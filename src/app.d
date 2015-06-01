import std.stdio;

// phobos
import std.math : fmax, fmin;

// allegro
import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_color;

// local
import tilemap;

private enum {
  displayWidth  = 800,
  displayHeight = 600,
  cameraSpeed   = 5,
  mapDataPath   = "./content/map1.json"
}

// the camera will allow us to scroll around the map
// it is very simple and does not stop at the map borders
struct Camera {
  float x = 0, y = 0;       // location
  float maxX = 0, maxY = 0; // bounds
  float velX = 0, velY = 0; // velocity

  @property auto transform() {
    ALLEGRO_TRANSFORM trans;
    al_identity_transform(&trans);
    al_translate_transform(&trans, -x, -y);
    return trans;
  }

  void update() {
    x = (x + velX).fmax(0).fmin(maxX);
    y = (y + velY).fmax(0).fmin(maxY);
  }
}

int main(char[][] args)
{
  return al_run_allegro(
  {
    // basic allegro setup
    al_init();

    ALLEGRO_DISPLAY* display = al_create_display(displayWidth, displayHeight);
    ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
    ALLEGRO_TIMER* timer = al_create_timer(1.0 / 60);

    al_install_keyboard();
    al_install_mouse();
    al_init_image_addon();

    al_register_event_source(queue, al_get_display_event_source(display));
    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_timer_event_source(timer));

    with(ALLEGRO_BLEND_MODE) {
      al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA);
    }

    // load the image we will use to draw tiles
    ALLEGRO_BITMAP* tileAtlas = al_load_bitmap("./content/ground.png");

    // build the map
    auto map = buildMap(mapDataPath);

    // set up the camera
    Camera camera;
    camera.maxX = map.tileWidth * map.numCols - displayWidth;
    camera.maxY = map.tileHeight * map.numRows - displayHeight;

    al_start_timer(timer);
    bool exit = false;
    bool redraw = false;
    while(!exit)
    {
      ALLEGRO_EVENT event;
      while(al_get_next_event(queue, &event))
      {
        switch(event.type)
        {
          case ALLEGRO_EVENT_DISPLAY_CLOSE:
          {
            exit = true;
            break;
          }
          case ALLEGRO_EVENT_KEY_DOWN:
          {
            switch(event.keyboard.keycode)
            {
              case ALLEGRO_KEY_ESCAPE:
              {
                exit = true;
                break;
              }
              case ALLEGRO_KEY_W:
                camera.velY -= cameraSpeed;
                break;
              case ALLEGRO_KEY_S:
                camera.velY += cameraSpeed;
                break;
              case ALLEGRO_KEY_A:
                camera.velX -= cameraSpeed;
                break;
              case ALLEGRO_KEY_D:
                camera.velX += cameraSpeed;
                break;
              default:
            }
            break;
          }
          case ALLEGRO_EVENT_KEY_UP:
          {
            switch(event.keyboard.keycode)
            {
              case ALLEGRO_KEY_W:
                camera.velY += cameraSpeed;
                break;
              case ALLEGRO_KEY_S:
                camera.velY -= cameraSpeed;
                break;
              case ALLEGRO_KEY_A:
                camera.velX += cameraSpeed;
                break;
              case ALLEGRO_KEY_D:
                camera.velX -= cameraSpeed;
                break;
              default:
            }
            break;
          }
          case ALLEGRO_EVENT_TIMER:
          {
            redraw = true;
            break;
          }
          default:
        }
      }

      if (redraw) {
        redraw = false;
        camera.update();
        auto transform = camera.transform;
        al_use_transform(&transform);
        al_clear_to_color(ALLEGRO_COLOR(0, 0, 0, 0));
        drawMap(map, tileAtlas);
        al_flip_display();
      }
    }

    return 0;
  });
}

