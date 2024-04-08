interface Updates {

  abstract void update();
  default void update(Collection<Object> list) {
    for ( Object item : list) ((Updates) item).update();
  }
}

interface Displays {

  abstract void display();
  default void display(Collection<Object> list) {
    for ( Object item : list) ((Displays) item).display();
  }
}

interface Listens {

  abstract void keyPressed();
  abstract void keyReleased();
  abstract void mousePressed();
  abstract void mouseReleased();
}

interface Draggable {
} // only works on actors stored in scene instance actor list (at the moment)

interface TileHolds {

  default boolean tryPlaceOnTile(Tile t) {

    if (t == null) {
      println("\nTried to place outside tilemap limits");
      return false;
    }
    for (WeakReference<Actor> weakActorRef : t.heldItems) if (weakActorRef.get() instanceof Actor) return false;
    t.heldItems.add(new WeakReference<Actor>((Actor) this));
    if (this instanceof Actor) ((Actor)this).location = new PVector(t.location.x, t.location.y);
    return true;
  }
}

@FunctionalInterface
  interface Callback<T> {

  abstract T call();
}

interface Command {

  abstract void call();
}
