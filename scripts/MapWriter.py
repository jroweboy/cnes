# Filename  : MapWriter.py
# Authors   : Bjorn Lindeijer and Georg Muntingh
# Version   : 1.1
# Date      : April 29, 2008
# Copyright : Public Domain

import os, sys, math
import struct, base64, zlib
from pathlib import Path

from PIL import Image
from xml.dom.minidom import Document

class Tileset:
    """ This class represents a set of tiles.
    """

    def __init__(self, tileImageFile, tileWidth, tileHeight):
        self.TileWidth = tileWidth
        self.TileHeight = tileHeight
        self.Filename = tileImageFile
        self.Name = os.path.splitext(tileImageFile)[0]
        self.List = []
        self.TileDict = {}
        self.readTiles()

    def readTiles(self):
        """ This method reads the tiles from the tileset and also fills up the tile dictionary.
        """
        TileImage = Image.open(self.Filename).convert("RGB")
        TileIW, TileIH = TileImage.size
        TilesetW, TilesetH = TileIW // self.TileWidth, TileIH // self.TileHeight

        for y in range(TilesetH):
            for x in range(TilesetW):
                box = self.TileWidth * x, self.TileHeight * y, self.TileWidth * (x+1), self.TileHeight * (y+1)
                tile = TileImage.crop(box)
                self.List.append(tile)

                s = str(list(tile.getdata()))
                if not s in self.TileDict:
                    self.TileDict[s] = len(self.List) - 1

    def findTile(self, tileImage):
        """ This method returns the tile index for the given tile image if it is part of this tileset,
            and returns 0 if the tile could not be found. Constant complexity due to dictionary lookup.
        """
        s = str(list(tileImage.getdata()))
        if s in self.TileDict:
            return self.TileDict[s] + 1
        else:
            return 0

class TileMap:
    """ This class represents a tile map.
    """

    def __init__(self, mapImageFile, tileSet, tileWidth, tileHeight):
        self.TileWidth = tileWidth
        self.TileHeight = tileHeight
        self.TileSet = tileSet
        self.List = []
        self.readMap()

    def readMap(self):
        """ This function takes the map image, and obtains a list self.List, where
            an entry equals i if self.TileSet.List[i-1] is the corresponding picture on the map
            image. If a matching tile is not found, i is set to 0.
        """
        MapImage = Image.open(mapImageFile).convert("RGB")
        MapImageWidth, MapImageHeight = MapImage.size
        self.Width, self.Height = MapImageWidth // self.TileWidth, MapImageHeight // self.TileHeight
        progress = -1

        for y in range(self.Height):
            for x in range(self.Width):
                box = self.TileWidth * x, self.TileHeight * y, self.TileWidth * (x+1), self.TileHeight * (y+1)
                tile = MapImage.crop(box)
                self.List.append(self.TileSet.findTile(tile))

                # Calculate the progress, and print it to the screen.
                p = ((x + y * self.Width) * 100) / (self.Width * self.Height)
                if progress != p:
                    progress = p
        print("Completed reading map.")

    def write(self, fileName):
        doc = Document()
        map = doc.createElement("map")
        map.setAttribute("version", "0.99b")
        map.setAttribute("orientation", "orthogonal")
        map.setAttribute("width", str(self.Width))
        map.setAttribute("height", str(self.Height))
        map.setAttribute("tilewidth", str(self.TileWidth))
        map.setAttribute("tileheight", str(self.TileHeight))
        tileset = doc.createElement("tileset")
        tileset.setAttribute("name", self.TileSet.Name)
        tileset.setAttribute("firstgid", str(1))
        tileset.setAttribute("tilewidth", str(self.TileSet.TileWidth))
        tileset.setAttribute("tileheight", str(self.TileSet.TileHeight))
        image = doc.createElement("image")
        image.setAttribute("source", self.TileSet.Filename)
        tileset.appendChild(image)
        map.appendChild(tileset)
        layer = doc.createElement("layer")
        layer.setAttribute("name", "background")
        layer.setAttribute("width", str(self.Width))
        layer.setAttribute("height", str(self.Height))
        data = doc.createElement("data")

        data.setAttribute("encoding", "base64")
        TileData = b""
        for tileId in self.List:
            TileData = TileData + struct.pack("<l", tileId)  # pack the tileId into a long
        b64data = doc.createTextNode(base64.b64encode(TileData).decode("utf-8"))
        data.appendChild(b64data)

        layer.appendChild(data)
        map.appendChild(layer)
        doc.appendChild(map)
        file = open(fileName, "w")
        file.write(doc.toprettyxml(indent = " "))
        file.close()
        print("Completed writing tmx.")

if __name__ == "__main__":
  if sys.argv[1] == "--help":
      print("Usage  : python Image2Map.py [tileX] [tileY] <map image file> <tileset file>")
      print("Example: python MapWriter.py 8 8 JansHouse.png JansHouse-Tileset.png")
  elif len(sys.argv) < 5:
      print("Error  : You specified too few arguments!\n")
      print("Usage  : python Image2Map.py [tileX] [tileY] <map image file> <tileset file>")
      print("Example: python MapWriter.py 8 8 JansHouse.png JansHouse-Tileset.png")
  else:
      tileX, tileY = int(sys.argv[1]), int(sys.argv[2])
      mapImageFile, tileImageFile = str(Path(sys.argv[3]).resolve()), str(Path(sys.argv[4]).resolve())
      map = TileMap(mapImageFile, Tileset(tileImageFile, tileX, tileY), tileX, tileY)
      map.write(os.path.splitext(mapImageFile)[0] + ".tmx")