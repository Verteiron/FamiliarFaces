Scriptname vMYC_Trophy_MiraakMask extends vMYC_TrophyBase
{Player has killed Miraak}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;--=== Properties ===--

Static	Property	vMYC_ShrineDLC2MiraakHelm	Auto

;--=== Variables ===--

Int		iMaskID

;--=== Events/Functions ===--

Function CheckVars()

	BaseX 		= 	-77.0
	BaseY 		= 	 21.0
	BaseZ 		= 	  6.2352
	;AngleX 		= 	-53.7840
	;AngleY 		= 	 18.8350
	;AngleZ 		= 	 13.3018
	AngleX 		= 	-55.7451
	AngleY 		= 	  6.5581
	AngleZ 		= 	  6.0
	Scale 		= 	  1.24
	
	;AngleX0	=	-56.4590    
	;AngleY0	=	 0
	;AngleZ0	=	 0
	
	;+15
	;AngleX1	=	-55.5382
	;AngleY1	=	 12.4580
	;AngleZ1	=	 8
	
	;+30
	;AngleX2	=	-52.5671
	;AngleY2	=	 24.6293
	;AngleZ2	=	 17.0 
	
	TrophyName  	= "DLC02"
	TrophyFullName  = "Miraak's Mask"
	TrophyPriority 	= 2
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_SMALL
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	
EndFunction

Event OnSetTemplate()
	iMaskID = CreateTemplate(vMYC_ShrineDLC2MiraakHelm)
EndEvent

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display}
	If aiDisplayFlags
		DisplayForm(iMaskID)
	EndIf
EndEvent

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	Quest kGoalQuest = Quest.GetQuest("DLC2MQ06") ;Only filled if Dragonborn is loaded
	If kGoalQuest
		Return kGoalQuest.IsCompleted() as Int
	EndIf
	Return 0
EndFunction
