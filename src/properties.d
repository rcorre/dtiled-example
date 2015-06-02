/// Show a rect in the corner of the screen that displays info on the current tile properties.
module properties;

// phobos
import std.string : toStringz;

// allegro
import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

// local
import tilemap;

private enum {
  // bounds of rectangle to draw
  rectLeft   = 650,
  rectTop    = 550,
  rectRight  = 800,
  rectBottom = 600,

  // bounds of name text
  terrainNameX = rectLeft,
  terrainNameY = rectTop,

  // bounds of name text
  featureNameX = rectLeft,
  featureNameY = rectTop + 20,

  // bounds of obstruction text
  obstructionX = rectLeft,
  obstructionY = rectTop + 20,

  // colors
  rectColor = ALLEGRO_COLOR(1, 1, 1, 0.25),
  textColor = ALLEGRO_COLOR(0.5, 0, 0, 1),
}

/// Show a rect in the corner of the screen that displays info on the current tile properties.
void drawTileProperties(in Tile tile, in ALLEGRO_FONT* font) {
  al_draw_filled_rounded_rectangle( rectLeft, rectTop, rectRight, rectBottom, 10, 10, rectColor);

  al_draw_text(font, textColor, terrainNameX, terrainNameY, 0, tile.terrainName.toStringz);
  al_draw_text(font, textColor, featureNameX, featureNameY, 0, tile.featureName.toStringz);

  if (tile.isObstruction) {
    al_draw_text(font, textColor, obstructionX, obstructionY, 0, "Obstructs Movement");
  }
}
