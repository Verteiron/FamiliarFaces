Scriptname NiOverride Hidden

; Valid keys
; ID - TYPE - Name
; 0 - int - ShaderEmissiveColor
; 1 - float - ShaderEmissiveMultiple
; 2 - float - ShaderGlossiness
; 3 - float - ShaderSpecularStrength
; 4 - float - ShaderLightingEffect1
; 5 - float - ShaderLightingEffect2
; 6 - TextureSet - ShaderTextureSet
; 7 - int - ShaderTintColor
; 8 - float - ShaderAlpha
; 9 - string - ShaderTexture (index 0-8)
; 20 - float - ControllerStartStop (-1.0 for stop, anything else indicates start time)
; 21 - float - ControllerStartTime
; 22 - float - ControllerStopTime
; 23 - float - ControllerFrequency
; 24 - float - ControllerPhase

; Indexes are for controller index (0-255)
; -1 indicates not relevant, use it when not using controller based properties

; Persist True will save the change to the co-save and will automatically re-apply when equipping
; Persist False will apply the change visually until the armor is re-equipped or the game is reloaded (Equivalent to SetPropertyX)

; ObjectReference must be an Actor
; Overrides will clean themselves if the Armor or ArmorAddon no longer exists (i.e. you uninstalled the mod they were associated with)
bool Function HasOverride(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global

Function AddOverrideFloat(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, float value, bool persist) native global
Function AddOverrideInt(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, int value, bool persist) native global
Function AddOverrideBool(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, bool value, bool persist) native global
Function AddOverrideString(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, string value, bool persist) native global
Function AddOverrideTextureSet(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index, TextureSet value, bool persist) native global

; Gets the saved override value
float Function GetOverrideFloat(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
int Function GetOverrideInt(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
bool Function GetOverrideBool(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
string Function GetOverrideString(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global
TextureSet Function GetOverrideTextureSet(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global

; Gets the property straight from the node (Handy if you need the current value if an override D.N.E yet)
float Function GetPropertyFloat(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
int Function GetPropertyInt(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
bool Function GetPropertyBool(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
string Function GetPropertyString(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, int key, int index) native global
;TextureSet is not stored on the node, individual textures are, however.

; Returns whether the specified node could be found for the given parameters
; Debug will report errors to NiOverrides log file
bool Function HasArmorAddonNode(ObjectReference ref, bool firstPerson, Armor arm, ArmorAddon addon, string node, bool debug = false) native global

; Applies all armor properties visually to the actor, this shouldn't be necessary under normal circumstances
Function ApplyOverrides(ObjectReference ref) native global

; ObjectReference must be an Actor (These could work for non-actor objects, untested)
; ADVANCED USE ONLY, THESE DO NOT SELF CLEANUP IF THE NODE IS NOT FOUND
; Returns whether there is an override for this particular node
bool Function HasNodeOverride(ObjectReference ref, bool isFemale, string node, int key, int index) native global

Function AddNodeOverrideFloat(ObjectReference ref, bool isFemale, string node, int key, int index, float value, bool persist) native global
Function AddNodeOverrideInt(ObjectReference ref, bool isFemale, string node, int key, int index, int value, bool persist) native global
Function AddNodeOverrideBool(ObjectReference ref, bool isFemale, string node, int key, int index, bool value, bool persist) native global
Function AddNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index, string value, bool persist) native global
Function AddNodeOverrideTextureSet(ObjectReference ref, bool isFemale, string node, int key, int index, TextureSet value, bool persist) native global

; Return the stored override, returns default (nil) values if the override D.N.E
float Function GetNodeOverrideFloat(ObjectReference ref, bool isFemale, string node, int key, int index) native global
int Function GetNodeOverrideInt(ObjectReference ref, bool isFemale, string node, int key, int index) native global
bool Function GetNodeOverrideBool(ObjectReference ref, bool isFemale, string node, int key, int index) native global
string Function GetNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index) native global
TextureSet Function GetNodeOverrideTextureSet(ObjectReference ref, bool isFemale, string node, int key, int index) native global

; Gets the property straight from the node (Handy if you need the current value if an override D.N.E yet)
float Function GetNodePropertyFloat(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
int Function GetNodePropertyInt(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
bool Function GetNodePropertyBool(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
string Function GetNodePropertyString(ObjectReference ref, bool firstPerson, string node, int key, int index) native global
;TextureSet is not stored on the node, individual textures are, however.

; Applies all node properties visually to the actor, this shouldn't be necessary under normal circumstances
Function ApplyNodeOverrides(ObjectReference ref) native global


; Remove functions do not revert the modified state, only remove it from the save

; Removes ALL Armor based overrides from ALL actors (Global purge)
Function RemoveAllOverrides() native global

; Removes all Armor based overrides for a particular actor
Function RemoveAllReferenceOverrides(ObjectReference ref) native global

; Removes all ArmorAddon overrides for a particular actor and armor
Function RemoveAllArmorOverrides(ObjectReference ref, bool isFemale, Armor arm) native global

; Removes all overrides for a particular actor, armor, and addon
Function RemoveAllArmorAddonOverrides(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon) native global

; Removes all overrides for a particukar actor, armor, addon, and nodeName
Function RemoveAllArmorAddonNodeOverrides(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node) native global

; Removes one particular override from an actor, armor, addon, node name, key, index
Function RemoveOverride(ObjectReference ref, bool isFemale, Armor arm, ArmorAddon addon, string node, int key, int index) native global

; Removes ALL Node based overrides for ALL actors (Global purge)
Function RemoveAllNodeOverrides() native global

; Removes all Node based overrides for a particular actor
Function RemoveAllReferenceNodeOverrides(ObjectReference ref) native global

; Removes all Node based overrides for a particular actor, gender, and nodeName
Function RemoveAllNodeNameOverrides(ObjectReference ref, bool isFemale, string node) native global

; Removes one particular override from an actor, of a particular gender, nodeName, key, and index
Function RemoveNodeOverride(ObjectReference ref, bool isFemale, string node, int key, int index) native global

; Overlay Data
int Function GetNumBodyOverlays() native global
int Function GetNumHandOverlays() native global
int Function GetNumFeetOverlays() native global
int Function GetNumFaceOverlays() native global

int Function GetNumSpellBodyOverlays() native global
int Function GetNumSpellHandOverlays() native global
int Function GetNumSpellFeetOverlays() native global
int Function GetNumSpellFaceOverlays() native global

; Adds all enabled overlays to an Actor (Cannot add to player, always exists for player)
Function AddOverlays(ObjectReference ref) native global

; Returns whether this actor has overlays enabled (Always true for player)
bool Function HasOverlays(ObjectReference ref) native global

; Removes overlays from an actor (Cannot remove from player)
Function RemoveOverlays(ObjectReference ref) native global

; Restores the original non-diffuse skin textures to skin overlays
Function RevertOverlays(ObjectReference ref) native global

; Restores the original non-diffuse skin textures to particular overlay
; Valid masks: Combining masks not recommended
; 4 - Body
; 8 - Hands
; 128 - Feet
Function RevertOverlay(ObjectReference ref, string nodeName, int armorMask, int addonMask) native global

; Restores the original non-diffuse skin textures to all head overlays
Function RevertHeadOverlays(ObjectReference ref) native global

; Restores the original non-diffuse skin textures to particular overlay
; Valid partTypes
; 1 - Face
; Valid shaderTypes
; 4 - FaceTint
Function RevertHeadOverlay(ObjectReference ref, string nodeName, int partType, int shaderType) native global

; Sets a body morph value on an actor
Function SetMorphValue(ObjectReference ref, string morphName, float value) native global

; Gets a body morph value on an actor
float Function GetMorphValue(ObjectReference ref, string morphName) native global

; Clears a body morph value on an actor
Function ClearMorphValue(ObjectReference ref, string morphName) native global

; Clears all body morphs for an actor
Function ClearMorphs(ObjectReference ref) native global

; Updates the weight data post morph value
; only to be used on actors who have morph values set
Function UpdateModelWeight(ObjectReference ref) native global