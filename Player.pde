class Player extends Actor implements Listens, Draggable, TileHolds { // player will not be in the end product
  
  Movement movement;
  Rect rect;
  ArrayList<Tile> path = new ArrayList();
  int currentPathTile = 0;
  
  Player(){ 
    
    PVector startPosition = getGridLocation( new PVector(GRID_X_OFFSET, 0) );
    location = new PVector(startPosition.x, startPosition.y);
    movement = (Movement) addComponent("Movement");
    rect = (Rect) addComponent("Rect");
    rect.fillOpacity = 0;
    rect.stroke = WHITE;
    rect.strokeOpacity = 1;
    layer = 2;
    
  }
  
  void update(){
  
    rect.update();
    update(components);
    
    if (currentPathTile < path.size()) {
    
      PVector moveAmount = PVector.sub(path.get(currentPathTile).location, location);
      movement.move(moveAmount);
      if (abs(moveAmount.mag()) < 0.01) currentPathTile++;
      
    }
    
    
  }
  void display(){
  
    display(components);
    for (int i = currentPathTile-1; i < path.size()-1; i++) {
        PVector start = i == currentPathTile-1 ? location : path.get(i).location;
        PVector end = path.get(i+1).location;
        stroke(LIGHTBLUE);
        strokeWeight(4);
        line(start.x, start.y, end.x, end.y);
    }
    PVector end = path.size() > 0 ? path.get(path.size()-1).location : null;
    if (end != null && currentPathTile < path.size()) rect(end.x, end.y, TILE_SIZE/2, TILE_SIZE/2, 4);
    
    strokeWeight(1);
  }
  
  void keyPressed(){
  
    if (key == ENTER) {
      
      currentPathTile = 0;
      TileMap tmap = (TileMap) levels.get(currentLevel).getActor("TileMap");
      if (!tmap.rect.checkCollidingWithPoint(cursor.location)) return;
      Tile startTile = tmap.getTileAtLocation(location);
      Tile goalTile = tmap.getTileAtLocation(cursor.location);
      if (startTile == null || goalTile == null) return;
      path = findPath(startTile, goalTile);
      if (path == null) path = new ArrayList();
    }
  }
  
  void keyReleased(){}
  
  void mousePressed(){}
  
  void mouseReleased(){}
} 


class PlayerController { // maybe make a global thing

  PlayerController(){}
  
  void update(){
  }
  
  void keyPressed(){}
  
  void keyReleased(){}
  
  void mousePressed(){}
  
  void mouseReleased(){}
}
