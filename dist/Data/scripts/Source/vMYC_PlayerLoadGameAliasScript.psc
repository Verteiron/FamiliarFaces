Scriptname vMYC_PlayerLoadGameAliasScript extends ReferenceAlias
{Attach to Player alias. Enables the quest to receive the OnGameReload event.}

; === [ vMYC_PlayerLoadGameAliasScript.psc ] ==============================---
; Enables the owning vMYC_BaseQuest to receive the OnGameReload event.
; ========================================================---

;=== Events ===--

Event OnPlayerLoadGame()
{Send OnGameReload event to the owning quest.}
	(GetOwningQuest() as vMYC_BaseQuest).OnGameReload()
EndEvent
