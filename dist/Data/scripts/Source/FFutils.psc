Scriptname FFutils Hidden
{Thanks to Brendan for this plugin}

; Replaces the actorbase's perks with the perks listed in the FormList
Function LoadCharacterPerks(ActorBase akActorbase, FormList perkList) native global

; Replaces the actorbase's shouts with the shouts listed in the FormList
Function LoadCharacterShouts(ActorBase akActorbase, FormList shoutList) native global

; Removes <formid>.nif and .dds from the respective directories. 
;  Returns
;  -1 = Bad ActorBase
;   0 = success
;   Bitmask:
;    1:kReturnDeletedNif
;    2:kReturnDeletedDDS
Int Function DeleteFaceGenData(ActorBase akActorbase) native global

Function TraceConsole(String asTrace) native global

String Function UUID() native global
