class Tile extends Actor {

  Tile[] neighbors = new Tile[4];
  Rect rect;
    // Weak references do not keep objects alive in memory when all normal (strong) references are gone
    // We use WeakReference<T> so we do not need to make sure every kill method communicates to associated tiles that they need to drop their references.
    ArrayList<WeakReference<Actor>> heldItems = new ArrayList();
  //WeakReference<TileHolds> heldItem = new WeakReference(null);
  int tilemapIndex = 0;
  int cost = 1;

  Tile() {

    PVector startPosition = getGridLocation( new PVector(GRID_X_OFFSET, 0) );
    location = new PVector(startPosition.x, startPosition.y); // many components require its parent have a location so make sure we instantiate location ahead of time
    rect = (Rect) addComponent("Rect");  // like rect ^^
    rect.strokeOpacity = 0.1;
    rect.fillOpacity = 0;
    layer = 1;
  }

  void update() {
    update(components);
    for (int i = heldItems.size() - 1; i >= 0; i--) {
      
      if (heldItems.get(i).get() == null) heldItems.remove(i);
    }
  }

  void display() {
    
    rect.fillOpacity = (cost - 1) * (255 / 10);
    rect.fill = (cost - 1) * (255/10);
    display(components);
    //if (heldItems.size() > 0 && heldItems.get(0).get() instanceof Actor) rect.fillOpacity = .5;
    //else rect.fillOpacity = 0;
    //if (rect.checkCollidingWithPoint(new PVector(mouseX, mouseY) )) {
    //  fill(0, .3 * 255);
    //  for (Tile neighbor : neighbors) if (neighbor != null) rect(neighbor.location.x, neighbor.location.y, TILE_SIZE, TILE_SIZE);
    //}
  }
}

class TileMap extends Actor {


  final int MAP_WIDTH = 24;
  final int MAP_HEIGHT = 23;
  ArrayList<Tile> tiles = new ArrayList();
  Rect rect = null;

  TileMap() {

    rect = (Rect) addComponent("Rect");
    rect.setSize(TILE_SIZE * (MAP_WIDTH), TILE_SIZE * MAP_HEIGHT);
    location = PVector.sub(getGridLocation( new PVector(GRID_X_OFFSET + (MAP_WIDTH/2) * TILE_SIZE, (MAP_HEIGHT/2) * TILE_SIZE) ), new PVector(16, 0));
    rect.fill = 0;
    rect.fillOpacity = .75;
    rect.strokeOpacity = 0;
    layer = -1;

    for (int i = 0; i < MAP_WIDTH*MAP_HEIGHT; i++) tiles.add( new Tile() );

    for (int i = 0; i < MAP_WIDTH*MAP_HEIGHT; i++) {

      // populate neighbors
      Tile tile = tiles.get(i);
      tile.tilemapIndex = i;
      if (i % MAP_WIDTH != 0) tile.neighbors[NEIGHBOR_LEFT] = tiles.get(i-1);
      if (i / MAP_WIDTH >= 1) tile.neighbors[NEIGHBOR_TOP] = tiles.get(i-MAP_WIDTH);
      if ((i + 1) % MAP_WIDTH != 0) tile.neighbors[NEIGHBOR_RIGHT] = tiles.get(i+1);
      if (i / MAP_WIDTH < MAP_HEIGHT-1) tile.neighbors[NEIGHBOR_BOT] = tiles.get(i+MAP_WIDTH);

      tile.location =  getGridLocation( new PVector ( GRID_X_OFFSET + (i % MAP_WIDTH) * TILE_SIZE, (i / MAP_WIDTH) * TILE_SIZE) ) ;
      //println(tile.location);
    }
  }

  void update() {
    update(components);
    for (Tile t : tiles) t.update();
  }

  void display() {
    display(components);
    for (Tile t : tiles) t.display();
  }

