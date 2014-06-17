
;/  Each container (JArray, JMap & JFormMap) inherits JValue functionality
/;
Scriptname JValue Hidden


;/  Retains and returns the object.
    All containers that were created with object* or objectWith* methods are automatically destroyed after some amount of time (~10 seconds)
    To keep object alive you must retain it once and you have to __release__ it when you do not need it anymore (also to not pollute save file).
    An alternative to retain-release is store object in JDB container
/;
int function retain(int object) global native

;/  releases the object and returns zero, so you could release and nullify with one line of code: object = JVlaue.release(object)
/;
int function release(int object) global native

;/  just a union of retain-release calls. releases previousObject, retains and returns newObject.
    useful for those who use Papyrus properties instead of manual (and more error-prone) release-retain object lifetime management
/;
int function releaseAndRetain(int previousObject, int newObject) global native

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

;/  creates and returns new container (JArray or JMap) containing the contents of JSON file
/;
int function readFromFile(string filePath) global native

;/  parses files in directory (non recursive) and returns JMap containing filename - json-object pairs.
    note: by default it does not filters files by extension and will try to parse everything
/;
int function readFromDirectory(string directoryPath, string extension="") global native

;/  creates new container object using given JSON string-prototype
/;
int function objectFromPrototype(string prototype) global native

;/  writes object into JSON file
/;
function writeToFile(int object, string filePath) global native

;/  returns true, if container capable resolve given path.
    for ex. JValue.hasPath(container, ".player.health") will check if given container has 'player' which has 'health' information
/;
bool function hasPath(int object, string path) global native

;/  attempts to get value at given path.
    JValue.solveInt(container, ".player.mood") will return player's mood
/;
float function solveFlt(int object, string path) global native
int function solveInt(int object, string path) global native
string function solveStr(int object, string path) global native
int function solveObj(int object, string path) global native
form function solveForm(int object, string path) global native

;/  attempts to set value.
    JValue.solveIntSetter(container, ".player.mood", 12) will set player's mood to 12
/;
bool function solveFltSetter(int object, string path, float value) global native
bool function solveIntSetter(int object, string path, int value) global native
bool function solveStrSetter(int object, string path, string value) global native
bool function solveObjSetter(int object, string path, int value) global native
bool function solveFormSetter(int object, string path, form value) global native
