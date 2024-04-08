
void saveToJSON(File selection) {

  if (selection == null) {
    println("\nFile selection canceled.");
    return;
  }
  if (!selection.getName().contains(".json")) {
    println("\nError: Must save to a json file.");
    return;
  }

  try {
    JSONObject json = serializer.getContents(levels.get(currentLevel));
    saveJSONObject(json, selection.getCanonicalPath());
    println("\nSaved current level to " + selection.getName());
  }
  catch(Exception e) {
    println(e);
  }
}

public class JSONSerializer {

  private Set<Object> visitedObjects = new HashSet<>();

  // This function ignores the type of o (only serializing its contents)
  JSONObject getContents(Object o) {
    visitedObjects.clear(); // Clear the set before each serialization
    return serializeObject(o);
  }

  private JSONObject serializeObject(Object o) {
    JSONObject object = new JSONObject();
    JSONObject contents = new JSONObject();
    if (o == null) return contents;
    if (visitedObjects.contains(o)) {
      // Object already visited, return an empty JSON object or handle as needed
      return contents;
    }
    
    if (o instanceof WeakReference) {
      contents.setString( "WeakReference", ((Actor)((WeakReference)o).get()).id);
      object.setJSONObject(cleanName(o.getClass().getName()), contents);
      return object;
    }

    visitedObjects.add(o);

    Field[] fields = o.getClass().getDeclaredFields();
    List<Field> extFields = new ArrayList<>(Arrays.asList(fields));
    List<Field> superFields = Arrays.asList(o.getClass().getSuperclass().getDeclaredFields());
    extFields.addAll( superFields );

    for (Field field : extFields) {
      try {
        try { field.setAccessible(true); }
        catch(Exception e) { 
          
          continue;
        }
        Class<?> fieldType = field.getType();

        if (field.isSynthetic()) continue; // this skips over java created fields

        Object fieldValue = field.get(o);

        if (isUserDefinedClass(fieldType)) {

          //println(field.getName());

          // if is a component reference sitting outside components list ... (the serialized components list will store component data)
          // we will rereference that same object on reentry into the program
          if (Component.class.isAssignableFrom(fieldType) && field.get(o) != null) { // then replace reference with string id of component

            contents.setString(field.getName(), ((Component) field.get(o)).id);
            continue;
          }
          
          if (PVector.class.isAssignableFrom(fieldType) && field.get(o) != null) {
             PVector pvector = (PVector) field.get(o);
             //if (o instanceof Player) println(pvector);
             JSONObject subobject = new JSONObject();
             subobject.setFloat("x", pvector.x);
             subobject.setFloat("y", pvector.y);
             subobject.setFloat("z", pvector.z);
             contents.setJSONObject(field.getName(), subobject);
          
            continue;
          }

          if (field.getName().contains("Callback")) continue;

          if (fieldType.isEnum()) {
            JSONObject subobject = new JSONObject();
            subobject.setString(fieldType.getSimpleName(), field.get(o).toString());
            contents.setJSONObject(field.getName(), subobject);
            continue;
          }

          //println(fieldType);
          JSONObject subobject = serializeObject(fieldValue);
          //println(subobject);
          contents.setJSONObject(field.getName(), subobject);
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

            // Add additional handling for other types if needed
            String javaObjectType = fieldType.getName().substring(fieldType.getName().lastIndexOf('.') + 1);
            switch (javaObjectType) {

            case "String":
              contents.setString(field.getName(), (String) field.get(o));
              break;

            case "ArrayList":

              ArrayList<?> arrayList = (ArrayList<?>) field.get(o);
              if (arrayList != null) {
                JSONObject listObject = new JSONObject();
                for (Object element : arrayList) {
                  JSONObject subobject = serializeObject(element);
                  String elementType = cleanName(element.getClass().getName());
                  listObject.setJSONObject(cleanName(element.toString()), (JSONObject) subobject.get(elementType));
                }
                contents.setJSONObject(field.getName(), listObject);
              }
              break;
            }
            break;
          }
        }
      }
      catch (Exception e) {
        e.printStackTrace(); // Handle exceptions appropriately
      }
    }
    object.setJSONObject(cleanName(o.getClass().getName()), contents);
    return object;
  }
}


