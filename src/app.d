import std.stdio;


// allegro
import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_color;

// local
import camera;
import tilemap;
import geometry;

private enum {
  displayWidth    = 800,
  displayHeight   = 600,
  cameraSpeed     = 5,
  framesPerSecond = 60,
  mapDataPath     = "./content/map1.json"
}

int main(char[][] args)
{
  return al_run_allegro(
  {
    // basic allegro setup
    al_init();

    ALLEGRO_DISPLAY* display = al_create_display(displayWidth, displayHeight);
    ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
    ALLEGRO_TIMER* timer = al_create_timer(1.0 / framesPerSecond);

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

    float maxCameraX = map.tileWidth * map.numCols - displayWidth;
    float maxCameraY = map.tileHeight * map.numRows - displayHeight;

    // set up the camera
    auto camera = Camera(cameraSpeed, Vector2f(maxCameraX, maxCameraY));

    al_start_timer(timer);
    bool exit = false;
    bool redraw = false;
    while(!exit)
    {
      ALLEGRO_EVENT event;
      while(al_get_next_event(queue, &event))
      {
        camera.handleInput(event);

        switch(event.type)
        {
          case ALLEGRO_EVENT_KEY_DOWN:
          {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) {
              exit = true; // press ESC to end game
            }
            break;
          }
          case ALLEGRO_EVENT_DISPLAY_CLOSE:
          {
            exit = true; // closing the display also ends the game
            break;
          }
          case ALLEGRO_EVENT_TIMER:
          {
            redraw = true; // time for a new frame
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

