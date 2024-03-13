class Level implements Updates, Displays {
  
  PlayerController controller = new PlayerController();
  Timer test = new Timer(1);

  Level(){
    
    test.autoRestart = true;
  }
  
  void update(double dt){
    controller.update();
    controller.player.update(dt);
    test.update(dt);
  }
  
  void display(double alpha){
  
    controller.player.display(alpha);
  }
  
  void keyPressed(){
    controller.keyPressed();
  }
  
  void keyReleased(){
    controller.keyReleased();
  }
  
  void mousePressed(){
    controller.mousePressed();  
  }
  
  void mouseReleased(){
    controller.mouseReleased();
  }
}
