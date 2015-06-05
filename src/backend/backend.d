module backend.backend;

import backend.types;

abstract class Backend {
  /// Called when mouse is clicked, passed the button number
  void function(int) onMouseClicked;

  /// Called when mouse is moved, passed new position of mouse
  void function(Vector2f) onMouseMoved;

  /// Called when one of the WASD keys is pressed/released.
  /// Passed the current WASD direction (e.g. (1,1) if S and D are held)
  void function(Vector2i) onWASD;

  /// Called for each new frame, passed a reference to the backend and the time elapsed
  void function(Backend, float) onUpdate;

  /// entry point. returns when program is exited
  int run(Vector2i displaySize, float frameRate);

  /// Call before drawing any tiles. Pass the current camera offset to set up a transform.
  void startDrawingMap(Vector2f cameraOffset);

  /// Call after drawing tiles is done to clear camera transform
  void endDrawingMap();

  /// Call before doing any drawing for the current frame.
  void clearDisplay();

  /// Call after all drawing is done for the current frame.
  void flipDisplay();

  /// Draw a tile. Only call between calls to startDrawingMap and endDrawingMap.
  void drawTile(Vector2f pos, Rect2i spriteRect, Color tint);

  /// Draw a textbox containing the given lines of text.
  void drawTextbox(Rect2i rect, string[] lines, Color textColor, Color boxColor);
}
