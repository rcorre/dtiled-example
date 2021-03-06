/// Tile and map structures
module tilemap;

// phobos
import std.conv      : to;
import std.range     : zip, chunks;
import std.array     : array;
import std.algorithm : map;

// dtiled
import dtiled;

// local
import backend;

/// represents a single tile within the map
struct Tile {
  Color4f tint; /// color to shade tile with when drawing

  const {
    string terrainName; /// name of terrain from map data
    string featureName; /// name of feature (tree/wall/ect.) from map data. null if no feature.
    Rect2i terrainRect; /// section of sprite atlas used to draw tile
    Rect2i featureRect; /// section of sprite atlas used to draw tile
    bool isObstruction; /// a custom property set in Tiled
  }

  @property bool hasFeature() { return featureRect.width > 0; }

  this(TiledGid terrainGid, TiledGid featureGid, TilesetData tileset) {
    Tile tile;
    tint = Color4f(1f,1f,1f,1f);

    if (terrainGid) {
      terrainName = tileset.tileProperties(terrainGid).get("name", null);

      terrainRect = Rect2i(tileset.tileOffsetX(terrainGid),
                           tileset.tileOffsetY(terrainGid),
                           tileset.tileWidth,
                           tileset.tileHeight);

      isObstruction = tileset.tileProperties(terrainGid).get("obstruction", "false").to!bool;
    }

    if (featureGid) {
      featureName = tileset.tileProperties(featureGid).get("name", null);

      featureRect = Rect2i(tileset.tileOffsetX(featureGid),
                           tileset.tileOffsetY(featureGid),
                           tileset.tileWidth,
                           tileset.tileHeight);
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

    return OrthoMap!Tile(tiles, data.tileWidth, data.tileHeight);
}
