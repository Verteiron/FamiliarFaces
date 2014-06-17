
;/  Global entry point to store mod information. Main intent - replace global variables
    Manages keys and values associations as JMap
/;
Scriptname JDB Hidden


;/  attempts to get value associated with path.
    for ex. following information associated with 'frosfall' key:
    
    "frostfall" : {
        "exposureRate" : 0.5,
        "arrayC" : ["stringValue", 1.5, 10, 1.14]
    }
    
    then JDB.solveFlt(".frostfall.exposureRate") will return 0.5 and
    JDB.solveObj(".frostfall.arrayC") will return array containing ["stringValue", 1.5, 10, 1.14] values
/;
float function solveFlt(string path) global native
int function solveInt(string path) global native
string function solveStr(string path) global native
int function solveObj(string path) global native
form function solveForm(string path) global native

;/  attempts to assign value. returns false if no such path
                for ex. JDB.solveFltSetter(".frostfall.exposureRate", 1.0) assigns 1.0 to ".frostfall.exposureRate" path
/;
bool function solveFltSetter(string path, float value) global native
bool function solveIntSetter(string path, int value) global native
bool function solveStrSetter(string path, string value) global native
bool function solveObjSetter(string path, int value) global native
bool function solveFormSetter(string path, form value) global native

;/  Associates(and replaces previous association) container object with a string key.
    destroys association if object is zero
    for ex. JDB.setObj("frostfall", frostFallInformation) will associate 'frostall' key and frostFallInformation so you can access it later
/;
function setObj(string key, int object) global native

;/  returns true, if DB capable resolve given path, e.g. it able to execute solve* or solver*Setter functions successfully
/;
bool function hasPath(string path) global native

;/  returns new array containing all JDB keys
/;
int function allKeys() global native

;/  returns new array containing all containers associated with JDB
/;
int function allValues() global native

;/  writes storage data into JSON file at given path
/;
function writeToFile(string path) global native

;/  reads information from a file at given path and fills storage with it's JSON content
    NOTE: it will replace all existing JDB contents!
/;
function readFromFile(string path) global native
