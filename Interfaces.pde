interface Updates {

  abstract void update();
  default void update(Collection<Object> list) {
    for( Object item : list) ((Updates) item).update();
  }
}

interface Displays {
  
  abstract void display();
  default void display(Collection<Object> list) {
    for( Object item : list) ((Displays) item).display();
  }
}

interface Listens {

  abstract void keyPressed();
  abstract void keyReleased();
  abstract void mousePressed();
  abstract void mouseReleased();
}

interface TileHolds {

  default boolean tryPlaceOnTile(Tile t){
  
    if (t.heldItem.get() != null) return false;
    t.heldItem = new WeakReference(this);
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
