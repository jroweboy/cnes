
; Generated NES Tilemap code template.
; This file should be linked into the final build in order to load tilemaps

; Setup the segments where the audio/dmc data will end up in.
.segment "FIXED"
; Tilemap header table in the fixed bank.
; The format is as follows:
; width
; height
; tileset bank A id
; tiledata bank A id
; pointer to start of tileset data
; pointer to start of tile data
.export tilemap_header
tilemap_header:
{tilemap_header}

; Tilemap tileset data is encoded below
{tilemap_tilesets}

; Tilemap Map data is encoded below
; Tilemap data is encoded in 8 byte vertical strips that are using a custom Run Length Encoding format
; as described in the loader.
{tilemap_mapdata}
