class Movement extends Component {
  
  Actor parent;
  Timer moveTime = new Timer(1.5);
  PVector moveAmount;
  PVector newLocation;
  boolean isMoving = false;
  
  
  Movement(Actor parent) {
    
    
    this.parent = parent;
    moveAmount = new PVector(0,0);
    moveTime.isDone = true;
    
    moveTime.onTickCallback = () -> { 
      
      parent.location = PVector.lerp(parent.location, 
                                     newLocation, 
                                     moveTime.elapsed/moveTime.duration); 
      return false; 
    };
    moveTime.onFinishedCallback= () -> {
      isMoving = false;
      moveAmount = new PVector(0,0);
      moveTime.reset();
      return null;
    };
    
  }

  void update(){ 
    
    moveTime.update();
  }
  
  void move(PVector moveAmount) {
    
    if (isMoving) {
      if ((moveTime.elapsed / moveTime.duration) < 0.4) return;  // this weirdness is to allow a fast transition between move actions 
      // essentially if passed 40% of the move, teleport to target location and start next move
      this.parent.location = newLocation;
      moveTime.onFinishedCallback.call();
    }
    this.moveAmount = moveAmount;
    newLocation = PVector.add(this.parent.location, moveAmount);
    moveTime.reset();
    isMoving = true;
  }
  
  void setMoveTime(float time) {  moveTime.duration = time; }
  
  void display() {}
}
