enum LEVEL_TYPE {
  LEVEL,
    PAUSE_MENU,
    MAIN_MENU,
    HUD,
    EMPTY,
}

class Scene implements Updates, Displays, Listens {

  ArrayList<Object> actors = new ArrayList(); // do not add non-actor types
  ArrayList<Command> commands = new ArrayList();
  LEVEL_TYPE type = LEVEL_TYPE.LEVEL;

  // CONSTRUCTOR
  Scene(LEVEL_TYPE type) {
    this.type = type;
    if (type == LEVEL_TYPE.EMPTY) return;
    if (type != LEVEL_TYPE.LEVEL) {
      println("\nCreated ui scene " + cleanName(this.toString()));
      return;
    } else println("\nCreated level " + cleanName(this.toString()));
    
    addActor("TileMap");
    addActor("Player");
    
    
  }

  void update() {
    updateActors();
    handleCommands();
    cullDeadActors();
  }

  void updateActors() {

    for (Object a : actors) {
      Actor actor = (Actor) a;
      if (actor.actorState.equals(ACTOR_STATE.AWAKE)) actor.update();
    }
  }

  void handleCommands() {
    for (int i = commands.size() - 1; i >= 0; i--) {
      commands.get(i).call();
      commands.remove(i);
    }
  }

  void cullDeadActors() {

    for (int i = actors.size() - 1; i >= 0; i--) {
      Actor a = (Actor) actors.get(i);
      if (a.actorState.equals(ACTOR_STATE.DEAD)) actors.remove(i);
    }
  }

  void display() {
    for (Object a : actors) {
      Actor actor = (Actor) a;
      if (actor.actorState.equals(ACTOR_STATE.AWAKE)) actor.display();
    }
  }

  void keyPressed() {
    
    for (Object a : actors) if (a instanceof Listens) ((Listens)a).keyPressed();
    if (key == 'x' && type == LEVEL_TYPE.LEVEL) { 
      Tile tile = ((TileMap) getActor("TileMap")).getTileAtLocation(cursor.location);
      if (tile == null) return;
      if (tile.heldItems.size() <= 0) return;
      Actor a = tile.heldItems.get(0).get();
      a.actorState = ACTOR_STATE.DEAD;
      tile.heldItems.get(0).clear();
    }
    if (type == LEVEL_TYPE.LEVEL) {
      
      
      TileMap tmap = (TileMap) getActor("TileMap");
      if (key == '=') {
        Tile t = tmap.getTileAtLocation(new PVector(mouseX, mouseY));
        if (t == null) return;
        t.cost++;
        if (t.cost > 10) t.cost = 10;
      }
      if (key == '-') {
        Tile t = ((TileMap) getActor("TileMap")).getTileAtLocation(new PVector(mouseX, mouseY));
        if (t == null) return;
        t.cost--;
        if (t.cost < 1) t.cost = 1;
      }
    }
  }

  void keyReleased() {
    for (Object a : actors) if (a instanceof Listens) ((Listens)a).keyReleased();
    
  }

  void mousePressed() {
    for (Object a : actors) if (a instanceof Listens) ((Listens)a).mousePressed();
  }

  void mouseReleased() {
    for (Object a : actors) if (a instanceof Listens) ((Listens)a).mouseReleased();
  }

  Actor addActor(Actor actor) {
    if (actor != null) {

      actors.add(actor);
      println(cleanName(actor.toString()) + " actor added to " + cleanName(this.toString()) + "... ");
    }
    return actor;
  }

  Actor addActor(String name) {
    Actor actor = createActor(name);
    if (actor != null) {
      actors.add(actor);
      println(cleanName(actor.toString()) + " actor added to " + cleanName(this.toString()));
    }
    return actor;
  }
  
  void toggleActors(){
    for (Object a : actors) {
      Actor actor = (Actor) a;
      if (actor.actorState == ACTOR_STATE.AWAKE) actor.actorState = ACTOR_STATE.ASLEEP;
      else if (actor.actorState == ACTOR_STATE.ASLEEP) actor.actorState = ACTOR_STATE.AWAKE;
    }
  }
  
  void sortActors(){
  
    Collections.sort(actors, new Comparator<Object>() {
      @Override
      int compare(Object a1, Object a2) { 
        return Integer.compare(((Actor)a1).layer, ((Actor)a2).layer); }
      }
    );
  }
  
  
  ArrayList<Actor> getActors(String name) {
    ArrayList<Actor> foundActors = new ArrayList();
    Class type;
    try { type = Class.forName("HanxStarter3$" + name); }
    catch(Exception e) {println ("getActors() failed: '" + name + "' actor type does not exist."); return foundActors; }
    for (Object a : actors) if (type == a.getClass()) foundActors.add((Actor) a);
    return foundActors;
  }
  
  Actor getActor(String name) {
    Class type;
    try { type = Class.forName("HanxStarter3$" + name); }
    catch(Exception e) {println ("getActor() failed: '" + name + "' actor type does not exist."); return null; }
    for (Object a : actors) if (type == a.getClass()) {
      return (Actor) a;
    }
    return null;
  }
}
