module backend.dgame;

import backend.types;
import backend.backend;

import Dgame.Window;
import Dgame.Math.Geometry;
import Dgame.Math.Vertex;
import Dgame.System.Font;
import Dgame.System.StopWatch;
import Dgame.System.Keyboard;
import Dgame.Graphic;

class DGameBackend : Backend {
  private {
    Window   _window;
    Text     _text;
    Surface  _tileSurface;
    Texture  _tileTexture;
    Sprite   _tileSprite;
    Vector2i _scrollDirection;
    Vector2f _cameraOffset;
    bool     _exit, _update;
    ubyte    _ticksPerFrame;

    void processEvent(in Event ev) {
      switch(ev.type) with (Event.Type) {
        case Quit:
          _exit = true;
          break;
        case KeyDown:
          if (ev.keyboard.key == Keyboard.Key.Esc) {
            _exit = true;
          }
          else if (!ev.keyboard.isRepeat) {
            handleWASD(ev.keyboard.key, 1);
          }
          break;
        case KeyUp:
          if (!ev.keyboard.isRepeat) {
            handleWASD(ev.keyboard.key, -1);
          }
          break;
        default:
      }
    }

    void handleWASD(Keyboard.Key key, int factor) {
      switch (key) with (Keyboard.Key) {
        case W:
          _scrollDirection.y -= factor;
          break;
        case S:
          _scrollDirection.y += factor;
          break;
        case A:
          _scrollDirection.x -= factor;
          break;
        case D:
          _scrollDirection.x += factor;
          break;
        default:
          return;
      }

      onWASD(_scrollDirection);
    }
  }

override:
  /// entry point. returns when program is exited
  int run(Vector2i displaySize, float frameRate) {
    _ticksPerFrame = cast(ubyte) (1000 / frameRate);

    _window = Window(displaySize.x, displaySize.y, "DTiled DGame Demo");
    _window.setClearColor(Color4b.Black);

    auto font = Font("./content/Mecha.ttf", 16);
    _text = new Text(font);

    _tileSurface = Surface("./content/ground.png");
    _tileTexture = Texture(_tileSurface);
    _tileSprite = new Sprite(_tileTexture);
    _tileSprite.setPosition(300,300);

    StopWatch stopWatch;
    Event event;
    Time lastUpdateTime = stopWatch.getTime();

    while(!_exit) {
      while (_window.poll(&event)) {
        processEvent(event);
      }

      if (stopWatch.getElapsedTicks() >= _ticksPerFrame) {
        onUpdate(this, stopWatch.getElapsedTicks / 1000f);
        stopWatch.reset();
      }
    }

    return 0;
  }

  /// Call before drawing any tiles. Pass the current camera offset to set up a transform.
  void startDrawingMap(Vector2f cameraOffset) {
    _cameraOffset = cameraOffset;
  }

  /// Call after drawing tiles is done to clear camera transform
  void endDrawingMap() {
    _cameraOffset = Vector2f(0,0);
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
  void drawTile(Vector2f pos, Rect2i spriteRect, Color4f tint) {
    _tileSprite.setColor(Color4b(tint));
    _tileSprite.setTextureRect(spriteRect);
    _tileSprite.setPosition(pos - _cameraOffset);
    _window.draw(_tileSprite);
  }

  /// Draw a textbox containing the given lines of text.
  void drawTextbox(Rect2i rect, string[] lines, Color4f textColor, Color4f boxColor) {
    Shape box = new Shape(Geometry.Quad,
      [
        Vertex(rect.x    , rect.y     ),
        Vertex(rect.right, rect.y     ),
        Vertex(rect.right, rect.bottom),
        Vertex(rect.x    , rect.bottom),
      ]
    );

    box.fill = Shape.Fill.Full;
    box.setColor(Color4b(boxColor));

    _window.draw(box);

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
