// phobos
import std.string : toStringz;

// dtiled
import dtiled.algorithm;

// local
import camera;
import backend;
import tilemap;
import backend.geometry;
import properties;

private enum {
  displayWidth    = 800,
  displayHeight   = 600,
  cameraSpeed     = 5,
  framesPerSecond = 60,
  mapDataPath     = "./content/map1.json"
}

private {
  TileGrid!Tile _map;
  Camera        _camera;
}

int main(char[][] args) {
  auto backend = getBackend();

  backend.onMouseClicked = &onMouseClicked;
  backend.onMouseMoved   = &onMouseMoved;
  backend.onWASD         = &onWASD;
  backend.onUpdate       = &onUpdate;

  _map = buildMap(mapDataPath);

  // set up the camera
  float maxCameraX = map.tileWidth * map.numCols - displayWidth;
  float maxCameraY = map.tileHeight * map.numRows - displayHeight;
  _camera = Camera(cameraSpeed, Vector2f(maxCameraX, maxCameraY));

  return backend.run();
}

void onMouseClicked(int) {
}

void onMouseMoved(Vector2f) {
  if (map.containsPoint(mousePos)) {
    drawTileProperties(map.tileAtPoint(mousePos), font);
  }
}

void onWASD(Vector2f) {
}

void onUpdate(Backend) {
}
