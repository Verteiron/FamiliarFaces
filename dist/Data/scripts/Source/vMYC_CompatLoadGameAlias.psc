Scriptname vMYC_CompatLoadGameAlias extends ReferenceAlias

Event OnPlayerLoadGame()
	(GetOwningQuest() as vMYC_CompatBase).OnGameReload()
EndEvent
