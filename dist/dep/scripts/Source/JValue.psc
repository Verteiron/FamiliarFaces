
;/  Each container (JArray, JMap & JFormMap) inherits JValue functionality
/;
Scriptname JValue Hidden


;/  Retains and returns the object. Purpose - extend object lifetime.
    Newly created object if not retained or not referenced/contained by another container directly or indirectly gets destoyed after ~10 seconds due to absence of owners.
    Retain increases amount of owners object have by 1. The retainer is responsible for releasing object later.
    Object have extended lifetime if JDB or JFormDB or any other container references/owns/contains object directly or indirectly.
    It's recommended to set a tag (any unique string will fit - mod name for ex.) - later you'll be able to release all objects with selected tag even if identifier was lost
/;
int function retain(int object, string tag="") global native

;/  releases the object and returns zero, so you can release and nullify with one line of code: object = JValue.release(object)
/;
int function release(int object) global native

;/  Just a union of retain-release calls. Releases previousObject, retains and returns newObject.
    It's recommended to set a tag (any unique string will fit - mod name for ex.) - later you'll be able to release all objects with selected tag even if identifier was lost.
/;
int function releaseAndRetain(int previousObject, int newObject, string tag="") global native

;/  For cleanup purpose only - releases lost (and not lost) objects with given tag.
    Complements all retain calls objects with given tag received with release calls.
    See 'object lifetime management' section for more information
/;
function releaseObjectsWithTag(string tag) global native

;/  Handly for temporary objects (objects with no owners) - pool 'locationName' owns any amount of objects, preventing their destuction, extends lifetime.
    Do not forget to clean location later! Typical use:
    int tempMap = JValue.addToPool(JMap.object(), "uniquePoolName")
    anywhere later:
    JValue.cleanTempLocation("uniqueLocationName")
/;
int function addToPool(int object, string poolName) global native
function cleanPool(string poolName) global native

;/  
    
    tests whether given object identifier points to existing object
/;
bool function isExists(int object) global native

;/  returns true if object is map, array or formmap container
/;
bool function isArray(int object) global native
bool function isMap(int object) global native
bool function isFormMap(int object) global native

;/  returns true, if container is empty
/;
bool function empty(int object) global native

;/  returns the number of items in container
/;
int function count(int object) global native

;/  removes all items from container
/;
function clear(int object) global native

;/  JSON serialization/deserialization:
    
    creates and returns new container object containing the contents of JSON file
/;
int function readFromFile(string filePath) global native

;/  parses JSON files in directory (non recursive) and returns JMap containing {filename, container-object} pairs.
    note: by default it does not filters files by extension and will try to parse everything
/;
int function readFromDirectory(string directoryPath, string extension="") global native

;/  creates new container object using given JSON string-prototype
/;
int function objectFromPrototype(string prototype) global native

;/  writes object into JSON file
/;
function writeToFile(int object, string filePath) global native

;/  Path resolving:
    
    returns true, if container capable resolve given path.
    for ex. JValue.hasPath(container, ".player.health") will check if given container has 'player' which has 'health' information
/;
bool function hasPath(int object, string path) global native

;/  Returns type of resolved value. 0 - no value, 1 - none, 2 - int, 3 - float, 4 - form, 5 - object, 6 - string
/;
int function solvedValueType(int object, string path) global native

;/  attempts to get value at given path.
    JValue.solveInt(container, ".player.mood") will return player's mood
/;
float function solveFlt(int object, string path, float default=0.0) global native
int function solveInt(int object, string path, int default=0) global native
string function solveStr(int object, string path, string default="") global native
int function solveObj(int object, string path, int default=0) global native
form function solveForm(int object, string path, form default=None) global native

;/  Attempts to assign value. Returns false if no such path
    With 'createMissingKeys=true' it creates any missing path element: solveIntSetter(map, ".keyA.keyB", 10, true) on empty JMap creates {keyA: {keyB: 10}} structure
/;
bool function solveFltSetter(int object, string path, float value, bool createMissingKeys=false) global native
bool function solveIntSetter(int object, string path, int value, bool createMissingKeys=false) global native
bool function solveStrSetter(int object, string path, string value, bool createMissingKeys=false) global native
bool function solveObjSetter(int object, string path, int value, bool createMissingKeys=false) global native
bool function solveFormSetter(int object, string path, form value, bool createMissingKeys=false) global native

;/  Evaluates piece of lua code. Lua support is experimental
/;
float function evalLuaFlt(int object, string luaCode, float default=0.0) global native
int function evalLuaInt(int object, string luaCode, int default=0) global native
string function evalLuaStr(int object, string luaCode, string default="") global native
int function evalLuaObj(int object, string luaCode, int default=0) global native
form function evalLuaForm(int object, string luaCode, form default=None) global native
