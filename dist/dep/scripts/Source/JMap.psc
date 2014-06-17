
;/  Associative key-value container.
    Inherits JValue functionality
/;
Scriptname JMap Hidden


;/  creates new container object. returns container identifier (integral number).
    identifier is the thing you will have to pass to the most of container's functions as first argument
/;
int function object() global native

;/  returns value associated with key
/;
int function getInt(int object, string key) global native
float function getFlt(int object, string key) global native
string function getStr(int object, string key) global native
int function getObj(int object, string key) global native
form function getForm(int object, string key) global native

;/  creates key-value association. replaces existing value if any
/;
function setInt(int object, string key, int value) global native
function setFlt(int object, string key, float value) global native
function setStr(int object, string key, string value) global native
function setObj(int object, string key, int container) global native
function setForm(int object, string key, form value) global native

;/  returns true, if something associated with key
/;
bool function hasKey(int object, string key) global native

;/  returns new array containing all keys
/;
int function allKeys(int object) global native

;/  returns new array containing all values
/;
int function allValues(int object) global native

;/  destroys key-value association
/;
bool function removeKey(int object, string key) global native

;/  returns count of items/associations
/;
int function count(int object) global native

;/  removes all items from container
/;
function clear(int object) global native
