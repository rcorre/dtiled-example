// phobos
import std.string : toStringz;

// allegro
import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_ttf;
import allegro5.allegro_font;
import allegro5.allegro_color;
import allegro5.allegro_primitives;

// local
import camera;
import tilemap;
import geometry;

private enum {
  displayWidth    = 800,
  displayHeight   = 600,
  cameraSpeed     = 5,
  framesPerSecond = 60,
  infoTextRegion  = Rect2i(600, 400, 200, 200),
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
    al_init_font_addon();
    al_init_ttf_addon();
    al_init_primitives_addon();

    al_register_event_source(queue, al_get_display_event_source(display));
    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_mouse_event_source());
    al_register_event_source(queue, al_get_timer_event_source(timer));

    with(ALLEGRO_BLEND_MODE) {
      al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA);
    }

    // load the image we will use to draw tiles
    ALLEGRO_BITMAP* tileAtlas = al_load_bitmap("./content/ground.png");

    // load a font for drawing text
    ALLEGRO_FONT* font = al_load_font("./content/Mecha.ttf", 12, 0);

    // Keep track of the tile under the mouse
    Vector2f mousePos = Vector2f(0,0);

    // build the map
    auto map = buildMap(mapDataPath);

    // set up the camera
    float maxCameraX = map.tileWidth * map.numCols - displayWidth;
    float maxCameraY = map.tileHeight * map.numRows - displayHeight;
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
          case ALLEGRO_EVENT_MOUSE_AXES:
          {
            mousePos = Vector2f(event.mouse.x, event.mouse.y);
            // mousePos is in screen space -- translate to tilemap space
            al_transform_coordinates(camera.transform, &mousePos.x, &mousePos.y);
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

        // clear the display
        al_clear_to_color(ALLEGRO_COLOR(0, 0, 0, 0));

        // preserve the previous transform
        ALLEGRO_TRANSFORM prevTrans;
        al_copy_transform(&prevTrans, al_get_current_transform());

        // draw the map according to the camera transform
        al_use_transform(camera.transform);
        drawMap(map, tileAtlas);

        // reset the transform and draw the tile's terrain name
        al_use_transform(&prevTrans);
        auto tileUnderMouse = map.tileAtPoint(mousePos);
        al_draw_text(font, al_map_rgb(128, 0, 0), 0, 0, 0,
            tileUnderMouse.terrainName.toStringz);

        auto coord = map.coordAtPoint(mousePos);
        al_draw_textf(font, al_map_rgb(128, 0, 0), 0, 0, 0,
            "%d, %d", coord.row, coord.col);

        // flip the display to the window
        al_flip_display();
      }
    }

    return 0;
  });
}
