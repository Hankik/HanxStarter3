class Movement extends Component {
  
  Actor parent;
  Timer moveTime = new Timer(.2);
  PVector moveAmount;
  PVector newLocation;
  boolean isMoving = false;
  
  
  Movement(Actor parent) {
    
    
    this.parent = parent;
    moveAmount = new PVector(0,0);
    moveTime.autoRestart = false;
    moveTime.isDone = true;
    
    moveTime.onTickCallback = () -> { 
      
      PVector tempLocation = PVector.lerp(parent.location, 
                                     newLocation, 
                                     moveTime.elapsed/moveTime.duration); 
      parent.location = new PVector(floor(tempLocation.x), floor(tempLocation.y)); 
      return false; 
    };
    moveTime.onFinishedCallback= () -> {
      isMoving = false;
      return null;
    };
    
  }

  void update(){ 
    
    moveTime.update();
  }
  
  void move(PVector moveAmount) {
    if (moveTime.isDone) moveTime.reset();
    if (isMoving) { return;
    }
    this.moveAmount = moveAmount;
    newLocation = PVector.add(this.parent.location, moveAmount);
    moveTime.reset();
    isMoving = true;
  }
  
  void setMoveTime(float time) {  moveTime.duration = time; }
  
  void display() {}
}
