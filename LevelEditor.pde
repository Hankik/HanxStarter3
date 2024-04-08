class LevelEditor extends Actor implements Listens {
  
  // Each placeable actor needs to be added here (CASE SENSITIVE)
  String[] actorOptions = {"Player", "Button", "DJ", "Player", "Button", "DJ","Player", "Button", "DJ", "ATypeWithAnAbsurdlyLongName",
"Player", "Button", "DJ","Player", "Button", "DJ", "ATypeWithAnAbsurdlyLongName"};
  int currentSelection = 0;
  int prevSelection = 0;
  Timer animationTime = new Timer(.12);
  Timer highlightTime = new Timer(.25);
  
  LevelEditor(){
  }

  void update(){
    animationTime.update();
    highlightTime.update();
  }
  void display(){
    
    
    
  
    // draw selection wheel
    pushMatrix();
    translate(location.x, location.y);
    
    fill(0, .75*255); // 75% opacity black
    stroke(0);
    rect(0,0, TILE_SIZE*2+2, TILE_SIZE*(actorOptions.length/2.25) - TILE_SIZE/5, 8); // scrollbar background
    
    for (int i = 0; i < actorOptions.length; i++) {
      
      float differenceMultiplier = 3.5;
      float prevDifference = abs(i - prevSelection);
      float newDifference = abs(i - currentSelection);
      float difference = lerp( prevDifference, newDifference, animationTime.elapsed / animationTime.duration);
      
      float prevYLocation = (i - prevSelection) * TILE_SIZE;
      float newYLocation = (i - currentSelection) * TILE_SIZE;
      float yLocation = lerp(prevYLocation , newYLocation , animationTime.elapsed / animationTime.duration);
      
      pushMatrix(); // otherwise all the downscalings add together
      
      float uniformFraction = 1 / (float) actorOptions.length;
      float numberOfFractions = actorOptions.length - (difference * differenceMultiplier/3);
      scale(uniformFraction * numberOfFractions); // this is odd but it works for scaling down items
      
      float uniformOpacityFraction = 255 / actorOptions.length;
      float numberOfOpacityFractions = actorOptions.length - difference * differenceMultiplier;
      
      fill(LIGHTRED,  uniformOpacityFraction * numberOfOpacityFractions );
      noStroke();
      rect(0, yLocation, TILE_SIZE*2, TILE_SIZE, 6);
      
      fill(0,  uniformOpacityFraction * numberOfOpacityFractions);
      if (i != currentSelection) textSize(12);// + 4 * (highlightTime.elapsed / highlightTime.duration));
      else textSize(12 + 4 * (highlightTime.elapsed / highlightTime.duration));
      clip(-TILE_SIZE + 3, yLocation - TILE_SIZE/2, TILE_SIZE*2 - 3, TILE_SIZE);
      text(actorOptions[i].toUpperCase(), 0, yLocation);
      noClip();
      
      popMatrix(); // throw away scaling
    }
    stroke(LIGHTRED);
    noFill();
    //strokeWeight(12 * (highlightTime.elapsed / highlightTime.duration));
    if (animationTime.isDone) { 
      
      float bonus = 0;
      if (actorOptions[currentSelection].length() >= 8) bonus = (actorOptions[currentSelection].length() - 8) * 10 + 20;
      
      // shadow 
      fill(0, .4 * 255);
      noStroke();
      rect(3,2,TILE_SIZE*2 + (12 + bonus) * (highlightTime.elapsed / highlightTime.duration), TILE_SIZE + 12 * (highlightTime.elapsed / highlightTime.duration), 16 - 8 * (highlightTime.elapsed / highlightTime.duration));
      
      // grown selected 
      fill(LIGHTRED);
      rect(0,0,TILE_SIZE*2 + (12 + bonus) * (highlightTime.elapsed / highlightTime.duration), TILE_SIZE + 12 * (highlightTime.elapsed / highlightTime.duration), 16 - 8 * (highlightTime.elapsed / highlightTime.duration));
      textSize(12 + 4 * (highlightTime.elapsed / highlightTime.duration));
      fill(0);
      text(actorOptions[currentSelection].toUpperCase(), 0, 0);
    }
    strokeWeight(1);
    popMatrix();
  }
  
  void mousePressed(){}
  void mouseReleased(){}
  void keyPressed(){
    
    if (key == ' ') {
      if (levels.get(currentLevel).type != LEVEL_TYPE.LEVEL) return;
      Actor spawnedActor = levels.get(currentLevel).addActor(actorOptions[currentSelection]);
      if (spawnedActor == null) return;
      Tile tileToSpawnAt = ((TileMap)levels.get(currentLevel).getActor("TileMap")).getTileAtLocation(  new PVector(mouseX, mouseY) );
      if (spawnedActor instanceof TileHolds) { 
        boolean success = ((TileHolds)spawnedActor).tryPlaceOnTile(tileToSpawnAt); 
        if (success) println("\nPlaced actor successfully: " + tileToSpawnAt.location);
        else {  
          println("\nActor failed to be placed.\nActor's actorState has been set to DEAD");
          spawnedActor.actorState = ACTOR_STATE.DEAD;
        }
      }
      else { 
        spawnedActor.actorState = ACTOR_STATE.DEAD;
        println("\nActor cannot be placed: does not implement TileHolds\nActor's actorState has been set to DEAD");
      }
    }
  }
  void keyReleased(){}
}
