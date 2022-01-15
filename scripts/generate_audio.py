#!/usr/bin/env python3

# Calls Famistudio to export the audio to Engine data and OGG
# and generates the ASM file that we can link against for Engine data

import argparse
import functools
import os
import pathlib
import shutil
import subprocess
import sys

def fm(*args, famistudio_path=None):
  # Default location for now is ../tools/famistudio/Famistudio
  if not famistudio_path:
    file_path = os.path.abspath(os.path.dirname(__file__))
    famistudio_path = f"{file_path}/../tools/famistudio/Famistudio"
  cmd = [famistudio_path, *args]
  if sys.platform != "win32":
    cmd = ["mono"] + cmd
  done = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, text=True)
  return done.stdout

def export_engine(fin, fout, famistudio_path=None):
  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(fout).resolve()
  project_name = fin.stem
  # export the engine to a single file to get the list of all the songs
  # that way we can split the sfx songs from the music songs
  fm(str(fin), 
    "famistudio-asm-export",
    f"{fout}/all_project.s",
    "-famistudio-asm-format:ca65",
    "-famistudio-generate-list", famistudio_path=famistudio_path)
  song_indicies = []
  sfx_indicies = []
  with open(f"{fout}/all_project_songlist.inc", 'r') as file:
    data = file.read().splitlines()
    for line in data:
      if line.startswith("song_max"):
        break
      elif line.startswith('song_sfx'):
        sfx_indicies += [line[line.rfind(" ")+1:]]
      elif line.startswith('song_'):
        song_indicies += [line[line.rfind(" ")+1:]]

  os.remove(f"{fout}/all_project_songlist.inc")
  os.remove(f"{fout}/all_project.dmc")
  os.remove(f"{fout}/all_project.s")

  print(f"Exporting SFX (project indicies: {sfx_indicies})")
  print(fm(str(fin),
    "famistudio-asm-sfx-export",
    f"{fout}/{project_name}_sfx.s",
    f"-export-songs:{','.join(sfx_indicies)}",
    "-famistudio-asm-format:ca65",
    "-famistudio-sfx-generate-list", famistudio_path=famistudio_path))

  # FIXUP: replace `sounds` inside the sfx file with a project specific name
  with open(f"{fout}/{project_name}_sfx.s", 'r') as f:
    s = f.read()
  s = s.replace("sounds", f"{project_name}_sfx")
  with open(f"{fout}/{project_name}_sfx.s", 'w') as f:
    f.write(s)

  print(f"Exporting songs (project indicies: {song_indicies})")
  return fm(str(fin),
    "famistudio-asm-export",
    f"{fout}/",
    f"-export-songs:{','.join(song_indicies)}",
    "-famistudio-asm-seperate-files",
    f"-famistudio-asm-seperate-song-pattern:{project_name}_{{song}}",
    f"-famistudio-asm-seperate-dmc-pattern:{project_name}",
    "-famistudio-asm-format:ca65",
    "-famistudio-generate-list", famistudio_path=famistudio_path)

def bin2h(fin):
  done = subprocess.run([str(shutil.which("bin2header")), str(fin)], stderr=subprocess.STDOUT, stdout=subprocess.PIPE, text=True)
  return done.stdout

def export_ogg(fin, fout, famistudio_path=None):
  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(fout).resolve()
  return fm(str(fin),
    "ogg-export",
    f"{fout}/{fin.stem}.ogg", famistudio_path=famistudio_path)

def generate_pc(fin, fout, famistudio_path=None):
  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(f"{fout}/pc/audio/").resolve()
  
  define = []
  include = []
  song_list = []
  song_list_len = []
  for i, file in enumerate(fin.rglob('*.fms')):
    song = file.stem
    export_ogg(file, fout, famistudio_path)
    print(bin2h(f"{fout}/{song}.ogg"))
    include += [f'#include "./{song}.ogg.h"']
    song_list += [f'{song}_ogg']
    song_list_len += [f'sizeof({song}_ogg)']
    define += ['#define ' + f'SONG_{song} {i}'.upper()]
  
  with open(f"{fout}/internal.c", 'w') as f:
    f.write(f'''
{os.linesep.join(include)}

const unsigned int cnes_songs_len = {len(song_list)};

const unsigned char* cnes_song_list[] = {{
  {(',' + os.linesep).join(song_list)}
}};

const unsigned int cnes_song_len[] = {{
  {(',' + os.linesep).join(song_list_len)}
}};
''')
  with open(f"{fout}/internal.h", 'w') as f:
    f.write(f'''
#ifndef __CNES_PC_AUDIO_H
#define __CNES_PC_AUDIO_H

{os.linesep.join(define)}

#endif //__CNES_PC_AUDIO_H
''') 


