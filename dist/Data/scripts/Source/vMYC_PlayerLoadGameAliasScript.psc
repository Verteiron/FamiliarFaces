Scriptname vMYC_PlayerLoadGameAliasScript extends ReferenceAlias

;--=== Events ===--

Event OnPlayerLoadGame()
	(GetOwningQuest() as vMYC_MetaQuestScript).OnGameReloaded()
EndEvent
