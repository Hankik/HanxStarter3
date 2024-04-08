import java.lang.reflect.*;
import java.util.*;
import java.util.HashSet;
import java.util.Set;
import java.lang.ref.WeakReference;
import java.util.UUID;
import java.util.PriorityQueue;

// TIMESTEP //
float dt, prevTime = 0.0;
float elapsed = 0.0;
// TIMESTEP

// TILE GLOBALS //
final float TILE_SIZE = 32;
final float GRID_X_OFFSET = TILE_SIZE * 8;
/* Use getGridLocation(PVector) to map items into grid */
// TILE GLOBALS // 

// LEVEL GLOBALS //
ArrayList<Scene> levels = new ArrayList();
int currentLevel = 0;
// LEVEL GLOBALS //

// UI GLOBALS //
Scene hud;
Cursor cursor;
// UI GLOBALS // 

JSONSerializer serializer;


// FONT GLOBALS //
PFont font;
// FONT GLOBALS //

HanxStarter3 applet = this; // We need this for the Constructor class method newInstance(applet, ... (other parameters);

boolean paused = false;

void setup() {
  
  
  font = createFont("Microsoft PhagsPa", 48);
  textFont(font);
  
  serializer = new JSONSerializer();
  surface.setTitle("HanxStarter3");
  surface.setResizable(false);
  size(1280, 740);
  //fullScreen();
  frameRate(144);
  
  hud = createUI(LEVEL_TYPE.HUD);
  cursor = new Cursor();
  levels.add( createUI( LEVEL_TYPE.MAIN_MENU) );
  levels.add( new Scene( LEVEL_TYPE.LEVEL) );
  //levels.get(1).sortActors(); // SORTING WORKS!!! :)))
  
  for (Scene level : levels) level.handleCommands(); // handle any important commands gathered in deserialization
  
}

void draw() {
  background(RED);
  translate(0,2);
  
 // calculate delta time
  float currTime = millis();
  dt = (currTime - prevTime) / 1000;
  prevTime = currTime;
  
  elapsed += dt;
  
  cursor.update();
  hud.update();
  if (!paused) levels.get(currentLevel).update();
  
  levels.get(currentLevel).display();
  hud.display();
  cursor.display();
}

void mouseWheel(MouseEvent event){
  LevelEditor editor = (LevelEditor) hud.getActor("LevelEditor");
  editor.animationTime.reset();
  editor.highlightTime.reset();
  editor.prevSelection = editor.currentSelection;
  editor.currentSelection += event.getCount();
  
  if (editor.currentSelection < 0) editor.currentSelection = editor.actorOptions.length-1;
  else if (editor.currentSelection > editor.actorOptions.length-1) editor.currentSelection = 0;
}

void mousePressed(){
  hud.mousePressed();
  levels.get(currentLevel).mousePressed();
  cursor.mousePressed();
}

void mouseReleased(){
  hud.mouseReleased();
  levels.get(currentLevel).mouseReleased();
  cursor.mouseReleased();
}

void keyPressed(){
  Keyboard.handleKeyDown(keyCode);
  hud.keyPressed();
  levels.get(currentLevel).keyPressed();
}


void keyReleased(){
  Keyboard.handleKeyUp(keyCode);
  hud.keyReleased();
  levels.get(currentLevel).keyReleased();
  // LMAO DONT LOOK
  if (key == 'p') for (Object a : hud.getActors("Button")) if (((Button)a).text == "| |") ((Button)a).purposeCallback.call();
  if (key == '.') {
    currentLevel++;
    background(RED);
    if (currentLevel >= levels.size()) currentLevel = 0;
  }
}
