enum LEVEL_TYPE {
  LEVEL,
  PAUSE_MENU,
  MAIN_MENU,
  HUD,
}

class Level implements Updates, Displays, Listens {

  ArrayList<Object> actors = new ArrayList(); // do not add non-actor types
  ArrayList<Command> commands = new ArrayList();
  LEVEL_TYPE type = LEVEL_TYPE.LEVEL;

  // CONSTRUCTOR
  Level(LEVEL_TYPE type) {
    this.type = type;
    if (type != LEVEL_TYPE.LEVEL) { println("\nCreated ui scene " + cleanName(this.toString())); return; }
    else println("\nCreated level " + cleanName(this.toString()));

    Tile t = (Tile) addActor("Tile");
    Player player = (Player) addActor("Player");
    t.heldItem = new WeakReference(player);
  }

  void update() {
    updateActors();
    handleCommands();
    cullDeadActors();
  }
  
  void updateActors(){
  
    for (Object a : actors) {
      Actor actor = (Actor) a;
      if (actor.actorState.equals(ACTOR_STATE.AWAKE)) actor.update();
    }
  }
  
  void handleCommands(){
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

  Actor addActor(Actor actor){
    if (actor != null)  {
    
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
}
