import java.lang.reflect.*;
import java.util.*;
import java.util.HashSet;
import java.util.Set;
import java.lang.ref.WeakReference;
import java.util.UUID;

// TIMESTEP //
float dt, prevTime = 0.0;
float elapsed = 0.0;
// TIMESTEP

// TILE GLOBALS //
final float GRID_X_OFFSET = 224;
final float TILE_SIZE = 32;
/* Use getGridLocation(PVector) to map items into grid */
// TILE GLOBALS // 

// LEVEL GLOBALS //
ArrayList<Level> levels = new ArrayList();
int currentLevel = 0;
final int UI_SCENE_AMOUNT = 1;
Level[] uiScenes = new Level[UI_SCENE_AMOUNT];
Level hud;
JSONSerializer serializer;
// LEVEL GLOBALS //

// FONT GLOBALS //
PFont maiandra;
// FONT GLOBALS //

HanxStarter3 applet = this; // We need this for the Constructor class method newInstance(applet, ... (other parameters);

boolean paused = false;

void setup() {
  
  maiandra = createFont("Maiandra GD", 48);
  
  surface.setTitle("HanxStarter3");
  surface.setResizable(false);
  size(1280, 720);
  frameRate(60);
  
  hud = createUI(LEVEL_TYPE.HUD);
  
  levels.add( new Level(LEVEL_TYPE.LEVEL) );

  serializer = new JSONSerializer();
  JSONObject json = serializer.getContents(levels.get(0));
  saveJSONObject(json, "data/save.json");
  
  for (Level level : levels) level.handleCommands(); // handle any important commands gathered in deserialization
}

void draw() {
  background(BLACK);
  
 // calculate delta time
  float currTime = millis();
  dt = (currTime - prevTime) / 1000;
  prevTime = currTime;
  
  elapsed += dt;
  hud.update();
  if (!paused) levels.get(currentLevel).update();
  
  levels.get(currentLevel).display();
  hud.display();
}

void mousePressed(){
  hud.mousePressed();
  levels.get(currentLevel).mousePressed();
}

void mouseReleased(){
  hud.mouseReleased();
  levels.get(currentLevel).mouseReleased();
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
  if (key == 'p') paused = !paused;
  if (key == '.') {
    currentLevel++;
    if (currentLevel >= levels.size()) currentLevel = 0;
  }
}
