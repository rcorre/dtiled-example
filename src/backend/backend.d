module backend.backend;

import backend.geometry;

abstract class Backend {
  void delegate(int)      onMouseClicked;
  void delegate(Vector2f) onMouseMoved;
  void delegate(Vector2f) onWASD;
  void delegate(Backend)  onUpdate;

  int run();

  void startDrawingMap();
  void endDrawingMap();

  void clearDisplay()
  void flipDisplay();

  void setCameraTransform(Vector2f offset);
  void clearCameraTransform();

  void drawTile(Vector2f pos, Vector2f cameraOffset, Rect2i spriteRect, bool highlight);
  void drawInfo(string terrain, string feature, bool isObstruction);
}
