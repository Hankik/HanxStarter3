class Movement extends Component {
  
  Actor parent;
  Timer moveTime = new Timer(1.5);
  PVector moveAmount;
  PVector newLocation;
  boolean isMoving = false;
  
  Movement(Actor parent) {
    name = "movement";
    
    
    this.parent = parent;
    moveAmount = new PVector(0,0);
    moveTime.isDone = true;
    
    moveTime.onTickCallback = () -> { 
      
      parent.location = PVector.lerp(parent.location, 
                                     newLocation, 
                                     moveTime.elapsed/moveTime.duration); 
      return null; 
    };
    moveTime.onFinishedCallback= () -> {
      isMoving = false;
      moveAmount = new PVector(0,0);
      moveTime.reset();
      return null;
    };
  }

  void update(double dt){ 
    
    moveTime.update(dt);
  }
  
  void move(PVector moveAmount) {
    
    if (isMoving) {
      if ((moveTime.elapsed / moveTime.duration) < 0.4) return;
      this.parent.location = newLocation;
      moveTime.onFinishedCallback.call();
    }
    this.moveAmount = moveAmount;
    newLocation = PVector.add(this.parent.location, moveAmount);
    moveTime.reset();
    isMoving = true;
  }
  
  void setMoveTime(float time) {  moveTime.duration = time; }
  
  void display(double alpha) {}
}
