#!/bin/sh

tiled -v foo >/dev/null 2>&1 || { echo >&2 "Failed to execute tiled. Is it installed?"; exit 1; }
tiled --export-map "./resources/map1.tmx" "./content/map1.json"
