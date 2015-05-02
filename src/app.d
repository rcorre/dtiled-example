module a5test;

import std.stdio;

import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_ttf;
import allegro5.allegro_color;
import tiled;

int main(char[][] args)
{
	return al_run_allegro(
	{
    // basic allegro setup
		al_init();

		ALLEGRO_DISPLAY* display = al_create_display(800, 600);
		ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
    ALLEGRO_TIMER* timer = al_create_timer(1.0 / 60);

		al_install_keyboard();
		al_install_mouse();
		al_init_image_addon();
		al_init_ttf_addon();

		al_register_event_source(queue, al_get_display_event_source(display));
		al_register_event_source(queue, al_get_keyboard_event_source());
		al_register_event_source(queue, al_get_timer_event_source(timer));

    // load the image we will use to draw tiles
		ALLEGRO_BITMAP* tileAtlas = al_load_bitmap("./content/ground.png");

    // load the map
    auto map = TiledMap.load("./content/map1.json");

    // the layers determine which tiles go where
    auto groundLayer = map.getLayer("Ground");
    auto featureLayer = map.getLayer("Features");

    // the tileset contains data about the tiles
    auto tileset = map.getTileset("ground");

    with(ALLEGRO_BLEND_MODE) {
			al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA);
		}

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
							default:
						}
						break;
					}
					case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
					{
						exit = true;
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
        al_clear_to_color(ALLEGRO_COLOR(0, 0, 0, 0));
        map.drawLayer(groundLayer, tileset, tileAtlas);
        map.drawLayer(featureLayer, tileset, tileAtlas);
        al_flip_display();
      }
		}

		return 0;
	});
}

void drawLayer(TiledMap map, TiledLayer layer, TiledTileset tileset, ALLEGRO_BITMAP* atlas) {
  foreach(idx, gid ; layer.data) {
    if (gid == 0) { continue; } // no tile at this spot

    // based on the current index and the map grid size, we can determine where the top-left of the
    // tile should be drawn.
    float dx = layer.idxToCol(idx) * map.tilewidth;
    float dy = layer.idxToRow(idx) * map.tileheight;

    // the GID is used as an index into the tileset, and tells us what region of the tile atlas
    // should be used to draw the tile.
    float sx = tileset.tileOffsetX(gid);
    float sy = tileset.tileOffsetY(gid);
    float sw = tileset.tilewidth;
    float sh = tileset.tileheight;

    al_draw_bitmap_region(atlas, sx, sy, sw, sh, dx, dy, 0);
  }
}
