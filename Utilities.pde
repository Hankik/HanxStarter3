
// IMPORTANT
PVector getGridLocation(PVector location) {
  return new PVector( floor(location.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE/2, 
                      floor(location.y / TILE_SIZE) * TILE_SIZE + TILE_SIZE/2);
}

class Cursor extends Actor {
  
  WeakReference<Actor> heldActor = new WeakReference(null);
  
  void update(){
    location = new PVector(mouseX, mouseY);
  }
  
  void display(){
    noFill();
    stroke(WHITE);
    PVector gridLocation = getGridLocation(location);
    rectMode(CENTER);
    rect(gridLocation.x, gridLocation.y, TILE_SIZE, TILE_SIZE);
  }
}

class Timer extends Component {

  float duration = 1;
  float timeLeft = 1;
  float elapsed = 0;
  boolean isDone = true;
  boolean autoRestart = false;
  boolean paused = false;
  Callback onTickCallback = () -> { return true; };
  Callback onFinishedCallback = () -> {  return true;};
  
  Timer(Actor parent){
  
    
    this.parent = parent;
    timeLeft = duration;
    isDone = false;
  }
  
  Timer(float duration) {
  
    this.duration = duration;
    this.timeLeft = duration;
    isDone = false;
    
  }
  
  void update(){
  
    if (this.paused) return;
    
    
    if (timeLeft <= 0) {
      timeLeft = 0;
      elapsed = duration;
      isDone = true;
      
      onFinishedCallback.call();
      if (autoRestart) reset();
      
    } else {
    
      if (!isDone) {

        
        timeLeft -= dt;
        elapsed += dt;
        
        onTickCallback.call();
      }
    }
  }
  
  void display(){}
  
  void reset(){
    
    timeLeft = duration;
    elapsed = 0;
    isDone = false;
    
  }
  
  void togglePause(){
  
    paused = !paused;
  }
}

class AddActorCommand implements Command {

  Actor actorToAdd = null;
  Level actorLevel = null;
  
  void call(){
    actorLevel.addActor(actorToAdd);
  }
}

class SetFieldReferenceCommand implements Command {
    
    Object referenceHolder = null;
    Field referenceField = null;
    Object referencedObject = null;

    void call(){
      try { referenceField.set(referenceHolder, referencedObject); } 
      catch(Exception e) {println(e);}
      
    }
}

float easeInOutQuad(float x) {
  return x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2;
}

float easeInSine(float x) {
  return 1 - cos((x * PI) / 2);
}

float easeInOut(float t, float b, float c, float d) {
    if (t == 0)
      return b;
    if ((t /= d / 2) == 2)
      return b + c;
    float p = d * (.3f * 1.5f);
    float a = c;
    float s = p / 4;
    if (t < 1)
      return -.5f * (a * (float) Math.pow(2, 10 * (t -= 1)) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p)) + b;
    return a * (float) Math.pow(2, -10 * (t -= 1)) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p) * .5f + c + b;
  }

// color constants
final color RED = #bf616a;
final color ORANGE = #d08770;
final color YELLOW = #ebcb8b;
final color GREEN = #a3be8c;
final color PURPLE = #b48ead;
final color BLUE = #5e81ac;
final color DARKBLUE = #324061;
final color WHITE = #eceff4;
final color BLACK = #3b4252;
final color BROWN = #9e6257;
final color LIGHTGREEN = #d9e68f;
final color PINK = #db96ad;
final color LIGHTBLUE = #92cade;
final color LIGHTRED = #FF8C8C;
