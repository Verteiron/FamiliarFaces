Scriptname FFutils Hidden
{Series of utility functions provided by ffutils.dll.}

; === [ FFutils.psc ] =====================================================---
; Thanks to expired for starting this plugin for me. It has since been 
; added to considerably. These are mostly bulk functions that are much
; faster to do on the c++ side than on the Papyrus side.
; ========================================================---

Function SetLevel(ActorBase akActorBase, Int newLevel) native global
{Set akActorbase's level.}

Function LoadCharacterPerks(ActorBase akActorbase, FormList perkList) native global
{Replaces akActorbase's perks with the perks listed in the FormList.}

Function LoadCharacterShouts(ActorBase akActorbase, FormList shoutList) native global
{Replaces akActorbase's shouts with the shouts listed in the FormList.}

Function LoadCharacterSpells(ActorBase akActorbase, FormList spellList) native global
{Replaces akActorbase's spells with the spells listed in the FormList.}

Form[] Function GetActorSpellList(Actor akActor, Bool abIncludeBaseSpells = True) native global
{Returns an array (may be >128) of all the Actor's spells, optionally excluding spells from the actor's base.}

Form[] Function GetActorShoutList(ActorBase akActorBase) native global
{Returns an array (may be >128) of all akActorbase's shouts.}

Function GetCharacterSpells(Actor akActor, FormList spellList, Bool abIncludeBase = True) native global
{Populates spellList with the all of akActor's spells. If abIncludeBase is true, excludes actorbase-provided spells.}

Function GetCharacterShouts(Actor akActor, FormList shoutList) native global
{Populates shoutList with the all of akActor's shouts.}

Int Function DeleteFaceGenData(ActorBase akActorbase) native global
{Removes <formid>.nif and .dds from the respective directories. 
  Returns
   -1 = Bad ActorBase
    0 = success
  Bitmask:
    1:kReturnDeletedNif
    2:kReturnDeletedDDS
.}

Function TraceConsole(String asTrace) native global
{Print a string to the console.}

String Function userDirectory() native global
{Returns "%UserProfile%/My Documents/My Games/Skyrim/Familiar Faces".}

String Function UUID() native global
{Returns a random UUID.}

Int Function BuildCharacterPackage(String asCharacterName) native global 
{Returns a random UUID.}

Int Function FilterFormlist(FormList sourceList, Formlist filteredList, Int aiType) native global
{Populates filteredList with all forms in sourceList that are aiType. Returns number of matching forms.}

Form[] Function GetfilteredList(FormList sourceList, Int aiType) native global
{Returns an array (may be >128) of all forms in sourceList that are aiType.}

Int[] Function GetItemCounts(Form[] sourceArray, ObjectReference akObject) native global
{Returns an array (may be >128) of the counts for all form in sourceArray in akObject's inventory.}

Int[] Function GetItemTypes(Form[] sourceArray) native global
{Returns an array (may be >128) of the numeric ItemTypes for all forms in sourceArray.}

Int[] Function GetItemFavorited(Form[] sourceArray) native global
{Returns an array (may be >128) of Bool as Int indicating whether the item is favorited.}

Int[] Function GetItemHasExtraData(Form[] sourceArray) native global
{Returns an array (may be >128) of Bool as Int indicating whether the item has ExtraData (is customized or enchanted).}

String[] Function GetItemNames(Form[] sourceArray) native global
{Returns an array (may be >128) of String containing the names of all forms in sourceArray.}

String Function GetSourceMod(Form akForm) native global
{Returns the name of the mod that provides akForm.}

String Function ReadStringFromFile(String sFileName) native global
{FIXME: DEBUG DO NOT USE! Returns a string read from sFileName.}

String[] Function GetNodeList(Form akForm) native global
{FIXME: DEBUG DO NOT USE! Returns an array (may be >128) of String containing the node names of akForm. DOES NOT WORK!.}
