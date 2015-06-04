// A simple camera that can scroll around the map
module camera;

import std.math : fmax, fmin;
import backend;

// it is very simple and does not stop at the map borders
struct Camera {
    const float speed;     /// rate of movement in set direction per update
    const Vector2f maxPos; /// maximum position of lower right corner
    Vector2f offset;       /// position of top-left corner
    Vector2i direction;    /// direction of movement

  this(float speed, Vector2f maxPosition) {
    this.speed  = speed;
    this.maxPos = maxPosition;
    offset      = Vector2f(0,0);
    direction   = Vector2i(0,0);
  }

  // move the camera based on its current velocity
  void update() {
    auto dx = speed * direction.x;
    auto dy = speed * direction.y;

    // keep position inside map
    offset.x = (offset.x + dx).fmax(0).fmin(maxPos.x);
    offset.y = (offset.y + dy).fmax(0).fmin(maxPos.y);
  }

  auto screenToWorldPos(Vector2f pos) {
    return Vector2f(pos.x + offset.x, pos.y + offset.y);
  }
}
