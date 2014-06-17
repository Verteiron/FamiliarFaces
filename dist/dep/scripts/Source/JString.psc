
;/  various string utility methods
/;
Scriptname JString Hidden


;/  breaks source text onto set of lines of almost equal size.
    returns JArray object containing lines
/;
int function wrap(string sourceText, int charactersPerLine=60) global native
