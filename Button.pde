class Button extends Actor implements Listens {

  String text = "";
  Rect rect;
  ButtonState state = ButtonState.IDLE;
  Callback purposeCallback = () -> { println("\nbutton does nothing"); return false; };
  
  Button(){
  
    PVector startPosition = getGridLocation( new PVector(width/2, height/2) );
    location = new PVector(startPosition.x, startPosition.y);
    rect = (Rect) addComponent("Rect");
    rect.setSize(TILE_SIZE, TILE_SIZE);
  }

  Button(PVector location, PVector size, String text, Callback purpose) {

    rect = new Rect(location.x, location.y, size.x, size.y);
    this.purposeCallback = purpose;
    this.text = text;
  }

  void update() {
    rect.update();

    switch (state) {

    case IDLE:
      if (mouseX < rect.x - rect.halfW) break;
      if (mouseX > rect.x + rect.halfW) break;
      if (mouseY < rect.y - rect.halfH) break;
      if (mouseY > rect.y + rect.halfH) break;
      state = ButtonState.HOVERED;
      break;
    case HOVERED:
      if (mouseX < rect.x - rect.halfW) {
        state = ButtonState.IDLE;
        break;
      }
      if (mouseX > rect.x + rect.halfW) {
        state = ButtonState.IDLE;
        break;
      }
      if (mouseY < rect.y - rect.halfH) {
        state = ButtonState.IDLE;
        break;
      }
      if (mouseY > rect.y + rect.halfH) {
        state = ButtonState.IDLE;
        break;
      }
      break;
    case PRESSED:
      if (mouseX < rect.x - rect.halfW) {
        state = ButtonState.IDLE;
        break;
      }
      if (mouseX > rect.x + rect.halfW) {
        state = ButtonState.IDLE;
        break;
      }
      if (mouseY < rect.y - rect.halfH) {
        state = ButtonState.IDLE;
        break;
      }
      if (mouseY > rect.y + rect.halfH) {
        state = ButtonState.IDLE;
        break;
      }
      break;
    case RELEASED:
      purposeCallback.call();
      state = ButtonState.IDLE;
      break;
    }
  }

  void display() {
    
    switch (state) {
    
      case IDLE:
      fill(LIGHTBLUE);
      break;
      case HOVERED:
      fill(BLUE);
      break;
      case PRESSED:
      fill(DARKBLUE);
      break;
      case RELEASED:
      fill(DARKBLUE);
      break;
    }
    stroke(0);
    textFont(maiandra);
    strokeWeight(1);
    rectMode(CENTER);
    rect( rect.x, rect.y, rect.w, rect.h, 8);
    fill(0);
    textAlign(CENTER);
    textSize(16);
    text(text, rect.x, rect.y + 6);
  }

  void mousePressed() {

    if (state == ButtonState.HOVERED) {

      state = ButtonState.PRESSED;
    }
  }

  void mouseReleased() {

    if (state == ButtonState.PRESSED) {

      state = ButtonState.RELEASED;
    }
  }
  
  void keyPressed(){}
  void keyReleased(){}
}

enum ButtonState {

  IDLE,
    HOVERED,
    PRESSED,
    RELEASED,
}
