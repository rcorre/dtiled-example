/// Tile and map structures
module tilemap;

// phobos
import std.range     : zip, chunks;
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
  string featureName; /// name of feature (tree/wall/ect.) from map data. null if no feature.
  Rect2i terrainRect; /// section of sprite atlas used to draw tile
  Rect2i featureRect; /// section of sprite atlas used to draw tile

  this(TiledGid terrainGid, TiledGid featureGid, TilesetData tileset) {
    Tile tile;

    if (terrainGid) {
      terrainName = tileset.tileProperties(terrainGid).get("name", null);

      terrainRect.x = tileset.tileOffsetX(terrainGid);
      terrainRect.y = tileset.tileOffsetY(terrainGid);
      terrainRect.w = tileset.tileWidth;
      terrainRect.h = tileset.tileHeight;
    }

    if (featureGid) {
      featureName = tileset.tileProperties(featureGid).get("name", null);

      featureRect.x = tileset.tileOffsetX(featureGid);
      featureRect.y = tileset.tileOffsetY(featureGid);
      featureRect.w = tileset.tileWidth;
      featureRect.h = tileset.tileHeight;
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
      .zip(featureLayer.data)          // pair together terrain and feature gids
      .chunks(data.numCols)            // group together rows
      .map!(chunk => chunk
          .map!(gids => Tile(gids[0], gids[1], tileset)) // generate a tile from each GID pair
          .array)
      .array;                          // create an array of all the rows

    return OrthoMap!Tile(data.tileWidth, data.tileHeight, tiles);
}

void drawMap(OrthoMap!Tile map, ALLEGRO_BITMAP* atlas) {
  // this is an optimization for drawing multiple times from the same bitmap
  al_hold_bitmap_drawing(true);

  foreach(coord, tile ; map) {
    auto pos = map.tileOffset(coord);

    // draw ground sprite
    auto region = tile.terrainRect;
    if (region.w > 0) {
      al_draw_bitmap_region(
          atlas,                                  // bitmap
          region.x, region.y, region.w, region.h, // region of bitmap
          pos.x, pos.y,                           // offset of tile
          0);                                     // flags
    }

    // draw feature sprite (e.g. tree, mountain)
    region = tile.featureRect;
    if (region.w > 0) {
      al_draw_bitmap_region(
          atlas,                                  // bitmap
          region.x, region.y, region.w, region.h, // region of bitmap
          pos.x, pos.y,                           // offset of tile
          0);                                     // flags
    }
  }

  al_hold_bitmap_drawing(false);
}
