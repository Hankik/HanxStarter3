class Tile extends Actor {

  //Rect hitbox;
  // Weak references do not keep objects alive in memory when all normal (strong) references are gone
  // We use WeakReference<T> so we do not need to make sure every kill method communicates to associated tiles that they need to drop their references.
  WeakReference<TileHolds> heldItem = new WeakReference(null); 
  
  Tile(){
    
    PVector startPosition = getGridLocation( new PVector(GRID_X_OFFSET, 0) );
    location = new PVector(startPosition.x, startPosition.y); // many components require its parent have a location so make sure we instantiate location ahead of time
    //hitbox = (Rect) 
    addComponent("Rect");  // like rect ^^
  }
  
  void update(){
    update(components);
  }
  
  void display(){
    display(components);
  }
}
