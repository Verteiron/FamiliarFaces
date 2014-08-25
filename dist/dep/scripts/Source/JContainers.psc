
;/  Various utility methods
/;
Scriptname JContainers Hidden


;/  returns true if JContainers plugin is installed
/;
bool function isInstalled() global native

;/  returns API version. Incremented by 1 each time old API is not backward compatible with new one.
    current API version is 3
/;
int function APIVersion() global native

;/  returns true if file at path exists
/;
bool function fileExistsAtPath(string path) global native

;/  A path to user-specific directory - /My Games/Skyrim/JCUser/
/;
string function userDirectory() global native

;/  returns last occured error (error code):
    0 - JError_NoError
    1 - JError_ArrayOutOfBoundAccess
/;
int function lastError() global native

;/  returns string that describes last error
/;
string function lastErrorString() global native
