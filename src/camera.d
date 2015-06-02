// A simple camera that can scroll around the map
module camera;

// phobos
import std.math : fmax, fmin;

// allegro
import allegro5.allegro;

// local
import geometry;

// it is very simple and does not stop at the map borders
struct Camera {
  private {
    const float speed;
    Vector2f _position, _velocity, _maxPosition;
    ALLEGRO_TRANSFORM _trans;
  }

  this(float speed, Vector2f maxPosition) {
    this.speed = speed;
    _maxPosition = maxPosition;
    _position = Vector2f(0,0);
    _velocity = Vector2f(0,0);
  }

  @property const auto transform() { return &_trans; }

  // move the camera based on its current velocity
  void update() {
    // keep position inside map
    _position.x = (_position.x + _velocity.x).fmax(0).fmin(_maxPosition.x);
    _position.y = (_position.y + _velocity.y).fmax(0).fmin(_maxPosition.y);

    // compute the transform that performs a translation based on the camera position
    al_identity_transform(&_trans);
    al_translate_transform(&_trans, -_position.x, -_position.y);
  }

  /// Adjust the velocity based on keyboard input events
  void handleInput(in ALLEGRO_EVENT ev) {
    // only interested in keyboard events
    if (ev.type != ALLEGRO_EVENT_KEY_DOWN && ev.type != ALLEGRO_EVENT_KEY_UP) return;

    // change in speed
    float delta = (ev.type == ALLEGRO_EVENT_KEY_DOWN) ? speed : -speed;

    switch(ev.keyboard.keycode) {
      case ALLEGRO_KEY_W:
        _velocity.y -= delta;
        break;
      case ALLEGRO_KEY_S:
        _velocity.y += delta;
        break;
      case ALLEGRO_KEY_A:
        _velocity.x -= delta;
        break;
      case ALLEGRO_KEY_D:
        _velocity.x += delta;
        break;
      default:
    }
  }

  auto screenToWorldPos(Vector2f pos) {
    return Vector2f(pos.x + _position.x, pos.y + _position.y);
  }
}
