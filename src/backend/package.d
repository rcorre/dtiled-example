module backend;

public import backend.types;
public import backend.backend;

version (AllegroBackend) {
  public import backend.allegro;
  Backend getBackend() { return new AllegroBackend(); }
}
version (DGameBackend) {
  public import backend.dgame;
  Backend getBackend() { return new DGameBackend(); }
}
