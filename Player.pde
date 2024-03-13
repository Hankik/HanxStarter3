class Player extends Actor {
  
  Movement m_Movement = new Movement(this);
  Rect m_Rect;
  
  Player(){ 
    name = "player";
    location = new PVector(0,0);
    m_Rect = new Rect(location.x, location.y, 32, 32);
  }
  
  void update(double dt){
  
    m_Movement.update(dt);
    m_Rect.update(dt);
    
  }
  void display(double alpha){
  
    m_Rect.setPosition(location);
    m_Rect.display(alpha);
  }
} 


class PlayerController {

  Player player = new Player();
  PlayerController(){}
  
  void update(){
  
    if (Keyboard.isDown(Keyboard.LEFT) && !Keyboard.isDown(Keyboard.RIGHT))
      player.m_Movement.move( new PVector(-32, 0)  ); 
    if (!Keyboard.isDown(Keyboard.LEFT) && Keyboard.isDown(Keyboard.RIGHT))
      player.m_Movement.move( new PVector(32, 0) ); 
    if (Keyboard.isDown(Keyboard.UP) && !Keyboard.isDown(Keyboard.DOWN))
      player.m_Movement.move( new PVector(0, -32) );
    if (!Keyboard.isDown(Keyboard.UP) && Keyboard.isDown(Keyboard.DOWN))
      player.m_Movement.move( new PVector(0, 32) ); 
  }
  
  void keyPressed(){
      
  }
  
  void keyReleased(){}
  
  void mousePressed(){}
  
  void mouseReleased(){}
}
