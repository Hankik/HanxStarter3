interface Updates {

  abstract void update(double dt);
}

interface Displays {
  
  abstract void display(double timeStepRemaining);
}

@FunctionalInterface
interface Callback<T> {

  abstract T call();  
}
