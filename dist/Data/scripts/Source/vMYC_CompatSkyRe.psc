Scriptname vMYC_CompatSkyRe extends vMYC_CompatBase  
{Module for SkyRE compatibility. Right now this just excludes a bunch of Perks.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Properties ===--

Formlist Property vMYC_ModCompatibility_PerkList_Unsafe Auto

;=== Variables ===--

;=== Events/Functions ===--

Bool Function IsRequired()
{Return true if the mod that this module supports is installed.}
	If GetModByName("SkyRe_Main.esp") != 255
		Return True
	EndIf
	Return False
EndFunction

Int Function StartModule()
{User code for startup.}
	AddSkyRePerks()
	Return 1
EndFunction

Int Function StopModule()
{User code for shutdown.}
	Return 1
EndFunction

Int Function UpkeepModule()
{User code for upkeep.}
	If !vMYC_ModCompatibility_PerkList_Unsafe.HasForm(GetFormFromFile(0x1D050DE9,"SkyRe_Main.esp"))
		AddSkyRePerks()
	EndIf
	Return 1
EndFunction

Function CheckVars()
{Any extra variables that might need setting up during OnInit. Will also be run OnGameLoad.}

EndFunction

Function AddSkyREPerks()
;Special thanks to Raulfin for this list!
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D050DE9,"SkyRe_Main.esp")) ; xxxAlchemyAdhesiveExplosives "Adhesives Explosives" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D00FED9,"SkyRe_Main.esp")) ; xxALCAdvancedExplosives "Advanced Explosives" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071E1,"SkyRe_Main.esp")) ; xxxAlchemyBenefactor1 "Benefactor" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071E2,"SkyRe_Main.esp")) ; xxxAlchemyBenefactor2 "Benefactor" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071E3,"SkyRe_Main.esp")) ; xxxAlchemyBenefactor3 "Benefactor" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058218,"Skyrim.esm")) ; Experimenter50 "Experimenter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00105F2A,"Skyrim.esm")) ; Experimenter70 "Experimenter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00105F2B,"Skyrim.esm")) ; Experimenter90 "Experimenter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D2888A5,"SkyRe_Main.esp")) ; xxxALCFieldAlchemy "Field Alchemy" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D00FEDA,"SkyRe_Main.esp")) ; xxxAlchemyFuse "Fuse" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00105F2E,"Skyrim.esm")) ; GreenThumb "Green Thumb" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058215,"Skyrim.esm")) ; Physician "Physician" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071DB,"SkyRe_Main.esp")) ; xxxAlchemyPhysician1 "Physician" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071DF,"SkyRe_Main.esp")) ; xxxAlchemyPhysician2 "Physician" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071E0,"SkyRe_Main.esp")) ; xxxAlchemyPhysician3 "Physician" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D1A2404,"SkyRe_Main.esp")) ; xxxALCPoisonBurst "Poison Burst" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058217,"Skyrim.esm")) ; Poisoner "Poisoner" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071DC,"SkyRe_Main.esp")) ; xxxAlchemyPoisoner1 "Poisoner" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071DD,"SkyRe_Main.esp")) ; xxxAlchemyPoisoner2 "Poisoner" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071DE,"SkyRe_Main.esp")) ; xxxAlchemyPoisoner3 "Poisoner" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x0005821D,"Skyrim.esm")) ; Purity "Purity" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D049673,"SkyRe_Main.esp")) ; xxxAlterationAnimunculi0 "Animunculi" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D049674,"SkyRe_Main.esp")) ; xxxAlterationAnimunculi1 "Animunculi" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D049675,"SkyRe_Main.esp")) ; xxxAlterationAnimunculi2 "Animunculi" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04E298,"SkyRe_Main.esp")) ; xxxAlterationDeepInfusion0 "Deep Infusion" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04E299,"SkyRe_Main.esp")) ; xxxAlterationDeepInfusion1 "Deep Infusion" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D45DA30,"SkyRe_Main.esp")) ; xxxALTMassProduction "Mass Production" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04E803,"SkyRe_Main.esp")) ; xxxAlterationRepairUnit "Repair Unit" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08F263,"SkyRe_Main.esp")) ; xxxBLODispel0 "Dispel" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08F267,"SkyRe_Main.esp")) ; xxxBLODispel1 "Dispel" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0279AB,"SkyRe_Main.esp")) ; xxxBLOQuickReflexes0 "Quick Reflexes" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0279AC,"SkyRe_Main.esp")) ; xxxBLOQuickReflexes1 "Quick Reflexes" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D2A6472,"SkyRe_Main.esp")) ; xxxBLOReplenish0 "Replenish" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D2A6473,"SkyRe_Main.esp")) ; xxxBLOReplenish1 "Replenish" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08F264,"SkyRe_Main.esp")) ; xxxBLOShatter0 "Shatter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08F26A,"SkyRe_Main.esp")) ; xxxBLOShatter1 "Shatter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D035726,"SkyRe_Main.esp")) ; xxxCONBoneMastery0 "Bone Mastery" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D036217,"SkyRe_Main.esp")) ; xxxCONBoneMastery1 "Bone Mastery" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D036219,"SkyRe_Main.esp")) ; xxxCONBoneMastery2 "Bone Mastery" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D03621A,"SkyRe_Main.esp")) ; xxxCONBoneMastery3 "Bone Mastery" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D03621B,"SkyRe_Main.esp")) ; xxxCONBoneMastery4 "Bone Mastery" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D449601,"SkyRe_Main.esp")) ; xxxCONBoneMastery5 "Bone Mastery" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D035725,"SkyRe_Main.esp")) ; xxxCONHarvest0 "Harvest" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0361F9,"SkyRe_Main.esp")) ; xxxCONHarvest1 "Harvest" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0361FA,"SkyRe_Main.esp")) ; xxxCONHarvest2 "Harvest" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000D799E,"Skyrim.esm")) ; SoulStealer "Soul Stealer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D225825,"SkyRe_Main.esp")) ; xxxCONTheUnending "The Unending" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D035727,"SkyRe_Main.esp")) ; xxxCONTonguesOfOld1 "Tongues of Old" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D20CBF7,"SkyRe_Main.esp")) ; xxxCONTonguesOfOld0 "Tongues of Old" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D28B045,"SkyRe_Main.esp")) ; xxxENCAdvancedScripture "Advanced Scripture" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D1A241E,"SkyRe_Main.esp")) ; xxxENCArcaneBurst "Arcane Burst" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D2888A7,"SkyRe_Main.esp")) ; xxxENCBasicScripture "Basic Scripture" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD2B,"SkyRe_Main.esp")) ; xxxEnchantmentDeadlyTouchBase "Deadly Touch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD2C,"SkyRe_Main.esp")) ; xxxEnchantmentDeadlyTouch0 "Deadly Touch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD2D,"SkyRe_Main.esp")) ; xxxEnchantmentDeadlyTouch1 "Deadly Touch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD2E,"SkyRe_Main.esp")) ; xxxEnchantmentDeadlyTouch2 "Deadly Touch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD2F,"SkyRe_Main.esp")) ; xxxEnchantmentDeadlyTouch3 "Deadly Touch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD30,"SkyRe_Main.esp")) ; xxxEnchantmentDeadlyTouch4 "Deadly Touch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD31,"SkyRe_Main.esp")) ; xxxEnchantmentDeadlyTouch5 "Deadly Touch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D28B046,"SkyRe_Main.esp")) ; xxxENCElaborateScripture "Elaborate Scripture" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF659,"SkyRe_Main.esp")) ; xxxENCElementalBombard0 "Elemental Bombard" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D3DF04E,"SkyRe_Main.esp")) ; xxxENCElementalBombard1 "Elemental Bombard" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000BEE97,"Skyrim.esm")) ; Enchanter00 "Enchanter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C367C,"Skyrim.esm")) ; Enchanter20 "Enchanter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C367D,"Skyrim.esm")) ; Enchanter40 "Enchanter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C367E,"Skyrim.esm")) ; Enchanter60 "Enchanter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C367F,"Skyrim.esm")) ; Enchanter80 "Enchanter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08A6B6,"SkyRe_Main.esp")) ; xxxENCExtraEffect1 "Extra Effect" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08A6B7,"SkyRe_Main.esp")) ; xxxENCExtraEffect2 "Extra Effect" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007772,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential0 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007773,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential1 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007774,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential2 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007775,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential3 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007776,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential4 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04C1D3,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential5 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04C1D4,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential6 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04C1D5,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential7 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04C1D6,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential8 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04C1D7,"SkyRe_Main.esp")) ; xxxEnchantingHiddenPotential9 "Hidden Potential" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D3DF054,"SkyRe_Main.esp")) ; xxxENCElementalBombard1NeuralgiaPerk "Neuralgia" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD0B,"SkyRe_Main.esp")) ; xxxEnchantmentPrismBase "Prismatic Enchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD0F,"SkyRe_Main.esp")) ; xxxEnchantmentPrism0 "Prismatic Enchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD10,"SkyRe_Main.esp")) ; xxxEnchantmentPrism1 "Prismatic Enchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD11,"SkyRe_Main.esp")) ; xxxEnchantmentPrism2 "Prismatic Enchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD12,"SkyRe_Main.esp")) ; xxxEnchantmentPrism3 "Prismatic Enchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD13,"SkyRe_Main.esp")) ; xxxEnchantmentPrism4 "Prismatic Enchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05BD14,"SkyRe_Main.esp")) ; xxxEnchantmentPrism5 "Prismatic Enchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D28D80F,"SkyRe_Main.esp")) ; xxxENCSagesScripture "Sage's Scripture" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058205,"Skyrim.esm")) ; PerfectTouch "Ace's Mark" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058208,"Skyrim.esm")) ; Locksmith "Locksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x0005820A,"Skyrim.esm")) ; GoldenTouch "Nose For Coin" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D012A52,"SkyRe_Main.esp")) ; xxxSpellUnlockAllLocksPerk "Open all locks" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D012A50,"SkyRe_Main.esp")) ; xxxSpellUnlockEasyLocksPerk "Open easy locks (Novice, Apprentice)" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D012A51,"SkyRe_Main.esp")) ; xxxSpellUnlockAdvancedLocksPerk "Open most locks (Adept, Expert)" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058201,"Skyrim.esm")) ; Misdirection "Snatch" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00105F26,"Skyrim.esm")) ; TreasureHunter "Treasure Hunter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071E8,"SkyRe_Main.esp")) ; xxxFINTreasureHunter1 "Treasure Hunter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0071E9,"SkyRe_Main.esp")) ; xxxFINTreasureHunter2 "Treasure Hunter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00018E6A,"Skyrim.esm")) ; LightFingers20 "Light Fingers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00018E6B,"Skyrim.esm")) ; LightFingers40 "Light Fingers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00018E6C,"Skyrim.esm")) ; LightFingers60 "Light Fingers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00018E6D,"Skyrim.esm")) ; LightFingers80 "Light Fingers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000BE124,"Skyrim.esm")) ; LightFingers00 "Light Fingers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D383DF2,"SkyRe_Main.esp")) ; xxxHIWBacklash0 "Backlash" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D383DF4,"SkyRe_Main.esp")) ; xxxHIWBacklash1 "Backlash" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D383DF6,"SkyRe_Main.esp")) ; xxxHIWBacklash2 "Backlash" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0570EE,"SkyRe_Main.esp")) ; xxxHIWBladeBarrier0 "Blade Barrier" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0570F0,"SkyRe_Main.esp")) ; xxxHIWBladeBarrier1 "Blade Barrier" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0570F1,"SkyRe_Main.esp")) ; xxxHIWBladeBarrier2 "Blade Barrier" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D1089DB,"SkyRe_Main.esp")) ; xxxILLAnalysis0 "Analysis" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D1089DC,"SkyRe_Main.esp")) ; xxxILLAnalysis1 "Analysis" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04CCB0,"SkyRe_Main.esp")) ; xxxLightArmorSwiftCounter "Swift Counter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04CCB3,"SkyRe_Main.esp")) ; xxxLightArmorSwiftCounterInvincibility "Swift Counter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0565F5,"SkyRe_Main.esp")) ; xxxLIWKendo0 "Kendo" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0565F6,"SkyRe_Main.esp")) ; xxxLIWKendo1 "Kendo" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0565F7,"SkyRe_Main.esp")) ; xxxLIWKendo2 "Kendo" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0570F4,"SkyRe_Main.esp")) ; xxxLIWMasterfulFencer0 "Masterful Fencer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0880F5,"SkyRe_Main.esp")) ; xxxLIWMasterfulFencer1 "Masterful Fencer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0880F6,"SkyRe_Main.esp")) ; xxxLIWMasterfulFencer2 "Masterful Fencer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D055AF6,"SkyRe_Main.esp")) ; xxxLIWSharksJaw1OLD "Shark's Jaw" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D055AF7,"SkyRe_Main.esp")) ; xxxLIWSharksJaw2OLD "Shark's Jaw" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D086097,"SkyRe_Main.esp")) ; xxxLIWStyleSorcerersWrath "Sorcerer's Wrath" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF670,"SkyRe_Main.esp")) ; xxxMARAdvancedMissilecraft0 "Advanced Missilecraft" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF671,"SkyRe_Main.esp")) ; xxxMARAdvancedMissilecraft1OLD "Advanced Missilecraft" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF6A4,"SkyRe_Main.esp")) ; xxxMARAdvancedMissilecraft1 "Advanced Missilecraft" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D3DF04D,"SkyRe_Main.esp")) ; xxxMARAdvancedMissilecraft2 "Advanced Missilecraft" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF6A1,"SkyRe_Main.esp")) ; xxxMARArbalest "Arbalest" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF6A2,"SkyRe_Main.esp")) ; xxxMARLightweightConstruction "Lightweight Construction" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF657,"SkyRe_Main.esp")) ; xxxMARBallistics "Ballistics" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058F61,"Skyrim.esm")) ; EagleEye30 "Eagle Eye" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D008D04,"SkyRe_Main.esp")) ; xxxMAREagleEye1 "Eagle Eye" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF6A5,"SkyRe_Main.esp")) ; xxxMAREngineer "Engineer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D059157,"SkyRe_Main.esp")) ; xxxMARPowerDraw0 "Power Draw" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05915C,"SkyRe_Main.esp")) ; xxxMARPowerDraw1 "Power Draw" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05915D,"SkyRe_Main.esp")) ; xxxMARPowerDraw2 "Power Draw" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05915E,"SkyRe_Main.esp")) ; xxxMARPowerDraw3 "Power Draw" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05915F,"SkyRe_Main.esp")) ; xxxMARPowerDraw4 "Power Draw" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF6A0,"SkyRe_Main.esp")) ; xxxMARRecurve "Recurve" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0AF6A3,"SkyRe_Main.esp")) ; xxxMARSilencer "Silencer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00103ADA,"Skyrim.esm")) ; SteadyHand40 "Steady Hand" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00103ADB,"Skyrim.esm")) ; SteadyHand60 "Steady Hand" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058216,"Skyrim.esm")) ; Benefactor "Benefactor" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D06F11E,"SkyRe_Main.esp")) ; xxxRestorationBeaconOfLight0 "Beacon Of Light" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D06F11F,"SkyRe_Main.esp")) ; xxxRestorationBeaconOfLight1 "Beacon Of Light" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D06D5FE,"SkyRe_Main.esp")) ; xxxRestorationPatron "Patron" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x0005218E,"Skyrim.esm")) ; ArcaneBlacksmith "Arcane Artisan" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE0,"SkyRe_Main.esp")) ; xxxSmithingArmorer0 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE9,"SkyRe_Main.esp")) ; xxxSmithingArmorer1 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CEA,"SkyRe_Main.esp")) ; xxxSmithingArmorer2 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CEB,"SkyRe_Main.esp")) ; xxxSmithingArmorer3 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CEC,"SkyRe_Main.esp")) ; xxxSmithingArmorer4 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CED,"SkyRe_Main.esp")) ; xxxSmithingArmorer5 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CEE,"SkyRe_Main.esp")) ; xxxSmithingArmorer6 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CEF,"SkyRe_Main.esp")) ; xxxSmithingArmorer7 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CF0,"SkyRe_Main.esp")) ; xxxSmithingArmorer8 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CF1,"SkyRe_Main.esp")) ; xxxSmithingArmorer9 "Armorer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CDE,"SkyRe_Main.esp")) ; xxxSmithingBlacksmith0 "Blacksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CDF,"SkyRe_Main.esp")) ; xxxSmithingBlacksmith1 "Blacksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE1,"SkyRe_Main.esp")) ; xxxSmithingBlacksmith2 "Blacksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE2,"SkyRe_Main.esp")) ; xxxSmithingBlacksmith3 "Blacksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE3,"SkyRe_Main.esp")) ; xxxSmithingBlacksmith4 "Blacksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE4,"SkyRe_Main.esp")) ; xxxSmithingWeaponsmith5 "Blacksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE5,"SkyRe_Main.esp")) ; xxxSmithingWeaponsmith6 "Blacksmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D054FF5,"SkyRe_Main.esp")) ; xxxSmithingDeepSilver "Deep Silver" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058F75,"Skyrim.esm")) ; Allure "Meltdown" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000581E2,"Skyrim.esm")) ; KindredMage "Tradecraft" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0513EE,"SkyRe_Main.esp")) ; xxxSmithingTreasurecraft "Treasurecraft" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE6,"SkyRe_Main.esp")) ; xxxSmithingWeaponsmith7 "Weaponsmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE7,"SkyRe_Main.esp")) ; xxxSmithingWeaponsmith8 "Weaponsmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D007CE8,"SkyRe_Main.esp")) ; xxxSmithingWeaponsmith9 "Weaponsmith" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D05C827,"SkyRe_Main.esp")) ; xxxSmithingWeavingMill "Weaving Mill" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D046599,"SkyRe_Main.esp")) ; xxxSNEAmbush0 "Ambush" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D04659A,"SkyRe_Main.esp")) ; xxxSNEAmbush1 "Ambush" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D002DB0,"SkyRe_Main.esp")) ; xxxSNEAssassinate "Assassinate" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0068E7,"SkyRe_Main.esp")) ; xxxSNEKnockout "Knockout" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D03804E,"SkyRe_Main.esp")) ; xxxSNEKillSleepingPerk "Last Breath" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D037D35,"SkyRe_Main.esp")) ; xxxSNEThiefsToolbox0 "Thief's Toolbox" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D093336,"SkyRe_Main.esp")) ; xxxSNEThiefsToolbox1 "Thief's Toolbox" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058F72,"Skyrim.esm")) ; Bribery "Bribery" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D09D5DF,"SkyRe_Main.esp")) ; xxxSPEGrandFacade "Grand Facade" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000BE128,"Skyrim.esm")) ; Haggling00 "Haggling" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C07CE,"Skyrim.esm")) ; Haggling20 "Haggling" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C07CF,"Skyrim.esm")) ; Haggling40 "Haggling" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C07D0,"Skyrim.esm")) ; Haggling60 "Haggling" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x000C07D1,"Skyrim.esm")) ; Haggling80 "Haggling" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00105F29,"Skyrim.esm")) ; Intimidation "Intimidation" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0097D5,"SkyRe_Main.esp")) ; xxxSPELeadersVoice "Leader's  Voice" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D1EC8BF,"SkyRe_Main.esp")) ; xxxSPELoyalty0 "Loyalty" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D1EC8C0,"SkyRe_Main.esp")) ; xxxSPELoyalty1 "Loyalty" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x00058F7A,"Skyrim.esm")) ; Merchant "Merchant" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x001090A2,"Skyrim.esm")) ; Persuasion "Persuasion" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D240BE4,"SkyRe_Main.esp")) ; xxxSPEStrengthInNumbers0 "Strength In Numbers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D240BE5,"SkyRe_Main.esp")) ; xxxSPEStrengthInNumbers1 "Strength In Numbers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D240BE6,"SkyRe_Main.esp")) ; xxxSPEStrengthInNumbers2 "Strength In Numbers" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D1EC8E2,"SkyRe_Main.esp")) ; xxxSPETradesOfWar "Trades Of War" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D090D7F,"SkyRe_Main.esp")) ; xxxWAYAwareness "Awareness" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08E223,"SkyRe_Main.esp")) ; xxxWAYBondsWithNature "Bonds With Nature" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08E239,"SkyRe_Main.esp")) ; xxxWAYGatherer0 "Gatherer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08FD3A,"SkyRe_Main.esp")) ; xxxWAYGatherer1 "Gatherer" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD2B,"SkyRe_Main.esp")) ; xxxWAYHuntingGrounds0 "Hunting Grounds" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD2C,"SkyRe_Main.esp")) ; xxxWAYHuntingGrounds1 "Hunting Grounds" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD26,"SkyRe_Main.esp")) ; xxxWAYLegcutter "Legcutter" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08DCAC,"SkyRe_Main.esp")) ; xxxWAYLoyalty0 "Loyality" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08E237,"SkyRe_Main.esp")) ; xxxWAYLoyalty1 "Loyalty" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D08E238,"SkyRe_Main.esp")) ; xxxWAYLoyalty2 "Loyalty" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D09029D,"SkyRe_Main.esp")) ; xxxWAYNaturalization0 "Naturalization" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D09029F,"SkyRe_Main.esp")) ; xxxWAYNaturalization1 "Naturalization" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0902A0,"SkyRe_Main.esp")) ; xxxWAYNaturalization2 "Naturalization" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0902A1,"SkyRe_Main.esp")) ; xxxWAYNaturalization3 "Naturalization" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D0902A2,"SkyRe_Main.esp")) ; xxxWAYNaturalization4 "Naturalization" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD25,"SkyRe_Main.esp")) ; xxxWAYSilentHunt0 "Silent Hunt" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD27,"SkyRe_Main.esp")) ; xxxWAYSilentHunt1 "Silent Hunt" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD28,"SkyRe_Main.esp")) ; xxxWAYSilentHunt2 "Silent Hunt" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD29,"SkyRe_Main.esp")) ; xxxWAYSilentHunt3 "Silent Hunt" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D19AD2A,"SkyRe_Main.esp")) ; xxxWAYSilentHunt4 "Silent Hunt" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D093E08,"SkyRe_Main.esp")) ; xxxWAYTracker0 "Tracker" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D094E56,"SkyRe_Main.esp")) ; xxxWAYTracker1 "Tracker" 
	vMYC_ModCompatibility_PerkList_Unsafe.AddForm(GetFormFromFile(0x1D094E57,"SkyRe_Main.esp")) ; xxxWAYTracker2 "Tracker" 

EndFunction
