class Player extends Actor implements Listens { // this will not be in the end product
  
  Movement m_Movement;
  Rect m_Rect;
  
  Player(){ 
    
    PVector startPosition = getGridLocation( new PVector(GRID_X_OFFSET, 0) );
    location = new PVector(startPosition.x, startPosition.y);
    m_Movement = (Movement) addComponent("Movement");
    m_Rect = (Rect) addComponent("Rect");
    
  }
  
  void update(){
  
    m_Rect.update();
    update(components);
    
    if (Keyboard.isDown(Keyboard.LEFT) && !Keyboard.isDown(Keyboard.RIGHT))
      m_Movement.move( new PVector(-TILE_SIZE, 0)  ); 
    if (!Keyboard.isDown(Keyboard.LEFT) && Keyboard.isDown(Keyboard.RIGHT))
      m_Movement.move( new PVector(TILE_SIZE, 0) ); 
    if (Keyboard.isDown(Keyboard.UP) && !Keyboard.isDown(Keyboard.DOWN))
      m_Movement.move( new PVector(0, -TILE_SIZE) );
    if (!Keyboard.isDown(Keyboard.UP) && Keyboard.isDown(Keyboard.DOWN))
      m_Movement.move( new PVector(0, TILE_SIZE) ); 
    
    
  }
  void display(){
  
    display(components);
  }
  
  void keyPressed(){}
  
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
