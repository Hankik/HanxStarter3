
// IMPORTANT
PVector getGridLocation(PVector location) {
  return new PVector( floor(location.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE/2,
    floor(location.y / TILE_SIZE) * TILE_SIZE + TILE_SIZE/2);
}

class Cursor extends Actor {

  WeakReference<Actor> heldActor = new WeakReference(null);
  Callback inputCallback = null;
  Rect rect = (Rect) addComponent("Rect");
  PVector heldActorReturnLocation = null;
  
  // draw variables
  color stroke = RED;
  float defaultSize = TILE_SIZE - 6;
  float currentSize = TILE_SIZE;
  float changeInSize = 0;
  float changeInRotation = 0;
  
  // dangerous reference to tilemap (ugly gross) if anything is weird with cursor it could be this
  // it will only ever reference the tilemap in level.get(first level)
  TileMap tilemap = null;

  void update() {
    update(components);
    
    location = new PVector(mouseX, mouseY);
    PVector gridLocation = getGridLocation(location);
    if (heldActor.get() != null) heldActor.get().location = gridLocation;
    
    
    
  }

  void display() {
    if (paused) {
      heldActor = new WeakReference(null);
      return;
    }
    noFill();
    stroke(stroke);
    PVector gridLocation = getGridLocation(location);
    rectMode(CENTER);
    
    // affects cursor shape 
    currentSize = mousePressed ?  (inputCallback == null ? defaultSize - TILE_SIZE / 2 : TILE_SIZE/6): defaultSize;
    float targetChangeInSize =  mousePressed ? -currentSize + 1 : 0; // depending on if mousepressed, gets target cursor size
    changeInSize += (targetChangeInSize - changeInSize) * 8 * dt; // an easing value to animate between two states
    
    
    float targetRotation = mousePressed ? PI / (inputCallback == null ? 4 : 2) : 0; // same idea but rotation
    changeInRotation += (targetRotation - changeInRotation) * 16 * dt;
    if (abs(changeInRotation - targetRotation) < PI/1024) changeInRotation = targetRotation; // prevents awkward easing -> snaps back to default state when difference is below a threshold
    
    pushMatrix();
    translate(gridLocation.x, gridLocation.y); // if we dont translate to this position it rotates around the window's (0,0)
    rotate(changeInRotation);
    
    rect(0, 0, currentSize, currentSize + changeInSize, 6); // draws square usually but becomes horizontal bar
    if (mousePressed) rect(0, 0, currentSize + changeInSize, currentSize, 6); // draws a cross shape if mousePressed -> this is the vertical bar
    popMatrix();
    
    pushMatrix();
    translate(rect.x, rect.y);
    for (Object a : levels.get(currentLevel).actors) if (rect.checkCollidingWithPoint(((Actor)a).location)) {
      stroke(RED);
      fill(0, .35 * 255);
      rect(TILE_SIZE*2 + 4, 0, TILE_SIZE*2, TILE_SIZE*2);
      fill(WHITE);
      Actor actor = (Actor) a;
      textSize(12);
      text(actor.getClass().getSimpleName(), TILE_SIZE * 2 + 4, -TILE_SIZE + TILE_SIZE/4);
      fill(GREEN);
      textSize(10);
      for (int i = 0; i < actor.components.size(); i++) {
        Component c = (Component) actor.components.get(i);
        text(c.getClass().getSimpleName(), TILE_SIZE*2 + 4, -TILE_SIZE/3 + i * 12);
      }
      //text("components: " + actor.components.size(), TILE_SIZE*2 + 4, 0);
    }
    popMatrix();
    
  }
  
  void mousePressed(){
    if (paused || inputCallback != null) return;
    for (Object a : levels.get(currentLevel).actors) if (a instanceof Draggable) if (rect.checkCollidingWithPoint(((Actor)a).location) ) {
      heldActor = new WeakReference(a);
      if (inputCallback == null) heldActorReturnLocation = new PVector(heldActor.get().location.x, heldActor.get().location.y);
      inputCallback = () -> { return false; };
    } 
  }
  
  void mouseReleased(){ 
    if (heldActor.get() instanceof TileHolds) {
      Tile attemptedTile = ((TileMap)levels.get(currentLevel).getActor("TileMap")).getTileAtLocation( heldActor.get().location );
      boolean success = ((TileHolds)heldActor.get()).tryPlaceOnTile(attemptedTile);
      if (success) {
        
        println("\nActor moved from " + heldActorReturnLocation + " to new Tile at " + attemptedTile.location);
        Tile oldTile = ((TileMap)levels.get(currentLevel).getActor("TileMap")).getTileAtLocation( heldActorReturnLocation );
        for (int i = oldTile.heldItems.size() - 1; i >= 0; i--) if( oldTile.heldItems.get(i).get() instanceof Player) oldTile.heldItems.get(i).clear(); 
      }
      else heldActor.get().location = heldActorReturnLocation;
    } 
    heldActor = new WeakReference(null);
    heldActorReturnLocation = null;
    if (inputCallback == null) return;
    
    inputCallback.call();
    inputCallback = null;
  }
}

class Timer extends Component {

  float duration = 1;
  float timeLeft = 1;
  float elapsed = 0;
  boolean isDone = true;
  boolean autoRestart = false;
  boolean paused = false;
  Callback onTickCallback = () -> {
    return true;
  };
  Callback onFinishedCallback = () -> {
    return true;
  };

  Timer(Actor parent) {


    this.parent = parent;
    timeLeft = duration;
    isDone = false;
  }

  Timer(float duration) {

    this.duration = duration;
    this.timeLeft = duration;
    isDone = false;
  }

  void update() {

    if (this.paused) return;


    if (timeLeft <= 0) {
      timeLeft = 0;
      if (!isDone) onTickCallback.call();
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

  void display() {
  }

  void reset() {

    timeLeft = duration;
    elapsed = 0;
    isDone = false;
  }

  void togglePause() {

    paused = !paused;
  }
}

class ImplementObjectByIDCommand implements Command {

  Object holdingObject = null;
  Field holdingField = null;
  String idToFind = null;

  void call(){
    for (Scene level : levels) {

      for (Object a : level.actors) {
        Actor levelActor = (Actor) a;
        for (Object c : levelActor.components) if (((Component) c).id.equals(idToFind)) {
          SetFieldReferenceCommand setReference = new SetFieldReferenceCommand();
          setReference.referenceHolder = holdingObject;
          setReference.referenceField = holdingField;
          setReference.referencedObject = c;
          level.commands.add( setReference );
          return;
        }

        if ( levelActor.id.equals(idToFind) ) { // ugly as sin
          SetFieldReferenceCommand setReference = new SetFieldReferenceCommand();
          setReference.referenceHolder = holdingObject;
          setReference.referenceField = holdingField;
          setReference.referencedObject = levelActor;
          level.commands.add( setReference );
          return;
        }
      }
    }
  }
}

class InsertActorByIDCommand implements Command {

  ArrayList<Object> list = null;
  String id = null;
  boolean isWeakReference = false;
  
  void call() {
    for (Scene level : levels) {

      for (Object a : level.actors) {
        Actor levelActor = (Actor) a;
        for (Object c : levelActor.components) if (((Component) c).id.equals(id)) {
          if (isWeakReference) {
            list.add( new WeakReference(c));
            return;
          }
          else 
            list.add(levelActor);
          return;
        }
      
        if ( levelActor.id.equals(id) ) { // ugly as sin
          if (isWeakReference) {
           list.add( new WeakReference(levelActor));
           return;
          }
          else 
            list.add(levelActor);
          return;
        }
      }
    }
  }
  
}



class AddActorCommand implements Command {

  Actor actorToAdd = null;
  Scene actorLevel = null;

  void call() {
    actorLevel.addActor(actorToAdd);
  }
}

class SetFieldReferenceCommand implements Command {

  Object referenceHolder = null;
  Field referenceField = null;
  Object referencedObject = null;

  void call() {
    try {
      if (referenceField.get(referenceHolder) instanceof WeakReference) {
        referenceField.set(referenceHolder, new WeakReference(referencedObject));
        return;
      }
      referenceField.set(referenceHolder, referencedObject);
    }
    catch(Exception e) {
      println(e);
    }
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

public static float clamp(float val, float min, float max) {
  return Math.max(min, Math.min(max, val));
}

// color constants
final color RED = #bf616a;
final color ORANGE = #d08770;
final color YELLOW = #ebcb8b;
final color GREEN = #a3be8c;
final color PURPLE = #b48ead;//TREV - A355A5 RECCOMEND
final color DARKPURPLE = #A355A5; //TREV - 7555A5 RECCOMEND
final color BLUE = #5e81ac;
final color DARKBLUE = #324061;
final color WHITE = #eceff4;
final color BLACK = #3b4252;
final color BROWN = #9e6257;
final color LIGHTGREEN = #d9e68f;
final color PINK = #db96ad;
final color LIGHTBLUE = #92cade;
final color LIGHTRED = #FF8C8C;
