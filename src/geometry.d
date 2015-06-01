/// Basic geometric structs
module geometry;

alias Vector2i = Vector2!int;
alias Vector2f = Vector2!float;

struct Vector2(T) {
  T x, y;
}

alias Rect2i = Rect2!int;
alias Rect2f = Rect2!float;

struct Rect2(T) {
  T x, y, w, h;
}
