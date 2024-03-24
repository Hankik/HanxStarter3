Level createUI(LEVEL_TYPE type) {

  Level level = new Level(type);

  switch (type) {
    // add specific actors for each menu

  case PAUSE_MENU:
    break;

  case MAIN_MENU:
    break;

  case HUD:
    level.addActor("Cursor");
    level.addActor("HUDOverlay");
    Button addNewButtonButton = (Button) level.addActor("Button");
    addNewButtonButton.text = "+";
    addNewButtonButton.purposeCallback = () -> { 
      println();
      Button newButton = (Button) createActor("Button");
      newButton.location = getGridLocation(new PVector(
                                              random(GRID_X_OFFSET, width - GRID_X_OFFSET), 
                                              random(0, height)));
      newButton.text = "-";
      newButton.purposeCallback = () -> { newButton.actorState = ACTOR_STATE.DEAD;  return true; };
      // adding actors during update requires using this command
      // otherwise, you can add actors while game is paused
      AddActorCommand addActorCommand = new AddActorCommand();
      addActorCommand.actorToAdd = newButton;
      addActorCommand.actorLevel = levels.get(currentLevel);
      level.commands.add( addActorCommand ); 
      return true;
    };        
    Button hidePlayerButton = (Button) level.addActor("Button");
    hidePlayerButton.text = "zZz";
    hidePlayerButton.location = getGridLocation( new PVector( width/2, height/2 + TILE_SIZE) );
    hidePlayerButton.purposeCallback = () -> { 
      for (Object a : levels.get(currentLevel).actors) 
        if (a instanceof Player) {
          Player p = (Player) a;
          p.actorState = (p.actorState.equals(ACTOR_STATE.AWAKE) ? ACTOR_STATE.ASLEEP : ACTOR_STATE.AWAKE);
          println("\ntoggling player awake");
        } 
      return true; };
    Button saveToJSONButton = (Button) level.addActor("Button");
    saveToJSONButton.text = "save";
    saveToJSONButton.location = getGridLocation( new PVector( TILE_SIZE, height/2) );
    saveToJSONButton.purposeCallback = () -> {
    
      println("\nSaved current level to save2");
      JSONObject json = serializer.getContents(levels.get(currentLevel));
      saveJSONObject(json, "data/save2.json");
      return false;
    };
    Button loadFromJSONButton = (Button) level.addActor("Button");
    loadFromJSONButton.text = "load";
    loadFromJSONButton.location = getGridLocation( new PVector( TILE_SIZE, height/2 + TILE_SIZE * 2) );
    loadFromJSONButton.purposeCallback = () -> {
    
      JSONObject json = loadJSONObject("data/save2.json");
      Level deserializable = createLevel(json);
      levels.add(deserializable);
      deserializable.handleCommands();
      return false;
    };

    break;
  case LEVEL:
    println("LMAO. This is for making UI not levels. Go use Level constructor.");
    break;
  }

  return level;
}

class HUDOverlay extends Actor {
  
  color fill = PINK;

  void update(){}
  
  void display(){
    rectMode(CORNER);
    fill(fill);
    noStroke();
    rect(0, 0, GRID_X_OFFSET, height); 
    rect(width - GRID_X_OFFSET, 0, GRID_X_OFFSET, height);
    
    fill(WHITE);
    textAlign(RIGHT);
    text((paused ? "paused" : ""), width - GRID_X_OFFSET - TILE_SIZE, height - TILE_SIZE);
    textAlign(LEFT);
    text("level: " + currentLevel, GRID_X_OFFSET + TILE_SIZE, height - TILE_SIZE);
  }
}
