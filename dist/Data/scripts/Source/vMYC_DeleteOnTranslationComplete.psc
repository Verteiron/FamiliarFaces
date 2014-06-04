Scriptname vMYC_DeleteOnTranslationComplete extends ObjectReference  

Event OnTranslationComplete()
	Utility.Wait(0.1)
	Delete()
EndEvent
