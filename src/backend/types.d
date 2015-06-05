/// Wrap some basic types shared by backends
module backend.types;

struct Rect2(T) {
  T x, y, width, height;

  @property auto right() { return x + width; }
  @property auto bottom() { return y + height; }
}

alias Rect2i = Rect2!int;
alias Rect2f = Rect2!float;

version (AllegroBackend) {
  import allegro5.allegro;

  alias Vector2i = Vector2!int;
  alias Vector2f = Vector2!float;

  struct Vector2(T) { T x, y; }

  alias Color = ALLEGRO_COLOR;
}

version (DGameBackend) {
  // provides Vector2i and Vector2f
  public import Dgame.Math.Vector2;

  import Dgame.Graphic.Color : Color4f;
  alias Color = Color4f;
}
