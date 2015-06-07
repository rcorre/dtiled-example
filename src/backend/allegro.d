module backend.allegro;

import std.string : toStringz;

import backend.backend;
import backend.types;

import allegro5.allegro;
import allegro5.allegro_ttf;
import allegro5.allegro_font;
import allegro5.allegro_color;
import allegro5.allegro_image;
import allegro5.allegro_primitives;

class AllegroBackend : Backend {
  private {
    ALLEGRO_FONT*        _font;
    ALLEGRO_TIMER*       _timer;
    ALLEGRO_BITMAP*      _tileAtlas;
    ALLEGRO_DISPLAY*     _display;
    ALLEGRO_EVENT_QUEUE* _queue;

    bool _exit, _update;
    Vector2i _scrollDirection;

    void setup(Vector2i displaySize, float frameRate) {
      // basic allegro setup
      al_init();

      al_install_keyboard();
      al_install_mouse();
      al_init_image_addon();
      al_init_font_addon();
      al_init_ttf_addon();
      al_init_primitives_addon();

      _display   = al_create_display(displaySize.x, displaySize.y);
      _queue     = al_create_event_queue();
      _timer     = al_create_timer(1.0 / frameRate);
      _tileAtlas = al_load_bitmap("./content/ground.png");
      _font      = al_load_font("./content/Mecha.ttf", 16, 0);

      al_register_event_source(_queue, al_get_mouse_event_source());
      al_register_event_source(_queue, al_get_keyboard_event_source());
      al_register_event_source(_queue, al_get_timer_event_source(_timer));
      al_register_event_source(_queue, al_get_display_event_source(_display));

      with(ALLEGRO_BLEND_MODE) {
        al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA);
      }

      al_start_timer(_timer);
    }

    void shutdown() {
      al_destroy_display(_display);
      al_destroy_event_queue(_queue);
      al_destroy_timer(_timer);
      al_destroy_bitmap(_tileAtlas);
      al_destroy_font(_font);
    }

    void processEvent(in ALLEGRO_EVENT event) {
      switch(event.type)
      {
        case ALLEGRO_EVENT_KEY_DOWN:
          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) {
            _exit = true; // press ESC to end game
          }
          else if (event.keyboard.keycode == ALLEGRO_KEY_SPACE) {
            onToggleTool();
          }
          else {
            handleWASD(event);
          }
          break;
        case ALLEGRO_EVENT_KEY_UP:
          handleWASD(event);
          break;
        case ALLEGRO_EVENT_DISPLAY_CLOSE:
          _exit = true; // closing the display also ends the game
          break;
        case ALLEGRO_EVENT_MOUSE_AXES:
          onMouseMoved(Vector2f(event.mouse.x, event.mouse.y));
          break;
        case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
          onMouseClicked(event.mouse.button);
          break;
        case ALLEGRO_EVENT_TIMER:
          _update = true; // time for a new frame
          break;
        default:
      }
    }

    void handleWASD(in ALLEGRO_EVENT ev) {
      float factor = (ev.type == ALLEGRO_EVENT_KEY_DOWN) ? 1 : -1;

      switch(ev.keyboard.keycode) {
        case ALLEGRO_KEY_W:
          _scrollDirection.y -= factor;
          break;
        case ALLEGRO_KEY_S:
          _scrollDirection.y += factor;
          break;
        case ALLEGRO_KEY_A:
          _scrollDirection.x -= factor;
          break;
        case ALLEGRO_KEY_D:
          _scrollDirection.x += factor;
          break;
        default:
          return; // not a movement key
      }

      onWASD(_scrollDirection);
    }

    void mainLoop() {
      float lastUpdateTime = al_get_time();

      while(!_exit) {
        ALLEGRO_EVENT event;
        while(al_get_next_event(_queue, &event)) {
          processEvent(event);
        }

        if (_update) {
          float curTime = al_get_time();
          float delta = curTime - lastUpdateTime;
          lastUpdateTime = curTime;

          _update = false;
          onUpdate(this, delta);
        }
      }
    }
  }

  override {
    int run(Vector2i displaySize, float frameRate) {
      return al_run_allegro({
          setup(displaySize, frameRate);
          mainLoop();
          shutdown();
          return 0;
      });
    }

    void clearDisplay() {
      al_clear_to_color(ALLEGRO_COLOR(0, 0, 0, 0));
    }

    void flipDisplay() {
      al_flip_display();
    }

    void startDrawingMap(Vector2f cameraOffset) {
      al_identity_transform(al_get_current_transform());
      al_translate_transform(al_get_current_transform(), -cameraOffset.x, -cameraOffset.y);
      al_hold_bitmap_drawing(true); // optimization for drawing from same bitmap
    }

    void endDrawingMap() {
      al_identity_transform(al_get_current_transform());
      al_hold_bitmap_drawing(false);
    }

    void drawTile(Vector2f pos, Rect2i spriteRect, Color4f tint) {
      al_draw_tinted_bitmap_region(
          _tileAtlas,                          // bitmap
          tint,                                // color
          spriteRect.x, spriteRect.y,          // sprite offset
          spriteRect.width, spriteRect.height, // sprite size
          pos.x, pos.y,                        // offset of tile
          0);                                  // flags
    }

    void drawTextbox(Rect2i rect, string[] lines, Color4f textColor, Color4f boxColor) {
      al_draw_filled_rectangle(rect.x, rect.y, rect.right, rect.bottom, boxColor);

      Vector2f pos = Vector2f(rect.x, rect.y);

      foreach(line ; lines) {
        al_draw_text(_font, textColor, pos.x, pos.y, 0, line.toStringz);
        pos.y += al_get_font_line_height(_font);
      }
    }
  }
}
