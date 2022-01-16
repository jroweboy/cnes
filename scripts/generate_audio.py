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

# debugging
import inspect

def fm(*args, famistudio_path=None):
  # Default location for now is ../tools/famistudio/Famistudio
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
  if not famistudio_path:
    file_path = os.path.abspath(os.path.dirname(__file__))
    famistudio_path = f"{file_path}/../tools/famistudio/Famistudio"
  cmd = [famistudio_path, *args]
  if sys.platform != "win32":
    mono = str(shutil.which("mono"))
    cmd = [mono] + cmd
    if 'CI' in os.environ:
      xvfb = str(shutil.which("xvfb-run"))
      cmd = [xvfb, '--auto-servernum'] + cmd
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
  done = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, text=True)
  return done.stdout

def export_engine(fin, fout, famistudio_path=None):
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
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
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
  os.remove(f"{fout}/all_project_songlist.inc")
  os.remove(f"{fout}/all_project.dmc")
  os.remove(f"{fout}/all_project.s")

  print(f"Exporting NES SFX (project indicies: {sfx_indicies})")
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

  print(f"Exporting NES songs (project indicies: {song_indicies})")
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
  '''Generates a C header file from a binary file.'''
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
  fin = pathlib.Path(fin).resolve()
  var_name = fin.name.replace(".", "_").replace(" ", "_")
  fout = fin.with_suffix(fin.suffix+'.h')
  with open(fin, 'rb') as input:
    with open(fout, 'w') as output:
      data_len = 0
      output.write(f'''
// Generated from {fin.name} by bin2header (python impl)
unsigned char {var_name}[] = {{
''')
      # writes the previous line ending after the next line is read
      # so we don't end up with a trailing comma
      write_line_ending = False
      while True:
        data = input.read(1024 * 1024)
        if not data:
          break
        data_len += len(data)
        lines = [data[i:i+16] for i in range(0, len(data), 16)]
        for line in lines:
          if write_line_ending:
            output.write(f',\n')
          line = ','.join([f"0x{byte:02x}" for byte in line])
          output.write(f'{line}')
          write_line_ending = True
      output.write(f'}};\n')
      output.write('unsigned int {var_name}_len = {data_len};'.format(var_name=var_name, data_len=len(data)))

def export_ogg(fin, fout, famistudio_path=None):
  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(fout).resolve()
  return fm(str(fin),
    "ogg-export",
    f"{fout}/{fin.stem}.ogg", famistudio_path=famistudio_path)

def generate_pc(fin, fout, famistudio_path=None):
  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(f"{fout}/pc/audio/").resolve()
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
  
  define = []
  include = []
  song_list = []
  song_list_len = []
  for i, file in enumerate(fin.rglob('*.fms')):
    print(f"{inspect.getframeinfo(inspect.currentframe())}")
    song = file.stem
    print(f"Exporting PC audio track {file.stem} and converting to C header")
    export_ogg(file, fout, famistudio_path)
    bin2h(f"{fout}/{song}.ogg")
    include += [f'#include "./{song}.ogg.h"']
    song_list += [f'{song}_ogg']
    song_list_len += [f'sizeof({song}_ogg)']
    define += ['#define ' + f'SONG_{song} {i}'.upper()]
  include = '\n'.join(include)
  song_len = len(song_list)
  song_list = ',\n'.join(song_list)
  song_list_len = ',\n'.join(song_list_len)
  with open(f"{fout}/cnes_pc_audio_gen_internal.c", 'w') as f:
    f.write(f'''
{include}

const unsigned int cnes_song_list_len = {song_len};

const unsigned char* cnes_song_list[] = {{
  {song_list}
}};

const unsigned int cnes_song_len[] = {{
  {song_list_len}
}};
''')

  define = '\n'.join(define)
  with open(f"{fout}/cnes_pc_audio_gen_internal.h", 'w') as f:
    f.write(f'''
#ifndef __CNES_PC_AUDIO_H
#define __CNES_PC_AUDIO_H

{define}

#endif //__CNES_PC_AUDIO_H
''') 


def generate_engine(fin, fout, famistudio_path=None):
  '''Builds the asm module that should be linked with the build to provide audio
  This builds from all the FMS provided in the input directory.'''

  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(f"{fout}/nes/audio/").resolve()
  file_path = os.path.abspath(os.path.dirname(__file__))
  config = set()
  segments = set()
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
  for file in fin.rglob('*.fms'):
    project_name = file.stem
    print(f"{inspect.getframeinfo(inspect.currentframe())}")
    cmd_output = export_engine(str(file), fout, famistudio_path)
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
  print(f"{inspect.getframeinfo(inspect.currentframe())}")
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
  template = template.replace("{famistudio_segment_code}", '\n'.join(segments))
  template = template.replace("{famistudio_music_list}", song_data_template)
  template = template.replace("{famistudio_config_options}", '\n'.join(config))
  template = template.replace("{famistudio_engine_code}", engine)

  print(f"{inspect.getframeinfo(inspect.currentframe())}")
  with open(f"{fout}/cnes_nes_audio_gen_internal.s", 'w') as file:
    file.write(template)
  print()
  define = '\n'.join(define)
  with open(f"{fout}/cnes_nes_audio_gen_internal.h", 'w') as f:
    f.write(f'''
#ifndef __CNES_NES_AUDIO_H
#define __CNES_NES_AUDIO_H

{define}

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
#include "../nes/audio/cnes_nes_audio_gen_internal.h"
#else
#include "../pc/audio/cnes_pc_audio_gen_internal.h"
#endif //__NES__
#endif //CNES_AUDIO_GEN_H
''')

if __name__ == '__main__':
  main()
