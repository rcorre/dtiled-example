// phobos
import std.string : toStringz;

// dtiled
import dtiled.map;
import dtiled.coords;
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
  textBoxRegion   = Rect2f(700, 500, 100, 100)
}

private {
  OrthoMap!Tile _map;
  Camera        _camera;
  RowCol        _coordUnderMouse;
}

static this() {
  // load the map
  _map = buildMap(mapDataPath);

  // set up the camera
  float maxCameraX = _map.tileWidth  * _map.numCols - displayWidth;
  float maxCameraY = _map.tileHeight * _map.numRows - displayHeight;

  _camera = Camera(cameraSpeed, Vector2f(maxCameraX, maxCameraY));
}

int main(char[][] args) {
  auto backend = getBackend();

  backend.onMouseClicked = &onMouseClicked;
  backend.onMouseMoved   = &onMouseMoved;
  backend.onWASD         = &onWASD;
  backend.onUpdate       = &onUpdate;

  return backend.run();
}

void onMouseClicked(int button) {
  if (button == 1) {
    foreach(coord ; _map.enclosedCoords!(x => x.isObstruction)(_coordUnderMouse)) {
      _map.tileAt(coord).tint = tileHighlight;
    }
  }
  else {
    foreach(ref tile ; _map) {
      tile.tint = Color(1,1,1,1);
    }
  }
}

void onMouseMoved(Vector2f mousePos) {
  if (_map.containsPoint(mousePos)) {
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
    backend.drawTile(pos, tile.terrainRect, tile.tint);

    if (tile.hasFeature) {
      backend.drawTile(pos, tile.featureRect, tile.tint);
    }
  }
  backend.endDrawingMap();

  auto tile = _map.tileAt(_coordUnderMouse);
  auto info = [ tile.terrainName, tile.featureName, tile.isObstruction ? "Obstruction" : "" ];
  backend.drawTextbox(textBoxRegion, info, textColor, textBoxColor);

  backend.flipDisplay();
}
