
;/  various string utility methods
/;
Scriptname JString Hidden


;/  Breaks source text onto set of lines of almost equal size.
    Returns JArray object containing lines.
    Accepts ASCII and UTF-8 encoded strings only
/;
int function wrap(string sourceText, int charactersPerLine=60) global native
