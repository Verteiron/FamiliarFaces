Scriptname vFFC_PlayerLoadGameAliasScript extends ReferenceAlias
{Attach to Player alias. Enables the quest to receive the OnGameReload event.}

; === [ vFFC_PlayerLoadGameAliasScript.psc ] ==============================---
; Enables the owning vFFC_BaseQuest to receive the OnGameReload event.
; ========================================================---

;=== Events ===--

Event OnPlayerLoadGame()
{Send OnGameReload event to the owning quest.}
	(GetOwningQuest() as vFFC_BaseQuest).OnGameReload()
EndEvent
