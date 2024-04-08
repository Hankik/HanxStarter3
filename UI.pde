Scene createUI(LEVEL_TYPE type) {

  Scene level = new Scene(type);

  switch (type) {
    // add specific actors for each menu

  case PAUSE_MENU:
    break;

  case MAIN_MENU:
    Button startButton = (Button) level.addActor("Button");
    startButton.rect.setSize(TILE_SIZE * 3, TILE_SIZE);
    startButton.text = "START";
    startButton.location = getGridLocation( new PVector(width/2, height/2) );
    startButton.purposeCallback = () -> { currentLevel++; hud.toggleActors();  return true; };
    hud.toggleActors();
    
    
    break;

  case HUD:
    level.addActor("HUDOverlay");
    Button addNewButtonButton = (Button) level.addActor("Button");
    addNewButtonButton.location = getGridLocation( new PVector( width - GRID_X_OFFSET/2, height/2));
    addNewButtonButton.text = "+";
    addNewButtonButton.purposeCallback = () -> {
      println();
      Button newButton = (Button) createActor("Button");
      newButton.location = getGridLocation(new PVector(
        random(GRID_X_OFFSET, width - GRID_X_OFFSET),
        random(0, height)));
      newButton.text = "-";
      newButton.purposeCallback = () -> {
        newButton.actorState = ACTOR_STATE.DEAD;
        return true;
      };

      levels.get(currentLevel).addActor(newButton);

      return true;
    };
    Button hidePlayerButton = (Button) level.addActor("Button");
    hidePlayerButton.text = "zZz";
    hidePlayerButton.location = getGridLocation( new PVector( width - GRID_X_OFFSET/2, height/2 - TILE_SIZE) );
    hidePlayerButton.purposeCallback = () -> {
      for (Object a : levels.get(currentLevel).actors)
        if (a instanceof Player) {
          Player p = (Player) a;
          p.actorState = (p.actorState.equals(ACTOR_STATE.AWAKE) ? ACTOR_STATE.ASLEEP : ACTOR_STATE.AWAKE);
          println("\ntoggling player awake");
        }
      return true;
    };
    Button saveToJSONButton = (Button) level.addActor("Button");
    saveToJSONButton.text = "save";
    saveToJSONButton.location = getGridLocation( new PVector( TILE_SIZE, height/2) );
    saveToJSONButton.purposeCallback = () -> {

      selectOutput("Select a file to write to:", "saveToJSON");
      return false;
    };
    Button loadFromJSONButton = (Button) level.addActor("Button");
    loadFromJSONButton.text = "load";
    loadFromJSONButton.location = getGridLocation( new PVector( TILE_SIZE, height/2 + TILE_SIZE * 2) );
    loadFromJSONButton.purposeCallback = () -> {

      JSONObject json = loadJSONObject("data/save2.json");
      Scene deserializable = createLevel(json);
      levels.add(deserializable);
      deserializable.handleCommands();
      deserializable.sortActors();
      deserializable = null;
  
      return false;
    };
    level.addActor("PauseOverlay");
    
    Button pauseButton = (Button) level.addActor("Button");
    pauseButton.location = getGridLocation( new PVector(TILE_SIZE, TILE_SIZE) );
    pauseButton.text = "| |";
    pauseButton.purposeCallback = () -> {
      
      PauseOverlay pauseMenu = (PauseOverlay) hud.getActor("PauseOverlay");
      pauseMenu.open = !pauseMenu.open;
      paused = !paused;
      return true;
    };
    
    LevelEditor editor = (LevelEditor) level.addActor("LevelEditor");
    editor.location = new PVector(GRID_X_OFFSET - TILE_SIZE*3, height/2);

    
    break;
  case LEVEL:
    println("LMAO. This is for making UI not levels. Go use Level constructor.");
    break;
  }
  level.update();

  return level;
}

class HUDOverlay extends Actor {

  color fill = RED;

  void update() {
  }

  void display() {
    rectMode(CORNER);
    fill(fill);
    noStroke();
    rect(0, 0, GRID_X_OFFSET, height, 6);
    rect(width - GRID_X_OFFSET + 1, 0, GRID_X_OFFSET, height, 6);

    textSize(TILE_SIZE/2);
    fill(0);
    textAlign(LEFT);
    text("actor count: " + levels.get(currentLevel).actors.size(), width - TILE_SIZE * 4, height - TILE_SIZE);
    text((paused ? "paused" : ""), width - TILE_SIZE, height - TILE_SIZE);
    text("[ENTER]: PLAYERS MOVE\n[.]: NEXT LEVEL\n[P]: PAUSE\n[SPACE]: PLACE ACTOR\n[X]: DELETE", width - GRID_X_OFFSET + TILE_SIZE, TILE_SIZE, GRID_X_OFFSET - TILE_SIZE*2, TILE_SIZE*4 );
    textAlign(LEFT);
    text("level: " + currentLevel, TILE_SIZE, height - TILE_SIZE);
    PVector mouseGridLocation = getGridLocation(new PVector(mouseX, mouseY));
    text("[x: " + (int) mouseGridLocation.x + ", y: " + (int) mouseGridLocation.y + "]", TILE_SIZE*3, height - TILE_SIZE);
  }
}

class PauseOverlay extends Actor implements Listens {

  Button resumeGame = new Button();
  Button returnToMain = new Button();
  Button exitGame = new Button();
  boolean open = true;
  
  PauseOverlay(){
    
    resumeGame.rect.setSize(TILE_SIZE*3, TILE_SIZE);
    resumeGame.location = new PVector(width/2, height/2 - TILE_SIZE/2);
    resumeGame.text = "RESUME";
    resumeGame.purposeCallback = () -> { open = false; paused = false; return true; }; 
  
    returnToMain.rect.setSize(TILE_SIZE*3, TILE_SIZE);
    returnToMain.location = new PVector(width/2, height/2 + TILE_SIZE/2);
    returnToMain.text = "MENU";
    returnToMain.purposeCallback = () -> { currentLevel = 0; paused = false; open = false; hud.toggleActors(); return true; };
    
    exitGame.rect.setSize(TILE_SIZE*3, TILE_SIZE);
    exitGame.location = new PVector(width/2, height/2 + TILE_SIZE* 1.5);
    exitGame.text = "EXIT";
    exitGame.purposeCallback = () -> { exit(); return true; };
    
    update();
    paused = false;
    
    open = false;
  }

  void update(){
    if (!open) return;
    paused = true;
    resumeGame.update();
    returnToMain.update();
    exitGame.update();
  }
  
  void display(){
    if (!open) return;
    fill(WHITE, .35*255);
    rect(width/2, height/2, TILE_SIZE * 5, TILE_SIZE * 5, 8);
    fill(0);
    textSize(22);
    text("PAUSED", width/2, height/2 - TILE_SIZE * 1.666);
    resumeGame.display();
    returnToMain.display();
    exitGame.display();
  }
  
  void keyPressed(){}
  
  void keyReleased(){}
  
  void mousePressed(){
    resumeGame.mousePressed();
    returnToMain.mousePressed();
    exitGame.mousePressed();
  }
  
  void mouseReleased(){
    resumeGame.mouseReleased();
    returnToMain.mouseReleased();
    exitGame.mouseReleased();
  }
}
