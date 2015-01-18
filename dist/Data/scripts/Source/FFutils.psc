Scriptname FFutils Hidden
{Thanks to Brendan for this plugin}

; Replaces the actorbase's perks with the perks listed in the FormList
Function LoadCharacterPerks(ActorBase akActorbase, FormList perkList) native global

; Replaces the actorbase's shouts with the shouts listed in the FormList
Function LoadCharacterShouts(ActorBase akActorbase, FormList shoutList) native global

; Replaces the actorbase's spells with the spells listed in the FormList
Function LoadCharacterSpells(ActorBase akActorbase, FormList spellList) native global

; Return an array (may be >128) of all the Actor's spells, optionally excluding spells from the actor's base
Form[] Function GetActorSpellList(Actor akActor, Bool abIncludeBaseSpells = True) native global

; Return an array (may be >128) of all the ActorBase's shouts
Form[] Function GetActorShoutList(ActorBase akActorBase) native global

; Populates the formlist with the all of the actor's spells, optionally excluding actorbase-provided spells
Function GetCharacterSpells(Actor akActor, FormList spellList, Bool abIncludeBase = True) native global

; Populates the formlist with the all of the actor's shouts
Function GetCharacterShouts(Actor akActor, FormList shoutList) native global

; Removes <formid>.nif and .dds from the respective directories. 
;  Returns
;  -1 = Bad ActorBase
;   0 = success
;   Bitmask:
;    1:kReturnDeletedNif
;    2:kReturnDeletedDDS
Int Function DeleteFaceGenData(ActorBase akActorbase) native global

Function TraceConsole(String asTrace) native global

String Function userDirectory() native global

String Function UUID() native global

Int Function BuildCharacterPackage(String asCharacterName) native global 

; Populates filteredList with all forms in sourceList that are aiType. Returns number of matching forms.
Int Function FilterFormlist(FormList sourceList, Formlist filteredList, Int aiType) native global

; Return an array (may be >128) of all forms in sourceList that are aiType.
Form[] Function GetfilteredList(FormList sourceList, Int aiType) native global

Int[] Function GetItemCounts(Form[] sourceArray, ObjectReference akObject) native global

Int[] Function GetItemTypes(Form[] sourceArray) native global

Int[] Function GetItemFavorited(Form[] sourceArray) native global

Int[] Function GetItemHasExtraData(Form[] sourceArray) native global

String[] Function GetItemNames(Form[] sourceArray) native global

; Return the name of the mod that provides this form
String Function GetSourceMod(Form akForm) native global

String Function ReadStringFromFile(String sFileName) native global

String[] Function GetNodeList(Form akForm) native global


