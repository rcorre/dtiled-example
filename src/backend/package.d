module backend;

public import backend.types;
public import backend.backend;
public import backend.allegro;

Backend getBackend() { return new AllegroBackend(); }
