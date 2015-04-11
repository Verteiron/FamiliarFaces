Scriptname vMYC_API_Doppelganger extends vMYC_APIBase Hidden
{Manage saving and loading of Doppelgangers.}

; === [ vMYC_API_Doppelganger.psc ] =======================================---
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; ========================================================---

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry
Import vMYC_Session
Import vMYC_API_Character

;=== Generic Functions ===--

Int Function GetCharacterJMap(String asSID) Global
	Int iRet = -2 ; SID not present
	String sRegKey = "Characters." + asSID
	Int jCharacterData = vMYC_Registry.GetRegObj(sRegKey)
	If jCharacterData
		Return jCharacterData
	EndIf
	Return iRet
EndFunction

;=== Functions - Actorbase/Actor management ===--

ActorBase Function GetAvailableActorBase(Int aiSex, ActorBase akPreferredAB = None, Bool abLeveled = True) Global
{Returns the first available dummy actorbase of the right sex, optionally fetch the preferred one, optionally only choose unleveled ABs.}
	
	ActorBase kDoppelgangerBase = None
	Int jActorbaseMap = GetSessionObj("ActorbaseMap")
	
	If akPreferredAB
		If !JFormMap.GetStr(jActorbaseMap,akPreferredAB) ; If this AB is not already assigned in this session...
			JFormMap.SetStr(jActorBaseMap,akPreferredAB,"Reserved")
			SaveSession()
			Return akPreferredAB
		EndIf
	EndIf
	
	;== If we got this far then the preferred base is either not set or is in use ===--

	Int jActorbasePool = 0
	
	If aiSex ; 0 = m, 1 = f
		If abLeveled
			jActorbasePool = GetRegObj("ActorbasePool.F")
		Else
			jActorbasePool = GetRegObj("ActorbasePool.UF")
		EndIf
	Else
		If abLeveled
			jActorbasePool = GetRegObj("ActorbasePool.M")
		Else
			jActorbasePool = GetRegObj("ActorbasePool.UM")
		EndIf
	EndIf
	
	Int i = JArray.Count(jActorbasePool)
	While i > 0
		i -= 1
		kDoppelgangerBase = JArray.GetForm(jActorBasePool,i) as ActorBase
		If kDoppelgangerBase
			If !JFormMap.GetStr(jActorbaseMap,kDoppelgangerBase) ; If this AB is not already assigned in this session...
				JFormMap.SetStr(jActorBaseMap,kDoppelgangerBase,"Reserved")
				SaveSession()
				Return kDoppelgangerBase
			EndIf
		EndIf
	EndWhile

	Debug.Trace("MYC/API/Doppelganger/GetAvailableActorBase: Couldn't find an available ActorBase!",1)
	;== Either no more are available, or something else went wrong ===--
	Return None
EndFunction

String Function GetSIDForActor(Actor kActor) Global
	If (kActor as vMYC_Doppelganger)
		Return (kActor as vMYC_Doppelganger).SID
	EndIf
	Return ""
EndFunction

Actor Function GetActorForSID(String asSID)
	Int jActorBaseMap = GetSessionObj("ActorbaseMap")
	Int jActorForms = JFormMap.AllKeys(jActorBaseMap)
	Int jActorSIDs = JFormMap.AllValues(jActorBaseMap)
	Int idx = JArray.FindStr(jActorSIDs,asSID)
	If idx > -1
		Return JArray.GetForm(jActorForms,idx) as Actor
	EndIf
	Return None
EndFunction

Function AddMappedActorBase(ActorBase akActorBase, String asSID) Global
	Int jActorBaseMap = GetSessionObj("ActorbaseMap")
	If !jActorBaseMap
		SetSessionObj("ActorbaseMap",JFormMap.Object())
		jActorBaseMap = GetSessionObj("ActorbaseMap")
	EndIf
	JFormMap.SetStr(jActorbaseMap,akActorBase,asSID)
	SaveSession()
EndFunction

