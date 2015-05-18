Scriptname vFFC_UpdatePlayerData extends Quest
{Updates player data when certain SM events fire.}

Event OnStoryIncreaseSkill(string asSkill)
	SendModEvent("vFFC_BackgroundFunction","ScanPlayerStats")
	Stop()
EndEvent

Event OnStoryIncreaseLevel(Int aiNewLevel)
	SendModEvent("vFFC_BackgroundFunction","ScanPlayerStats")
	Stop()
EndEvent
