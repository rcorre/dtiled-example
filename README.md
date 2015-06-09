DTiled Allegro Example
===

This is an demo of [dtiled](https://github.com/rcorre/dtiled), a general-purpose
tilemap library.

# How do I run it?
[DAllegro](https://github.com/SiegeLord/DAllegro5) or
[DGame](https://github.com/Dgame/Dgame) as a backend.

These are provided as separate dub configurations:

```
dub -c allegro
dub -c dgame
```

For the allegro version, you must have allegro5 installed on your system.

You should see a window appear rendering a tilemap. Use WASD to scroll around
the map.

Press space to toggle your current 'tool', which is applied by clicking the left
mouse button.

Currently there are two tools:

- enclosure, which demonstrates `enclosedCoords`
  - try clicking inside the building, it should highlight all tiles inside
- flood, which demonstrates `floodFill`
  - clicking on a tile should flood all tiles of the same type with color

You can right-click to clear all highlighting.

# The Map
The map rendered in this demo was created using [Tiled](mapeditor.org).
The `buildMap` function in [tilemap.d](src/tilemap.d) demonstrates how you can
use dtiled to load a json file exported from Tiled.

# Media
The tile sheets used in this example are taken from an old project of mine and
are free to use under [CC0](http://creativecommons.org/publicdomain/zero/1.0/).
They can also be found on
[opengameart](http://opengameart.org/content/rpg-itemterraincharacter-sprites-ice-insignia)

The font used is [Mecha by Captain Falcon](http://www.fontspace.com/captain-falcon/mecha), and is
a Freeware font.
