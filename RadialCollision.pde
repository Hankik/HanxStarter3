class RadialCollision extends Component {

  float x, y, r;
  PVector localPosition = new PVector();
  
  // draw variables
  color fill = 0;
  float fillOpacity = 1; // 0-1 keep normalized
  color stroke = WHITE;
  float strokeOpacity = 1;
  
  RadialCollision(Actor parent){
    
  
    this.parent = parent;
    setPosition(parent.location);
    //setSize(TILE_SIZE, TILE_SIZE);
  }

  RadialCollision(float x, float y, float r) {    
    this.x = x;
    this.y = y;
    this.r = r;
    //setSize(w, h);
  }
  
  void setPosition(PVector newLocation){
  
    x = newLocation.x + localPosition.x;
    y = newLocation.y + localPosition.y;
  }

  void update() {
    
    //setPosition(parent.location);
  }

  void display() {
    
    rectMode(CENTER);
    fill(fill, clamp(fillOpacity, 0, 1) * 255);
    stroke(stroke, clamp(strokeOpacity, 0, 1) * 255);
    rectMode(CENTER);
    circle(x, y, r);
    
    //rectMode(CENTER);
    //fill(fill, clamp(fillOpacity, 0, 1) * 255);
    //stroke(stroke, clamp(strokeOpacity, 0, 1) * 255);
    //rectMode(CENTER);
    //rect(x, y, w, h, 10);
  }
}