Scene createLevel(JSONObject json) {

  Scene level = new Scene(LEVEL_TYPE.EMPTY);
  level.type = LEVEL_TYPE.LEVEL;
  JSONObject levelFields = (JSONObject) ((JSONObject) json.get("Scene")).get("actors");

  for (Object key : levelFields.keys()) {
    // Get value based on key
    String keyType = key.toString().substring(0, key.toString().indexOf("@"));
    Object value = (JSONObject) levelFields.get((String) key);
    //println(value);


    Class type = null;
    try {
      type = Class.forName("HanxStarter3$" + keyType);
    }
    catch(Exception e) {
      println(e);
    }
    if (type != null) {
      if (Actor.class.isAssignableFrom(type)) {
        Actor actor = createActor(keyType);
        populateActorFields(actor, (JSONObject) value);
        level.addActor(actor);
      }
    }
  }

  level.sortActors();
  return level;
}

void populateActorFields(Actor actor, JSONObject json) {

  Field[] fields = actor.getClass().getDeclaredFields();
  List<Field> extFields = new ArrayList<>(Arrays.asList(fields));
  List<Field> superFields = Arrays.asList(actor.getClass().getSuperclass().getDeclaredFields());
  extFields.addAll( superFields );

  for (Field field : extFields) {
    try {
      field.setAccessible(true);
      Class<?> fieldType = field.getType();

      if (field.isSynthetic()) continue; // this skips over java created fields


      if (isUserDefinedClass(fieldType)) {


        //println(fieldType.getSimpleName());

        if (Component.class.isAssignableFrom(fieldType)) {

          Class[]  parameterTypes = {HanxStarter3.class, Actor.class };
          Component component = (Component) fieldType.getDeclaredConstructor(parameterTypes).newInstance(applet, actor);
          //println(fieldType);
          Object inner = json.get(fieldType.getSimpleName());
          if (inner != null) {
            if (!(inner instanceof String)) actor.components.add(component);
          }
           
          //println(json.get(fieldType.getSimpleName()));
          populateComponentFields(component, (JSONObject) json.get(fieldType.getSimpleName())); // TO FIX: a lot of components' json is being entered as NULL.
          continue;
        }
        
        if (PVector.class.isAssignableFrom(fieldType) && field.get(actor) != null) {
             PVector pvector = (PVector) field.get(actor);
             JSONObject jsonPVector = (JSONObject) json.get( field.getName());
             if (jsonPVector == null) continue;
             //if (actor instanceof Player) println(jsonPVector);
             pvector.x = jsonPVector.getFloat("x");
             pvector.y = jsonPVector.getFloat("y");
          
            continue;
          }

        if (Actor.class.isAssignableFrom(fieldType)) {
          Actor subActor = createActor( fieldType.toString() );
          populateActorFields(subActor, (JSONObject) json.get(fieldType.toString()));

          field.set( actor, subActor );
          continue;
        }


        //println(field.getName());
        Object userDefinedObj = (Object) field.get(actor);

        if (userDefinedObj.getClass().isEnum()) {
          JSONObject userDefinedObjJSON = (JSONObject) json.get(field.getName());
          String inner = (String) userDefinedObjJSON.get(userDefinedObj.getClass().getSimpleName());
          Class<?> enumType = Class.forName(fieldType.getName());
          Enum<?> enumObj = setEnumByString(enumType.asSubclass(Enum.class), inner);
          userDefinedObj = enumObj;
          continue;
        }

        //List<Field> userDefinedObjFields = Arrays.asList( userDefinedObj.getClass().getDeclaredFields() );
        //JSONObject userDefinedObjJSON = (JSONObject) json.get(field.getName());

        

        // we have a userdefined field
      } else {
        switch (fieldType.getName()) {
          case "boolean":
            field.set(actor, (boolean) json.get(field.getName()));
          break;
          case "int":
            field.set(actor, (int) json.get(field.getName()));
          break;
        case "float":
          field.set(actor, (float) json.get(field.getName()));
          break;
        case "double":
          field.set(actor, (double) json.get(field.getName()));
          break;
        case "long":
          field.set(actor, (long) json.get(field.getName()));
          break;
        default:
          if (field.isEnumConstant()) {
          } // is enum

          // Add additional handling for other types if needed
          String javaObjectType = fieldType.getName().substring(fieldType.getName().lastIndexOf('.') + 1);
          switch (javaObjectType) {

          case "String":
            //println(json.get(field.getName()).toString());
            String foundString = json.get(field.getName()).toString();

            // look to see if value is an id BUT I DONT WANT THE KEY TO BE AN ID
            if (!field.getName().equals("id") && foundString.matches("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")) { //uuid check
              
              ImplementObjectByIDCommand findObjectCommand = new ImplementObjectByIDCommand();
              findObjectCommand.holdingObject = actor;
              findObjectCommand.holdingField = field;
              findObjectCommand.idToFind = foundString;
              levels.get(currentLevel).commands.add(findObjectCommand);
              
              continue;
            }
            field.set(actor, json.get(field.getName()));
            break;

          case "ArrayList":
            ArrayList<Object> arrayList = (ArrayList<Object>) field.get(actor);
            if (field.getName().equals("tiles")) {
              arrayList.clear();
            } 
            JSONObject list = (JSONObject) json.get(field.getName());
            
            //if (actor instanceof TileMap) println(((TileMap)actor).tiles.size());
            for (Object key : list.keys()) {
              String keyType = key.toString().substring(0, key.toString().indexOf("@"));
              //if (!keyType.equals("Tile")) println(key);
              
              if (keyType.equals("WeakReference")) {
                InsertActorByIDCommand insertActorCommand = new InsertActorByIDCommand();
                insertActorCommand.isWeakReference = true;
                insertActorCommand.list = arrayList;
                insertActorCommand.id = ((JSONObject)list.get(key.toString())).get("WeakReference").toString();
                levels.get(currentLevel).commands.add( insertActorCommand);
                continue;
              }
              
              Class type = null;
              try {
                type = Class.forName("HanxStarter3$" + keyType);
              } catch (Exception e) {}
              
              
              if (Actor.class.isAssignableFrom(type)) {
                Actor listactor = createActor(keyType);
                //println(key);
                populateActorFields(listactor, (JSONObject) list.get(key.toString()));
                arrayList.add(listactor);
              }
              
            }
            if (field.getName().equals("tiles")) {
             
                arrayList.sort(new Comparator<Object>() {
                @Override
                int compare(Object a1, Object a2) { 
                  return Integer.compare(((Tile)a1).tilemapIndex, ((Tile)a2).tilemapIndex); }
                }
              );
            } 
            
           //if (actor instanceof TileMap) println(((TileMap)actor).tiles.size());
            
            
            //println(json.get(fieldType.getName()));


            break;
            case "WeakReference": // im going to assume its an actor
              String id = json.get(field.getName()).toString();
              if (id == null) continue;
              println(id);
              
              ImplementObjectByIDCommand findObjectCommand = new ImplementObjectByIDCommand();
              findObjectCommand.holdingObject = actor;
              findObjectCommand.holdingField = field;
              findObjectCommand.idToFind = id;
              levels.get(currentLevel).commands.add(findObjectCommand);
              
              break;
          }
          break;
        }
      }
    }
    catch (Exception e) {
      e.printStackTrace(); // Handle exceptions appropriately
    }
  }
}

