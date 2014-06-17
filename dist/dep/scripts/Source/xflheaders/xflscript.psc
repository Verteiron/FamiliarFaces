Scriptname XFLScript extends Quest Conditional

int Property PLUGIN_EVENT_CLEAR_ALL = -1 Autoreadonly
int Property PLUGIN_EVENT_WAIT = 0x04 Autoreadonly
int Property PLUGIN_EVENT_SANDBOX = 0x05 Autoreadonly
int Property PLUGIN_EVENT_FOLLOW = 0x03 Autoreadonly
int Property PLUGIN_EVENT_ADD_FOLLOWER = 0x00 Autoreadonly
int Property PLUGIN_EVENT_REMOVE_FOLLOWER = 0x01 Autoreadonly
int Property PLUGIN_EVENT_REMOVE_DEAD_FOLLOWER = 0x02 Autoreadonly


FormList Property XFL_FollowerList  Auto  

Function XFL_SendPluginEvent(int akType, ObjectReference akRef1 = None, ObjectReference akRef2 = None, int aiValue1 = 0, int aiValue2 = 0)
EndFunction

Function XFL_AddFollower(Actor FollowerActor)
EndFunction

Function XFL_RemoveFollower(Actor follower, Int iMessage = 0, Int iSayLine = 1)
EndFunction