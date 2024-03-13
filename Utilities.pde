class Timer extends Component {

  float duration;
  float timeLeft;
  float elapsed = 0;
  boolean isDone = true;
  boolean autoRestart = false;
  boolean paused = false;
  Callback onTickCallback = () -> { return true; };
  Callback onFinishedCallback = () -> {  return true;};
  
  Timer(float duration) {
  
    this.duration = duration;
    this.timeLeft = duration;
    isDone = false;
    
  }
  
  void update(double dt){
  
    if (this.paused) return;
    
    
    if (timeLeft <= 0) {
      timeLeft = 0;
      elapsed = duration;
      isDone = true;
      
      onFinishedCallback.call();
      if (autoRestart) reset();
      
    } else {
    
      if (!isDone) {

        
        timeLeft -= dt;
        elapsed += dt;
        
        onTickCallback.call();
      }
    }
  }
  
  void display(double alpha){}
  
  void reset(){
    
    timeLeft = duration;
    elapsed = 0;
    isDone = false;
    
  }
  
  void togglePause(){
  
    paused = !paused;
  }
}

float easeInOutQuad(float x) {
  return x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2;
}

float easeInSine(float x) {
  return 1 - cos((x * PI) / 2);
}

float easeInOut(float t, float b, float c, float d) {
    if (t == 0)
      return b;
    if ((t /= d / 2) == 2)
      return b + c;
    float p = d * (.3f * 1.5f);
    float a = c;
    float s = p / 4;
    if (t < 1)
      return -.5f * (a * (float) Math.pow(2, 10 * (t -= 1)) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p)) + b;
    return a * (float) Math.pow(2, -10 * (t -= 1)) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p) * .5f + c + b;
  }