def generate_engine(fin, fout):
  '''Builds the asm module that should be linked with the build to provide audio
  This builds from all the FMS provided in the input directory.'''

  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(f"{fout}/nes/audio/").resolve()
  file_path = os.path.abspath(os.path.dirname(__file__))
  config = set()
  segments = set()
  for file in fin.rglob('*.fms'):
    project_name = file.stem
    cmd_output = export_engine(str(file), fout)
    if not cmd_output:
      continue
    print (cmd_output)
    for line in cmd_output.splitlines():
      # load up CONFIG vars and segment information
      if "Song '" in line:
        # grab the song name
        song_name = line[line.find('Song \'')+6:line.find('\' size')]
        segments.add(f'''
.segment "AUDIO_{project_name}_{song_name}"
.include "{project_name}_{song_name}.s"
.include "{project_name}_sfx.s"''')
      if 'Total dmc file size' in line:
        segments.add(f'''
.segment "AUDIO_{project_name}_dmc"
{project_name}_dmc:
.incbin "./{project_name}.dmc"''')
      # parse the cmd_output and grab any FAMISTUDIO_CONFIG vars and put them
      # into the template
      if "you must set" in line:
        # grab from FAMISTUDIO_ ... to the end
        config.add(line[line.find("FAMISTUDIO_"):-1])

  # If we didn't produce any output, bail before we write anything
  if not config or not segments:
    raise Exception("Unable to load any audio files")

  # Load the generated include files to get the name of the exported songs
  song_data = []
  songs = []
  define = []
  for i, file in enumerate(fout.rglob('*_songlist.inc')):
    with open(file) as f:
      songs += [file.stem[0:file.stem.find("_songlist")]]
      song_name = f.read().splitlines()[0]
      name = song_name[song_name.find("song_")+5:song_name.find(" =")]
      project_name = file.stem[0:file.stem.find(f"_{name}")]
      song_data += [{
        "banka": f".lobyte(.bank(music_data_{name}))",
        "bankc": f".lobyte(.bank({project_name}_dmc))",
        "addrhi": f".hibyte(music_data_{name})",
        "addrlo": f".lobyte(music_data_{name})",
        "sfxhi": f".hibyte({project_name}_sfx)",
        "sfxlo": f".lobyte({project_name}_sfx)",
      }]
      # intentionally offset the song number by 1
      # to make checking the queue is empty faster on NES
      define += ['#define ' + f'SONG_{name} {i+1}'.upper()]

  song_data = functools.reduce(lambda a,b: {
        "banka": ", ".join([a['banka'],b['banka']]),
        "bankc": ", ".join([a['bankc'],b['bankc']]),
        "addrhi": ", ".join([a['addrhi'],b['addrhi']]),
        "addrlo": ", ".join([a['addrlo'],b['addrlo']]),
        "sfxhi": ", ".join([a['sfxhi'],b['sfxhi']]),
        "sfxlo": ", ".join([a['sfxlo'],b['sfxlo']]),
      }, song_data)
  
  song_data_template = f"""
.export MusicBank_A, MusicBank_C, MusicAddrHi, MusicAddrLo, SFXAddrHi, SFXAddrLo
MusicBank_A: .byte {song_data['banka']}
MusicBank_C: .byte {song_data['bankc']}
MusicAddrHi: .byte {song_data['addrhi']}
MusicAddrLo: .byte {song_data['addrlo']}
SFXAddrHi:   .byte {song_data['sfxhi']}
SFXAddrLo:   .byte {song_data['sfxlo']}"""

  # now load the .s files for each of the songs to find the dmc sound effects
  for song in songs:
    with open(f"{fout}/{song}.s", 'r') as file:
      template = file.read()

  # write the data to the template file
  with open(f"{file_path}/audio_engine_template.s", 'r') as file:
    template = file.read()
  with open(f"{file_path}/famistudio_ca65.s", 'r') as file:
    engine = file.read()
  template = template.replace("{famistudio_segment_code}", os.linesep.join(segments))
  template = template.replace("{famistudio_music_list}", song_data_template)
  template = template.replace("{famistudio_config_options}", os.linesep.join(config))
  template = template.replace("{famistudio_engine_code}", engine)

  with open(f"{fout}/engine_build.s", 'w') as file:
    file.write(template)

  with open(f"{fout}/internal.h", 'w') as f:
    f.write(f'''
#ifndef __CNES_NES_AUDIO_H
#define __CNES_NES_AUDIO_H

{os.linesep.join(define)}

#endif //__CNES_NES_AUDIO_H
''') 

def create_dir_if_missing(d):
  pathlib.Path(d).mkdir(parents=True, exist_ok=True)

def main():
  parser = argparse.ArgumentParser(description='Processes Famistudio audio and outputs to NES and SDL formats')
  
  parser.add_argument('-a', '--all', action="store_true")
  parser.add_argument('-n', '--nes', action="store_true")
  parser.add_argument('-p', '--pc', action="store_true")
  parser.add_argument('-F', '--famistudio-path', type=str,
                      help='Path to the famistudio executable (Default: `../tools/famistudio/FamiStudio.exe`)''')
  parser.add_argument('fin', metavar='in', type=str,
                      help='Input Directory of fms files to build the song data from')
  parser.add_argument('fout', metavar='out', type=str,
                      help='Build Directory to write the output files to.')
                      
  args = parser.parse_args()
  create_dir_if_missing(args.fout)
  create_dir_if_missing(f"{args.fout}/nes/audio")
  create_dir_if_missing(f"{args.fout}/pc/audio")
  create_dir_if_missing(f"{args.fout}/inc")
  
  if (args.all):
    generate_pc(args.fin, args.fout, args.famistudio_path)
    generate_engine(args.fin, args.fout, args.famistudio_path)
  elif (args.nes):
    generate_engine(args.fin, args.fout, args.famistudio_path)
  elif (args.pc):
    generate_pc(args.fin, args.fout, args.famistudio_path)
  else:
    generate_pc(args.fin, args.fout, args.famistudio_path)
    generate_engine(args.fin, args.fout, args.famistudio_path)

  with open(f"{args.fout}/inc/cnes_audio_gen.h", 'w') as f:
    f.write('''
/**
 * Generated include file by the CNES build process. Include these
 * macros to use with the 
 */
#ifndef CNES_AUDIO_GEN_H
#define CNES_AUDIO_GEN_H
#ifdef __NES__
#include "../nes/audio/internal.h"
#else
#include "../pc/audio/internal.h"
#endif //__NES__
#endif //CNES_AUDIO_GEN_H
''')

if __name__ == '__main__':
  main()
