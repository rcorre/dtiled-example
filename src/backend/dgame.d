module backend.dgame;

import backend.types;
import backend.backend;

import Dgame.Window;
import Dgame.System.Font;
import Dgame.System.StopWatch;
import Dgame.System.Keyboard;
import Dgame.Graphic.Text;
import Dgame.Graphic.Color : Color4b;

class DGameBackend : Backend {
  private {
    Window _window;
    Text   _text;
    bool   _exit, _update;
    ubyte  _ticksPerFrame;

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
    _ticksPerFrame = cast(ubyte) (1000 / frameRate);
    _window = Window(displaySize.x, displaySize.y, "DTiled DGame Demo");
    auto font = Font("./content/Mecha.ttf", 16);
    _text = new Text(font);

    StopWatch stopWatch;
    Event event;
    Time lastUpdateTime = stopWatch.getTime();

    while(!_exit) {
      while (_window.poll(&event)) {
        processEvent(event);
      }

      if (stopWatch.getTicks() >= _ticksPerFrame) {
        onUpdate(this, stopWatch.getElapsedTime.seconds);
        stopWatch.reset();
      }
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
    _window.clear();
  }

  /// Call after all drawing is done for the current frame.
  void flipDisplay() {
    _window.display();
  }

  /// Draw a tile. Only call between calls to startDrawingMap and endDrawingMap.
  void drawTile(Vector2f pos, Rect2i spriteRect, Color tint) {
  }

  /// Draw a textbox containing the given lines of text.
  void drawTextbox(Rect2i rect, string[] lines, Color textColor, Color boxColor) {
    _text.foreground = Color4b(textColor);
    _text.x = rect.x;
    _text.y = rect.y;

    foreach (line ; lines) {
      _text.setData(line);
      _window.draw(_text);
      _text.y = _text.y + _text.height;
    }
  }
}
