abstract class Actor implements Updates, Displays {

  String name = "actor";
  PVector location = new PVector(0,0,0);
  PVector rotation = new PVector(0,0,0);
  PVector scale = new PVector(1,1,1);

  Actor(){}
  
  abstract void update(double dt);
  
  abstract void display(double alpha);
}

abstract class Component implements Updates, Displays {

  String name = "component";
  abstract void update(double dt);
  abstract void display(double alpha);
}
