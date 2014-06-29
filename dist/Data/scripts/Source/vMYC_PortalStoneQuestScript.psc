Scriptname vMYC_PortalStoneQuestScript extends Quest
{Give the player the portal script. This will be a bit more elaborate later.}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Actor Property PlayerRef Auto

Message Property vMYC_PortalStoneAddedMSG Auto

MiscObject	Property	vMYC_PortalStone	Auto

ReferenceAlias	Property	alias_PortalStone	Auto

vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto

;--=== Config variables ===--


;--=== Variables ===--

ObjectReference _kPortalStone

;--=== Events ===--

Event OnInit()
	;Debug.Trace("MYC/PortalStoneQuest: OnInit!")
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	If !PlayerREF.GetItemCount(vMYC_PortalStone) && IsRunning()
		Debug.Trace("MYC/PortalStoneQuest: Adding portal stone to player...")
		_kPortalStone = PlayerREF.PlaceAtMe(vMYC_PortalStone)
		alias_PortalStone.ForceRefTo(_kPortalStone)
		PlayerREF.AddItem(_kPortalStone,1,abSilent = True)
		vMYC_PortalStoneAddedMSG.Show()
	Else
		RegisterForSingleUpdate(1.0)
	EndIf

EndEvent