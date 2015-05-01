module a5test;

import std.stdio;

import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_font;
import allegro5.allegro_ttf;
import allegro5.allegro_color;
import tiled;

int main(char[][] args)
{
	return al_run_allegro(
	{
		al_init();

		ALLEGRO_DISPLAY* display = al_create_display(800, 600);

		ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();

		al_install_keyboard();
		al_install_mouse();
		al_init_image_addon();
		al_init_font_addon();
		al_init_ttf_addon();

		al_register_event_source(queue, al_get_display_event_source(display));
		al_register_event_source(queue, al_get_keyboard_event_source());
		al_register_event_source(queue, al_get_mouse_event_source());

    auto map = TiledMap.load("./content/map1.json");
		ALLEGRO_BITMAP* tileAtlas = al_load_bitmap("./content/ground.png");

    auto layer = map.getLayer("Ground");
    auto tileset = map.getTileset("ground");
		//ALLEGRO_FONT* font = al_load_font("DejaVuSans.ttf", 18, 0);

		with(ALLEGRO_BLEND_MODE)
		{
			al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA);
		}

		bool exit = false;
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
					default:
				}
			}

			al_clear_to_color(ALLEGRO_COLOR(0, 0, 0, 0));
      map.drawLayer(layer, tileset, tileAtlas);
			//al_draw_text(font, ALLEGRO_COLOR(1, 1, 1, 1), 70, 40, ALLEGRO_ALIGN_CENTRE, "Hello!");
			al_flip_display();
		}

		return 0;
	});
}

void drawLayer(TiledMap map, TiledLayer layer, TiledTileset tileset, ALLEGRO_BITMAP* atlas) {
  foreach(idx, gid ; layer.data) {
    float dx = layer.idxToCol(idx) * map.tilewidth;
    float dy = layer.idxToRow(idx) * map.tileheight;

    float sx = tileset.tileOffsetX(gid);
    float sy = tileset.tileOffsetY(gid);
    float sw = tileset.tilewidth;
    float sh = tileset.tileheight;

    al_draw_bitmap_region(atlas, sx, sy, sw, sh, dx, dy, 0);
  }
}
