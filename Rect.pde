class Rect extends Component {

  float x, y, w, h;
  PVector localPosition = new PVector();
  float edgeL, edgeR, edgeT, edgeB;
  float halfW, halfH;
  
  Rect(Actor parent){
    
  
    this.parent = parent;
    setPosition(parent.location);
    setSize(TILE_SIZE, TILE_SIZE);
    calculateAABB();
  }

  Rect(float x, float y, float w, float h) {

    
    this.x = x;
    this.y = y;
    setSize(w, h);
    calculateAABB();
  }
  
  void setPosition(PVector newLocation){
  
    x = newLocation.x + localPosition.x;
    y = newLocation.y + localPosition.y;
  }

  void setSize(float w, float h) {

    this.w = w;
    this.h = h;
    halfW = w/2;
    halfH = h/2;
  }

  void calculateAABB() {

    edgeL = x - halfW;
    edgeR = x + halfW;
    edgeT = y - halfH;
    edgeB = y + halfH;
  }

  boolean checkCollidingWith(Rect other) {

    if (edgeR < other.edgeL) return false;
    if (edgeL > other.edgeR) return false;
    if (edgeB < other.edgeT) return false;
    if (edgeT > other.edgeB) return false;
    return true;
  }

  void update() {
    
    setPosition(parent.location);
    calculateAABB();
  }

  void display() {
    
    rectMode(CENTER);
    noFill();
    stroke(255);
    rectMode(CENTER);
    rect(x, y, w, h, 10);
  }

  //
  // Collision resolution methods
  //
  public void fixOverlap(Rect other) {
    float pushUp = edgeB - other.edgeT;
    float pushLeft = edgeR - other.edgeL;

    if (pushUp <= pushLeft) setBottomEdge(other.edgeT);
    else {
    }//setRightEdge(other.edgeL);
  }
  public void setBottomEdge(float Y) {
    y = Y - halfH;
    calculateAABB();
  }
  public void setRightEdge(float X) {
    x = X - halfW;
    calculateAABB();
  }
  /**
   * This method finds the best solution for moving (this) AABB out from an (other)
   * AABB object. The method compares four possible solutions: moving (this) box
   * left, right, up, or down. We only want to choose one of those four solutions.
   * The BEST solution is whichever one is the smallest. So after finding the four
   * solutions, we compare their absolute values to discover the smallest.
   * We then return a vector of how far to move (this) AABB.
   * NOTE: you should first verify that (this) and (other) are overlapping before
   * calling this method.
   * @param  other  The (other) AABB object that (this) AABB is overlapping with.
   * @return  The vector that respresents how far (and in which direction) to move (this) AABB.
   */
  public PVector findOverlapFix(Rect other) {

    float moveL = other.edgeL - edgeR; // how far to move this box so it's to the LEFT of the other box.
    float moveR = other.edgeR - edgeL; // how far to move this box so it's to the RIGHT of the other box.
    float moveU = other.edgeT - edgeB; // how far to move this box so it's to the TOP of the other box.
    float moveD = other.edgeB - edgeT; // how far to move this box so it's to the BOTTOM of the other box.

    // The above values are potentially negative numbers; the sign indicates what direction to move.
    // But we want to find out which ABSOLUTE value is smallest, so we get a non-signed version of each.

    float absMoveL = abs(moveL);
    float absMoveR = abs(moveR);
    float absMoveU = abs(moveU);
    float absMoveD = abs(moveD);

    PVector result = new PVector();

    result.x = (absMoveL < absMoveR) ? moveL : moveR; // store the smaller horizontal value.
    result.y = (absMoveU < absMoveD) ? moveU : moveD; // store the smaller vertical value.

    if (abs(result.y) <= abs(result.x)) {
      // If the vertical value is smaller, set horizontal to zero.
      result.x = 0;
    } else {
      // If the horizontal value is smaller, set vertical to zero.
      result.y = 0;
    }

    return result;
  }
}
