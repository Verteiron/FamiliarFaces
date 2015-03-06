Scriptname vMYC_UpdatePlayerData extends Quest
{Updates player data when certain SM events fire.}

Event OnStoryIncreaseSkill(string asSkill)
	SendModEvent("vMYC_BackgroundFunction","ScanPlayerStats")
	Stop()
EndEvent

Event OnStoryIncreaseLevel(Int aiNewLevel)
	SendModEvent("vMYC_BackgroundFunction","ScanPlayerStats")
	Stop()
EndEvent
