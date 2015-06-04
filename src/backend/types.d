/// Wrap some basic types shared by backends
module backend.types;

alias Vector2i = Vector2!int;
alias Vector2f = Vector2!float;

alias Rect2i = Rect2!int;
alias Rect2f = Rect2!float;

import allegro5.allegro;

struct Vector2(T) {
  T x, y;
}

struct Rect2(T) {
  T x, y, width, height;

  @property auto right() { return x + width; }
  @property auto bottom() { return y + height; }
}

alias Color = ALLEGRO_COLOR;
