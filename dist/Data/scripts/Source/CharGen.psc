Scriptname CharGen Hidden

; Exports the player's head mesh and tint mask DDS relative to Data\SKSE\Plugins\CharGen\
Function ExportHead(string fileName) native global

; Saves a character's appearances to a preset file as well as a tint mask DDS
Function SaveCharacter(string characterName) native global

; Loads a character's appearance preset file onto an Actor
bool Function LoadCharacter(Actor akActor, Race akRace, string characterName) native global

; Replaces the actorbase's perks with the perks listed in the FormList
; Note: This function should ONLY be used prior to creation of the Actor
Function LoadCharacterPerks(ActorBase akActorbase, FormList perkList) native global