  Tile getTileAtLocation(PVector location) { // you dont need to pass in a gridlocation
    if (!rect.checkCollidingWithPoint(new PVector(mouseX, mouseY) )) return null;
    
    location = PVector.add(location, new PVector(-GRID_X_OFFSET, 0));
    
    int y = floor(location.y / TILE_SIZE) * MAP_WIDTH;
    int x = floor(location.x / TILE_SIZE) % MAP_WIDTH;
    //println("\nRetrieved tile at index " + (y + x) + "/" + (tiles.size()-1));
    return tiles.get(y+x);
  }
}

final int NEIGHBOR_LEFT = 0;
final int NEIGHBOR_TOP = 1;
final int NEIGHBOR_RIGHT = 2;
final int NEIGHBOR_BOT = 3;

class PathNode {
  
  PathNode(){}
  PathNode(Tile t, PathNode parent, int gcost, int hcost, float fcost) {
    this.tile = t;
    this.parent = parent;
    this.gcost = gcost;
    this.hcost = hcost;
    this.fcost = fcost;
  }
  PathNode(Tile t, PathNode parent, int gcost, int hcost) {
    this.tile = t;
    this.parent = parent;
    this.gcost = gcost;
    this.hcost = hcost;
  }

  Tile tile = null;
  PathNode parent = null;
  int gcost = 0;
  float hcost = 0;
  float fcost = 0;
  
}

ArrayList<Tile> reconstructPath(PathNode goal) {
  
    ArrayList<Tile> path = new ArrayList();
    PathNode current = goal;
    
    while (current != null) {
    
      path.add(0, current.tile);
      current = current.parent;
    }
    
    return path;
}

int heuristic(PathNode a, PathNode b) {
    return floor(abs(a.tile.location.x - b.tile.location.x) + abs(a.tile.location.y - b.tile.location.y));
}

ArrayList<Tile> findPath(Tile start, Tile goal) {
  
  PathNode startNode = new PathNode();
  PathNode goalNode = new PathNode();
  startNode.tile = start;
  goalNode.tile = goal;
  startNode.hcost = heuristic( startNode, goalNode);
  
  // create the open and closed sets
  PriorityQueue<PathNode> openSet = new PriorityQueue<>( (a, b) -> {
        if (Float.compare(a.fcost, b.fcost) == 0) {
            // Tie-breaking: Prefer states with higher g-cost (distance from start)
            return Integer.compare(b.gcost, a.gcost);
        } else {
            return Float.compare(a.fcost, b.fcost);
        }
    });
  HashSet<PathNode> closedSet = new HashSet();
  
  int depth = 0;
  // add start node to open set
  openSet.offer(startNode);
  
  while (!openSet.isEmpty() && depth < 11000) {
  
    PathNode current = openSet.poll();
    depth++;
    println(depth);
    
    // If we reached goal, reconstruct path
    if (current.tile == goalNode.tile) {
    
      return reconstructPath(current);
    }
    
    closedSet.add(current);
    
    for (Tile neighbor : current.tile.neighbors) {
      
      PathNode neighborNode = new PathNode();
      neighborNode.tile = neighbor;
      if (neighbor != null && !closedSet.contains(neighborNode)) {
      
        int gcost = current.gcost + neighbor.cost; 
        float hcost = heuristic( neighborNode, goalNode);
        neighborNode.parent = current;
        neighborNode.gcost = gcost;
        neighborNode.hcost = hcost;
        neighborNode.fcost = gcost + hcost;
        
        // If the neighbor is not in the open set or has a lower fCost, add it to the open set
        if (!openSet.contains(neighborNode) || neighborNode.fcost < openSet.stream()
                                                                         .filter(n -> n.tile == neighbor)
                                                                         .findFirst()
                                                                         .orElse(new PathNode(neighbor, null, 0, 0, 0))
                                                                         .fcost) {
          openSet.offer(neighborNode);
        }
      }
    }
  }
  return null;
}
