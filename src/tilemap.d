/// Tile and map structures
module tilemap;

// phobos
import std.range     : chunks;
import std.array     : array;
import std.algorithm : map;

// allegro
import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_color;

// dtiled
import dtiled;

// local
import geometry;

/// represents a single tile within the map
struct Tile {
  string terrainName; /// name of terrain from map data
  //string featureName; /// name of feature (tree/wall/ect.) from map data. null if no feature.
  Rect2i terrainRect; /// section of sprite atlas used to draw tile
  Rect2i featureRect; /// section of sprite atlas used to draw tile

  this(TiledGid gid, TilesetData tileset) {
    Tile tile;
    // a gid of 0 would indicate no tile at that position
    if (gid) {
      terrainName = tileset.tileProperties(gid).get("name", "unknown");

      terrainRect.x = tileset.tileOffsetX(gid);
      terrainRect.y = tileset.tileOffsetY(gid);
      terrainRect.w = tileset.tileWidth;
      terrainRect.h = tileset.tileHeight;
    }
  }
}

auto buildMap(string dataPath) {
    auto data = MapData.load(dataPath);

    // the layers determine which tiles go where
    auto groundLayer = data.getLayer("Ground");
    auto featureLayer = data.getLayer("Features");

    // the tileset contains data about the tiles
    auto tileset = data.getTileset("ground");

    auto tiles = groundLayer.data
      .chunks(data.numCols)                // group together rows
      .map!(row => row                     // for each row
          .map!(gid => Tile(gid, tileset)) // generate a tile from each GID
          .array)                          // create an array for that row
      .array;                              // create an array of all the rows

    return OrthoMap!Tile(data.tileWidth, data.tileHeight, tiles);
}

void drawMap(OrthoMap!Tile map, ALLEGRO_BITMAP* atlas) {
  foreach(coord, tile ; map) {
    auto pos = map.tileOffset(coord);
    auto region = tile.terrainRect;

    al_draw_bitmap_region(
        atlas,                                  // bitmap
        region.x, region.y, region.w, region.h, // region of bitmap
        pos.x, pos.y,                           // offset of tile
        0);                                     // flags
  }
}
