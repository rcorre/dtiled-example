/// Wrap some basic types shared by backends:
/// Vector2i/Vector2f
/// Rect2i
/// Color4f
module backend.types;

// Rect helpers
@property auto right(Rect2i rect)  { return rect.x + rect.width;  }
@property auto bottom(Rect2i rect) { return rect.y + rect.height; }

version (AllegroBackend) {
  import allegro5.allegro;

  struct Vector2(T) { T x, y; }
  alias Vector2i = Vector2!int;
  alias Vector2f = Vector2!float;

  struct Rect2i {
    int x, y;
    uint width, height;
  }

  alias Color4f = ALLEGRO_COLOR;
}

version (DGameBackend) {
  public import Dgame.Math.Vector2;
  public import Dgame.Graphic.Color : Color4f;

  import Dgame.Math.Rect;
  alias Rect2i = Rect;
}
