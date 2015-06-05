module backend.dgame;

import backend.types;
import backend.backend;

import Dgame.Window;
import Dgame.System.StopWatch;
import Dgame.System.Keyboard;

class DGameBackend : Backend {
  private {
    Window _window;
    bool _exit, _update;

    void processEvent(in Event ev) {
      switch(ev.type) with (Event.Type) {
        case Quit:
          _exit = true;
          break;
        case KeyDown:
        case KeyUp:
          if (ev.keyboard.key == Keyboard.Key.Esc) {
            _exit = true;
          }
          else {
            handleWASD(ev);
          }
          break;
        default:
      }
    }

    void handleWASD(in Event ev) {
    }
  }

override:
  /// entry point. returns when program is exited
  int run(Vector2i displaySize, float frameRate) {
    _window = Window(displaySize.x, displaySize.y, "DTiled DGame Demo");
    _window.clear();
    _window.display();

    Event event;
    while(!_exit) {
      _window.clear();

      while (_window.poll(&event)) {
        processEvent(event);
      }

      _window.display();
    }

    return 0;
  }

  /// Call before drawing any tiles. Pass the current camera offset to set up a transform.
  void startDrawingMap(Vector2f cameraOffset) {
  }

  /// Call after drawing tiles is done to clear camera transform
  void endDrawingMap() {
  }

  /// Call before doing any drawing for the current frame.
  void clearDisplay() {
  }

  /// Call after all drawing is done for the current frame.
  void flipDisplay() {
  }

  /// Draw a tile. Only call between calls to startDrawingMap and endDrawingMap.
  void drawTile(Vector2f pos, Rect2i spriteRect, Color tint) {
  }

  /// Draw a textbox containing the given lines of text.
  void drawTextbox(Rect2i rect, string[] lines, Color textColor, Color boxColor) {
  }
}
