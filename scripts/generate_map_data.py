#!/usr/bin/env python3

import argparse
import csv
import os
import pathlib
import xml.etree.ElementTree as ET
from PIL import Image

# local
from pb8 import pb8
from pilbmp2nes import pilbmp2chr

_scroll_vals_allowed = ["none", "horizontal", "vertical", "omni"]

class TileMap:
  """ This class represents a tile map.
  """
  def __init__(self, fin: pathlib.Path):
    with open(fin, 'r') as f:
      map = ET.parse(f).getroot()
    self.name = fin.stem
    print(f"Processing tilemap: {self.name}")
    self.mapwidth = map.get("width")
    self.mapheight = map.get("height")
    if int(map.get("tilewidth")) != 8:
      print("WARNING: Map Tile Width is not 8 pixels! Actual: ")
    if int(map.get("tileheight")) != 8:
      print("WARNING: Map Tile Height is not 8 pixels!")
      
    scrollnode = map.find('.//properties/property[@name="scroll"]')
    scrollval = "none"
    if scrollnode is not None:
      scrollval = scrollnode.get("value")
      if scrollval not in _scroll_vals_allowed:
        print(f"WARNING: 'Scroll' not set to one of the following allowed values: {_scroll_vals_allowed}. Default: none")
    else:
      print("WARNING: Custom map property 'scroll' not set!")
    self.scroll = scrollval

    if map.get("renderorder") != "right-down":
      print("ERROR: Map render order is not right-down!")
    tileset = map.find(".//tileset/image")
    tilefile = (fin.parent / tileset.get("source")).resolve()
    self.rawtileset = Image.open(tilefile)

    backgrounddata = map.find('.//layer[@name="background"]/data')
    if backgrounddata.get("encoding") != "csv":
      print("ERROR: Background layer data encoding is not CSV!")
    # import pdb; pdb.set_trace()
    self.tiles = list(csv.reader(backgrounddata.text.split("\n")))

def generate_pc(fin: pathlib.Path, fout: pathlib.Path):
  pass

def chunks(lst, n):
  """Yield successive n-sized chunks from lst."""
  for i in range(0, len(lst), n):
    yield lst[i:i + n]

def flatten(t):
  return [item for sublist in t for item in sublist]

def compress_nes_tileset(im: Image):
  byteplanes = b''.join(pilbmp2chr(im))
  compressed = flatten(list(pb8(byteplanes)))
  return [[f'${x:02x}' for x in chunk] for chunk in chunks(compressed, 16)]

def compress_nes_mapdata(tiles: list):
  compressed = flatten(list(pb8([int(x)-1 for x in flatten(tiles) if x])))
  return [[f'${x:02x}' for x in row] for row in chunks(compressed, 16)]

def generate_nes(fin: pathlib.Path, fout: pathlib.Path):
  nesout = fout / "nes" / "tilemap"
  create_dir_if_missing(nesout)
  template_path = pathlib.Path(os.path.abspath(os.path.dirname(__file__)))

  header_data = []
  tileset_data = []
  map_data = []
  define = []
  for i, f in enumerate(fin.glob('*.tmx')):
    tilemap = TileMap(f)
    name = tilemap.name
    byte_header = ','.join([f'#{tilemap.mapwidth}', f'#{tilemap.mapheight}', f'.bank(@tileset_{name})', f'.bank(@tileset_{name})'])
    word_header = ','.join([f'@tileset_{name}', f'@tiledata_{name}'])
    header_data += [f'@tilemap_{name}_header: .byte {byte_header} .word {word_header}']
    tileset = [f"  .byte {','.join(plane)}" for plane in compress_nes_tileset(tilemap.rawtileset)]
    tileset = "\n".join(tileset)
    tileset_data += [f'@tileset_{name}: \n{tileset}']
    maptiles = [f"  .byte {','.join(row)}" for row in compress_nes_mapdata(tilemap.tiles)]
    maptiles = "\n".join(maptiles)
    map_data += [f'@mapdata_{name}: \n{maptiles}']
    define += [f'#define MAP_{name.upper()} {i}']
    print(f"Completed processing for {tilemap.name}")
  define = '\n'.join(define)

  with open(template_path / "nes_tilemap_template.s", 'r') as file:
    template = file.read()
  template = template.replace("{tilemap_header}", '\n'.join(header_data))
  template = template.replace("{tilemap_tilesets}", '\n'.join(tileset_data))
  template = template.replace("{tilemap_mapdata}", '\n'.join(map_data))
  with open(nesout / "cnes_nes_tilemap_gen_internal.s", 'w') as file:
    file.write(template)

  with open(nesout / "cnes_nes_tilemap_gen_internal.h", 'w') as f:
    f.write(f'''
#ifndef __CNES_NES_TILEMAP_GEN_H
#define __CNES_NES_TILEMAP_GEN_H

{define}

#endif //__CNES_NES_TILEMAP_GEN_H
''')

def create_dir_if_missing(d: pathlib.Path):
  d.mkdir(parents=True, exist_ok=True)

def main(build: str, infile: str, outfile: str):
  fin = pathlib.Path(infile).resolve()
  fout = pathlib.Path(outfile).resolve()
  if build == "pc":
    generate_pc(fin, fout)
  elif build == "nes":
    generate_nes(fin, fout)
  else:
    generate_pc(fin, fout)
    generate_nes(fin, fout)

  with open((fout / "inc").with_name("cnes_tilemap_gen.h"), 'w') as f:
    f.write('''
/**
 * Generated include file by the CNES build process. Include these
 * macros to use with the 
 */
#ifndef CNES_TILEMAP_GEN_H
#define CNES_TILEMAP_GEN_H
#ifdef __NES__
#include "../nes/tilemap/cnes_nes_tilemap_gen_internal.h"
#else
#include "../pc/tilemap/cnes_pc_tilemap_gen_internal.h"
#endif //__NES__
#endif //CNES_TILEMAP_GEN_H
''')

if __name__ == '__main__':
  parser = argparse.ArgumentParser(description='Processes Famistudio audio and outputs to NES and SDL formats')
  
  parser.add_argument('-a', '--all', action="store_true")
  parser.add_argument('-n', '--nes', action="store_true")
  parser.add_argument('-p', '--pc', action="store_true")
  parser.add_argument('fin', metavar='in', type=str,
                      help='Input Directory of tmx files to build the tilemap data from.')
  parser.add_argument('fout', metavar='out', type=str,
                      help='Build Directory to write the output files to.')

  args = parser.parse_args()
  
  if args.nes:
    build = "nes"
  elif args.pc:
    build = "pc"
  else:
    build = "all"

  main(build, args.fin, args.fout)
