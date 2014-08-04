Scriptname vMYC_PlayerLoadGameEFFCompatAlias extends ReferenceAlias  

;--=== Events ===--

Event OnPlayerLoadGame()
	(GetOwningQuest() as vMYC_CompatEFF).OnGameReloaded()
EndEvent