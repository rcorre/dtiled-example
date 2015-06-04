// phobos
import std.string : toStringz;

// dtiled
import dtiled.map;
import dtiled.algorithm;

// local
import camera;
import backend;
import tilemap;
import backend;

private enum {
  displayWidth    = 800,
  displayHeight   = 600,
  cameraSpeed     = 5,
  framesPerSecond = 60,
  mapDataPath     = "./content/map1.json",
  tileNormalTint  = Color(1,1,1,1),
  tileHighlight   = Color(1,0,0,1),
  textColor       = Color(0.8,0,0,1),
  textBoxColor    = Color(1,1,1,0.4),
  textBoxRegion   = Rect2i(700, 500, 100, 100)
}

private {
  OrthoMap!Tile _map;
  Camera        _camera;
  RowCol        _coordUnderMouse;
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

void onMouseClicked(int button) {
  if (button == 1) {
    foreach(coord ; _map.enclosedCoords(_coordUnderMouse)) {
      coord.tint = tileHighlight;
    }
  }
  else {
    foreach(ref tile ; _map) {
      tile.tint = Color(1,1,1,1);
    }
  }
}

void onMouseMoved(Vector2f) {
  if (map.containsPoint(mousePos)) {
    _coordUnderMouse = _map.coordAtPoint(mousePos);
  }
}

void onWASD(Vector2i direction) {
  _camera.direction = direction;
}

void onUpdate(Backend backend) {
  _camera.update();

  backend.clearDisplay();

  backend.startDrawingMap(_camera.offset);
  foreach(coord, tile ; _map) {
    auto pos = _map.tileOffset(coord).as!Vector2f;
    backend.drawTile(pos, tile.terrainRegion, tile.tint);

    if (tile.hasFeature) {
      backend.drawTile(pos, tile.featureRegion, tile.tint);
    }
  }
  backend.endDrawingMap();

  auto tile = map.tileAt(_coordUnderMouse);
  auto info = [ tile.terrainName, tile.featureName, tile.isObstruction ? "Obstruction" : "" ];
  backend.drawTextbox(textBoxRegion, lines, textColor, textBoxColor);

  backend.flipDisplay();
}
