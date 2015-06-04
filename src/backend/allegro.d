module backend.allegro;

import backend.backend;
import backend.types;

import allegro5.allegro;
import allegro5.allegro_color;
import allegro5.allegro_font;
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

    void setup() {
      // basic allegro setup
      al_init();

      al_install_keyboard();
      al_install_mouse();
      al_init_image_addon();
      al_init_font_addon();
      al_init_ttf_addon();
      al_init_primitives_addon();

      _display   = al_create_display(displayWidth, displayHeight);
      _queue     = al_create_event_queue();
      _timer     = al_create_timer(1.0 / framesPerSecond);
      _tileAtlas = al_load_bitmap("./content/ground.png");
      _font      = al_load_font("./content/Mecha.ttf", 16, 0);

      al_register_event_source(queue, al_get_mouse_event_source());
      al_register_event_source(queue, al_get_keyboard_event_source());
      al_register_event_source(queue, al_get_timer_event_source(_timer));
      al_register_event_source(queue, al_get_display_event_source(_display));

      with(ALLEGRO_BLEND_MODE) {
        al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA);
      }

      al_start_timer(_timer);
    }

    void processEvent(in ALLEGRO_EVENT event) {
      switch(event.type)
      {
        case ALLEGRO_EVENT_KEY_DOWN:
          if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) {
            _exit = true; // press ESC to end game
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
          {
            if (event.mouse.button == 1) {
              auto origin = map.coordAtPoint(mousePos);
              foreach(coord ; map.enclosedCoords!(x => x.isObstruction)(origin)) {
                map.tileAt(coord).tint = al_map_rgb(255,0,0);
              }
            }
            else if (event.mouse.button == 2) {
              // right-click clears all highlights
              foreach(ref tile ; map) tile.tint = al_map_rgb(255,255,255);
            }
            break;
          }
        case ALLEGRO_EVENT_TIMER:
          _update = true; // time for a new frame
          break;
        default:
      }
    }

    void handleWASD(in ALLEGRO_EVENT event) {
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
      }

      onWASD(_scrollDirection);
    }

    int mainLoop() {
      setup();

      while(!_exit) {
        ALLEGRO_EVENT event;
        while(al_get_next_event(queue, &event)) {
          processEvent(event);
        }

        if (_update) {
          _update = false;
          onUpdate(this);
        }
      }

      shutdown();
      return 0;
    }
  }

  override {
    int run() {
      return al_run_allegro(&mainLoop);
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

    void drawTile(Vector2f pos, Rect2i spriteRect, Color tint) {
      al_draw_tinted_bitmap_region(
          _tileAtlas,                                      // bitmap
          tint,                                            // color
          region.x, region.y, region.width, region.height, // region of bitmap
          pos.x, pos.y,                                    // offset of tile
          0);                                              // flags
    }

    void drawTextbox(Rect2f rect, string[] lines, Color textColor, Color boxColor) {
      al_draw_filled_rectangle(rect.x, rect.y, rect.right, rect.bottom, boxColor);

      Vector2f pos = Vector2f(rect.x, rect.y);

      foreach(line ; lines) {
        al_draw_text(_font, textColor, pos.x, pos.y, 0, line.toStringz);
        pos.y += al_get_font_line_height(_font);
      }
    }
  }
}
