import java.lang.reflect.*;
import java.util.*;
import java.util.HashSet;
import java.util.Set;

// TIMESTEP //
double t, prevTime = 0.0;
double _dt = 1/ 60.0;
double elapsed = 0.0;

double currentTime = millis() / 1000;
double accumulator = 0.0;
// TIMESTEP
Level test;

void setup() {
  surface.setTitle("HaxStarterTemplate");
  surface.setResizable(false);
  size(1280, 720);
  frameRate(60);

  test = new Level();

  JSONSerializer serializer = new JSONSerializer();
  JSONObject json = serializer.getContents(test);
  saveJSONObject(json, "data/save.json");
}

void draw() {
  background(0);

//  double newTime = millis() / 1000;
//  double frameTime = newTime - currentTime;
//  currentTime = newTime;

//  accumulator += frameTime;

//  while ( accumulator >= _dt ) {
//    // update everything
//    test.update(_dt);
//    println("u");
//    t += _dt;
//    accumulator -= _dt;
//  }
 // calculate delta time
  float currTime = millis();
  _dt = (currTime - prevTime) / 1000;
  prevTime = currTime;
  
  elapsed += _dt;
  test.update(_dt);

  final double timeStepRemaining = accumulator / _dt;
  test.display(timeStepRemaining);
}

void mousePressed(){
  test.mousePressed();
}

void mouseReleased(){
  test.mouseReleased();
}

void keyPressed(){
  Keyboard.handleKeyDown(keyCode);
  test.keyPressed();
}


void keyReleased(){
  Keyboard.handleKeyUp(keyCode);
  test.keyReleased();
}

public class JSONSerializer {

  private Set<Object> visitedObjects = new HashSet<>();

  // This function ignores the type of o (only serializing its contents)
  JSONObject getContents(Object o) {
    visitedObjects.clear(); // Clear the set before each serialization
    return serializeObject(o);
  }

  private JSONObject serializeObject(Object o) {
    JSONObject contents = new JSONObject();
    if (o == null) return contents;
    if (visitedObjects.contains(o)) {
      // Object already visited, return an empty JSON object or handle as needed
      return contents;
    }

    visitedObjects.add(o);

    Field[] fields = o.getClass().getDeclaredFields();
    List<Field> extFields = new ArrayList<>(Arrays.asList(fields));
    List<Field> superFields = Arrays.asList(o.getClass().getSuperclass().getDeclaredFields()); 
    extFields.addAll( superFields );

    for (Field field : extFields) {
      try {
        field.setAccessible(true); 
        Class<?> fieldType = field.getType();
        if (field.isSynthetic()) continue;
        if (isUserDefinedClass(fieldType)) {
          JSONObject subobject = new JSONObject();
          println(field.getName() + ", " + cleanName(fieldType.getName()) + ", " + ((field.get(o) != null) ? cleanName(field.get(o).toString()) : "null"));
          contents.setJSONObject(field.getName(), subobject.setJSONObject(cleanName(fieldType.getName()), serializeObject(field.get(o))));
        } else {
          switch (fieldType.getName()) {
            case "boolean":
              contents.setBoolean(field.getName(), field.getBoolean(o));
            break;
          case "int":
            contents.setInt(field.getName(), field.getInt(o));
            break;
          case "float":
            contents.setFloat(field.getName(), field.getFloat(o));
            break;
          case "double":
            contents.setDouble(field.getName(), field.getDouble(o));
            break;
          case "long":
            contents.setLong(field.getName(), field.getLong(o));
            break;
          default:
            if (field.isEnumConstant()) contents.setString(field.getName(), (String) field.get(o));
            // Add additional handling for other types if needed
            break;
          }
        }
      }
      catch (Exception e) {
        e.printStackTrace(); // Handle exceptions appropriately
      }
    }
    return contents;
  }

  private boolean isUserDefinedClass(Class<?> type) {
    // Exclude primitive types and common Java types
    return !type.isPrimitive() && !type.getName().startsWith("java");
  }
  
  String cleanName(String name) {
  
    if (name.startsWith("processing.core.")) return name.substring(16);
    if (name.startsWith("HanxStarter3")) return name.substring(13);
    return name;
  }
}
