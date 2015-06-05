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
  displaySize    = Vector2i(800,600),
  cameraSpeed    = 300,
  frameRate      = 60,
  mapDataPath    = "./content/map1.json",
  tileNormalTint = Color4f(1,1,1,1),
  tileHighlight  = Color4f(1,0,0,1),
  textColor      = Color4f(0.8,0,0,1),
  textBoxColor   = Color4f(1,1,1,0.4),
  textBoxRegion  = Rect2i(700, 500, 100, 100)
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
  float maxCameraX = _map.tileWidth  * _map.numCols - displaySize.x;
  float maxCameraY = _map.tileHeight * _map.numRows - displaySize.y;

  _camera = Camera(cameraSpeed, Vector2f(maxCameraX, maxCameraY));
}

int main(char[][] args) {
  auto backend = getBackend();

  backend.onMouseClicked = &onMouseClicked;
  backend.onMouseMoved   = &onMouseMoved;
  backend.onWASD         = &onWASD;
  backend.onUpdate       = &onUpdate;

  return backend.run(displaySize, frameRate);
}

void onMouseClicked(int button) {
  if (button == 1) {
    // LMB clicked, highlight all tiles in the enclosed area around the mouse.
    // if the mouse is not in an enclosed area, the returned range will be empty.
    foreach(coord ; _map.enclosedCoords!(x => x.isObstruction)(_coordUnderMouse)) {
      _map.tileAt(coord).tint = tileHighlight;
    }
  }
  else {
    // RMB clicked, iterate through all tiles to clear highlighting
    foreach(ref tile ; _map) {
      tile.tint = tileNormalTint;
    }
  }
}

void onMouseMoved(Vector2f mousePos) {
  // mouse pos is relative to screen, add camera offset to get point relative to map
  auto mapPos = Vector2f(mousePos.x + _camera.offset.x, mousePos.y + _camera.offset.y);

  if (_map.containsPoint(mapPos)) {
    _coordUnderMouse = _map.coordAtPoint(mapPos);
  }
}

void onWASD(Vector2i direction) {
  _camera.direction = direction;
}

void onUpdate(Backend backend, float time) {
  _camera.update(time);

  backend.clearDisplay();

  // draw the map tiles
  backend.startDrawingMap(_camera.offset);

  foreach(coord, tile ; _map) {
    auto pos = _map.tileOffset(coord).as!Vector2f;
    backend.drawTile(pos, tile.terrainRect, tile.tint);

    if (tile.hasFeature) {
      backend.drawTile(pos, tile.featureRect, tile.tint);
    }
  }

  backend.endDrawingMap();

  // draw a textbox showing info on the tile currently under the mouse
  auto tile = _map.tileAt(_coordUnderMouse);
  auto info = [ tile.terrainName, tile.featureName, tile.isObstruction ? "Obstruction" : "" ];
  backend.drawTextbox(textBoxRegion, info, textColor, textBoxColor);

  backend.flipDisplay();
}