Function RemoveMappedActorBase(ActorBase akActorBase, String asSID) Global
	Int jActorBaseMap = GetSessionObj("ActorbaseMap")
	If !jActorBaseMap
		SetSessionObj("ActorbaseMap",JFormMap.Object())
		jActorBaseMap = GetSessionObj("ActorbaseMap")
	EndIf
	JFormMap.RemoveKey(jActorbaseMap,akActorBase)
	SaveSession()
EndFunction

Function RegisterActor(Actor akActor,String asSID = "") Global
	vMYC_Doppelganger kDoppelganger = akActor as vMYC_Doppelganger
	If kDoppelganger && !asSID
		asSID = kDoppelganger.SID
	EndIf
	If !asSID
		Return
	EndIf
	ActorBase kActorBase = akActor.GetActorBase()

	If !HasRegKey("Doppelgangers.Preferred." + asSID + ".ActorBase") 
		SetRegForm("Doppelgangers.Preferred." + asSID + ".ActorBase",kActorBase)
	EndIf
	SetSessionForm("Doppelgangers." + asSID + ".ActorBase",kActorBase)
	SetSessionForm("Doppelgangers." + asSID + ".Actor",akActor)
	AddMappedActorBase(kActorBase,asSID)
EndFunction

Function UnregisterActor(Actor akActor = None,String asSID = "") Global
	ActorBase kActorBase
	If akActor
		kActorBase = akActor.GetActorBase()
		vMYC_Doppelganger kDoppelganger = akActor as vMYC_Doppelganger
		If kDoppelganger && !asSID
			asSID = kDoppelganger.SID
		EndIf
		If !asSID
			Return
		EndIf
	EndIf

	If !kActorBase
		kActorBase = GetSessionForm("Doppelgangers." + asSID + ".ActorBase") as ActorBase
	EndIf
	RemoveMappedActorBase(kActorBase,asSID)
	ClearSessionKey("Doppelgangers." + asSID)
EndFunction

Actor Function CreateDoppelganger(String asSID, Bool abLeveled = True) Global
	Int jCharacterData = GetCharacterJMap(asSID)
	If !jCharacterData
		Debug.Trace("MYC/API/Doppelganger/CreateDoppelganger: Invalid SID!",1)
		Return None
	EndIf

	String sName = GetCharacterName(asSID)
	Int iSex = GetCharacterSex(asSID)
	Race kRace = GetCharacterRace(asSID)

	If sName && iSex > -1 && kRace
		Debug.Trace("MYC/API/Doppelganger/CreateDoppelganger: Going to assign a Doppelganger to " + sName + " (" + kRace.GetName() + ")")
	Else
		Debug.Trace("MYC/API/Doppelganger/CreateDoppelganger: Character " + asSID + " (" + sName + ") is missing vital data, aborting!",1)
		Return None
	EndIf
	ActorBase kDoppelgangerBase = GetAvailableActorBase(iSex,GetRegForm("Doppelgangers.Preferred." + asSID + ".ActorBase") as Actorbase,abLeveled)
	Debug.Trace("MYC/API/Doppelganger/CreateDoppelganger: Target ActorBase for " + sName + " will be " + kDoppelgangerBase + " (" + kDoppelgangerBase.GetName() + ")")
;	;GetRegForm("Doppelgangers.Preferred." + asSID + ".ActorBase")
;	;SetSessionForm("Doppelgangers." + asSID + ".ActorBase",MyActorBase)
	;SetSessionForm("Doppelgangers." + asSID + ".Actor",Self as Actor)
	ObjectReference kNowhere = Game.GetFormFromFile(0x00004e4d,"vMYC_MeetYourCharacters.esp") As ObjectReference ; Marker in vMYC_StagingCell
	Actor kDoppelActor = kNowhere.PlaceAtMe(kDoppelgangerBase) as Actor
	vMYC_Doppelganger kDoppelScript = kDoppelActor as vMYC_Doppelganger
	kDoppelScript.AssignCharacter(asSID)
	Return kDoppelActor
EndFunction

