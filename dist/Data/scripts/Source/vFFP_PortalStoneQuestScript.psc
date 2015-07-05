Scriptname vFFP_PortalStoneQuestScript extends Quest
{Give the player the portal script. This will be a bit more elaborate later.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Actor Property PlayerRef Auto

Message Property vFFP_PortalStoneAddedMSG Auto

MiscObject	Property	vFFP_PortalStone	Auto

ReferenceAlias	Property	alias_PortalStone	Auto

;=== Config variables ===--


;=== Variables ===--

ObjectReference _kPortalStone

;=== Events ===--

Event OnInit()
	;Debug.Trace("MYC/PortalStoneQuest: OnInit!")
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	If !PlayerREF.GetItemCount(vFFP_PortalStone) && IsRunning()
		;Debug.Trace("MYC/PortalStoneQuest: Adding portal stone to player...")
		_kPortalStone = PlayerREF.PlaceAtMe(vFFP_PortalStone)
		alias_PortalStone.ForceRefTo(_kPortalStone)
		PlayerREF.AddItem(_kPortalStone,1,abSilent = True)
		vFFP_PortalStoneAddedMSG.Show()
	Else
		RegisterForSingleUpdate(1.0)
	EndIf

EndEvent