#!/usr/bin/env python3

# Calls Famistudio to export the audio to Engine data and OGG
# and generates the ASM file that we can link against for Engine data

import argparse
import os
import pathlib
import subprocess

def fm(*args):
  # Default location for now is ../tools/famistudio/Famistudio
  file_path = os.path.abspath(os.path.dirname(__file__))
  done = subprocess.run([f"{file_path}/../tools/famistudio/Famistudio", *args], stderr=subprocess.STDOUT, stdout=subprocess.PIPE, text=True)
  return done.stdout

def export_engine(fin, fout):
  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(fout).resolve()
  return fm(str(fin),
    "famistudio-asm-export",
    f"{fout}/",
    "-famistudio-asm-seperate-files",
    "-famistudio-asm-format:ca65",
    "-famistudio-asm-generate-list",
    "-famistudio-asm-sfx-generate-list")

def export_ogg(fin, fout):
  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(fout).resolve()
  for file in fin.rglob('*.fms'):
    fm(str(file),
      "ogg-export",
      f"{fout}/{file.stem}.ogg")

def generate_engine(fin, fout):
  '''Builds the asm module that should be linked with the build to provide audio
  This builds from all the FMS provided in the input directory.'''

  fin = pathlib.Path(fin).resolve()
  fout = pathlib.Path(fout).resolve()
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
.include "{project_name}_{song_name}.s"''')
      if 'Total dmc file size' in line:
        segments.add(f'''
.segment "AUDIO_{project_name}_dmc"
.incbin "./{project_name}.dmc"''')
      # parse the cmd_output and grab any FAMISTUDIO_CONFIG vars and put them
      # into the template
      if "you must set" in line:
        # grab from FAMISTUDIO_ ... to the end
        config.add(line[line.find("FAMISTUDIO_"):-1])

  # If we didn't produce any output, bail before we write anything
  if not config or not segments:
    raise Exception("Unable to load any audio files")

  # write the data to the template file
  with open(f"{file_path}/audio_engine_template.s", 'r') as file:
    template = file.read()
  with open(f"{file_path}/famistudio_ca65.s", 'r') as file:
    engine = file.read()
  template = template.replace("{famistudio_segment_code}", os.linesep.join(segments))
  template = template.replace("{famistudio_config_options}", os.linesep.join(config))
  template = template.replace("{famistudio_engine_code}", engine)
  with open(f"{fout}/engine_build.s", 'w') as file:
    file.write(template)

def create_dir_if_missing(d):
  pathlib.Path(d).mkdir(parents=True, exist_ok=True)

def main():
  parser = argparse.ArgumentParser(description='Processes Famistudio audio and outputs to NES and SDL formats')
  parser.add_argument('fin', metavar='in', type=str,
                      help='Input Directory of fms files to build the song data from')
  parser.add_argument('fout', metavar='out', type=str,
                      help='Build Directory to write the output files to')
                      
  args = parser.parse_args()
  create_dir_if_missing(args.fout)
  export_ogg(args.fin, args.fout)
  generate_engine(args.fin, args.fout)

if __name__ == '__main__':
  main()