void populateComponentFields(Component component, JSONObject json) {
  if (json == null) return;

  Field[] fields = component.getClass().getDeclaredFields();
  List<Field> extFields = new ArrayList<>(Arrays.asList(fields));
  List<Field> superFields = Arrays.asList(component.getClass().getSuperclass().getDeclaredFields());
  extFields.addAll( superFields );

  for (Field field : extFields) {
    try {
      field.setAccessible(true);
      Class<?> fieldType = field.getType();

      if (field.isSynthetic()) continue; // this skips over java created fields

      if (isUserDefinedClass(fieldType)) {

        // we have a userdefined field
        if (Actor.class.isAssignableFrom(fieldType)) {
          Actor subActor = createActor( fieldType.toString() );
          populateActorFields(subActor, (JSONObject) json.get(fieldType.toString()));

          field.set( component, subActor );
          continue;
        }

        //println(field.getName());
        Object userDefinedObj = (Object) field.get(component);
        List<Field> userDefinedObjFields = Arrays.asList( userDefinedObj.getClass().getDeclaredFields() );
        JSONObject userDefinedObjJSON = (JSONObject) json.get(field.getName());
        for (Field userDefinedObjField : userDefinedObjFields) {
          if (userDefinedObjJSON.get( userDefinedObjField.getName()) != null)
            userDefinedObjField.set(userDefinedObj, userDefinedObjJSON.get( userDefinedObjField.getName() ));
        }
      } else {
        switch (fieldType.getName()) {
        case "boolean":
          field.set(component, json.get(field.getName()));
          break;
        case "int":
          field.set(component, json.get(field.getName()));
          break;
        case "float":
          field.set(component, json.get(field.getName()));
          break;
        case "double":
          field.set(component, json.get(field.getName()));
          break;
        case "long":
          field.set(component, json.get(field.getName()));
          break;
        default:
          if (field.isEnumConstant()) {
          } // is enum

          // Add additional handling for other types if needed
          String javaObjectType = fieldType.getName().substring(fieldType.getName().lastIndexOf('.') + 1);
          switch (javaObjectType) {

          case "String":
            String foundString = json.get(field.getName()).toString();
            if (!field.getName().equals("id") && foundString.matches("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")) { //uuid check
            
              ImplementObjectByIDCommand findObjectCommand = new ImplementObjectByIDCommand();
              findObjectCommand.holdingObject = component;
              findObjectCommand.holdingField = field;
              findObjectCommand.idToFind = foundString;
              levels.get(currentLevel).commands.add(findObjectCommand);
                
              continue;
            }
            field.set(component, json.get(field.getName()));
            break;

          case "ArrayList":
            ArrayList<?> arrayList = (ArrayList<?>) field.get(component);
            if (arrayList == null) arrayList = new ArrayList();
            //for (Object jarrayElem : (JSONArray) json.get(
            break;
            case "WeakReference": // im going to assume its an actor
              break;
          }
          break;
        }
      }
    }
    catch (Exception e) {
      e.printStackTrace(); // Handle exceptions appropriately
    }
  }
}

// Function to set enum value by string using reflection
public static <T extends Enum<T>> T setEnumByString(Class<T> enumClass, String value) {
  try {
    Method valueOfMethod = enumClass.getMethod("valueOf", String.class);
    return (T) valueOfMethod.invoke(null, value);
  }
  catch (Exception e) {
    throw new IllegalArgumentException("No such enum constant " + value);
  }
}

boolean isUserDefinedClass(Class<?> type) {
  // Exclude primitive types and common Java types
  return !type.isPrimitive() && !type.getName().startsWith("java") && !type.getName().startsWith("[");
}

String cleanName(String name) {

  if (name.startsWith("processing.core.")) return name.substring(16);
  if (name.startsWith("HanxStarter3$")) return name.substring(8);
  if (name.startsWith("java.lang.ref.")) return name.substring(14);
  return name;
}
