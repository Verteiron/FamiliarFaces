Scriptname vMYC_Trophy_ThaneBanners extends vMYC_TrophyBase
{Display a banner for each city Player is a Thane of.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

Int		Property	TROPHY_THANE_DAWNSTAR 	= 0x00000001	AutoReadonly Hidden
Int		Property	TROPHY_THANE_HJALLMARCH	= 0x00000002	AutoReadonly Hidden
Int		Property	TROPHY_THANE_RIFTEN		= 0x00000004	AutoReadonly Hidden
Int		Property	TROPHY_THANE_WHITERUN	= 0x00000008	AutoReadonly Hidden
Int		Property	TROPHY_THANE_WINTERHOLD	= 0x00000016	AutoReadonly Hidden
Int		Property	TROPHY_THANE_SOLITUDE	= 0x00000032	AutoReadonly Hidden
Int		Property	TROPHY_THANE_MARKARTH	= 0x00000064	AutoReadonly Hidden
Int		Property	TROPHY_THANE_FALKREATH	= 0x00000128	AutoReadonly Hidden

;=== Properties ===--

Form		Property	CityBannerSolitude01	Auto 
Form		Property	CityBannerDawnstar01	Auto 
Form		Property	CityBannerFalkreath01	Auto 
Form		Property	CityBannerHjaalmarch01	Auto 
Form		Property	CityBannerRiften01		Auto 
Form		Property	CityBannerWhiterun01	Auto 
Form		Property	CityBannerWinterhold01	Auto 
Form		Property	DweBanner01				Auto ; Markarth


;=== Variables ===--

;=== Events/Functions ===--

Event OnTrophyInit()

	TrophyName  	= "ThaneBanners"
	TrophyFullName  = "Thane banners"
	TrophyPriority 	= 6
	
	TrophyType 		= TROPHY_TYPE_BANNER
	TrophySize		= TROPHY_SIZE_LARGE
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	
EndEvent

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	
	;FIXME!
	Return 0
EndFunction

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display}
	;If aiDisplayFlags == 2, then the Brotherhood was destroyed
	If aiDisplayFlags 
		DisplayBanner(CityBannerDawnstar01)
		DisplayBanner(DweBanner01)
		DisplayBanner(CityBannerWhiterun01)
		DisplayBanner(CityBannerFalkreath01)
		DisplayBanner(CityBannerHjaalmarch01)
		DisplayBanner(CityBannerRiften01)
		DisplayBanner(CityBannerWinterhold01)
	EndIf	
	
EndEvent

Int Function Remove()
{User code for hide}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation}
	Return 1
EndFunction
