#FamiliarFaces

Skyrim mod that allow characters to be shared between different playthroughs.

This is a development version of Familiar Faces. There are bugs, possibly severe ones. You should be comfortable 
installing Skyrim mods and have a basic grasp of things like directory structures, 7z files, and load order.

This is a closed test. No NDAs to sign, but I ask that you do not redistribute these files, post public YouTube videos of 
it in action, etc.

BACK UP YOUR SAVED GAMES, YOUR DATA DIRECTORY, YOUR MOD LIST, LOAD ORDER, INI FILES, EVERYTHING BEFORE INSTALLING THIS! 
I will not help you pick up the pieces if it destroys your carefully laid-out load order or indeed fries your entire computer because you didn't make a back-up first.

###Reporting a bug

Please check the list of Quirks and Known Bugs below before reporting!

If the game crashed:

*   Make a copy of the Papyrus log and all contents of Data/vMYC before you relaunch the game.
*   Send those files to me, along with any problems you noticed before the crash and what you did leading up to it.
*   If you can consistently reproduce the crash, be sure to tell me how.

If not:

*   Take screenshots if they will help demonstrate the bug in question.
*   Make a copy of the same files as listed above AS SOON AS YOU EXIT THE GAME. It's important that you make a copy of 
     the files before you start playing again, as they will get changed the next time you start the game up.
*   Send me the copied files and a report of what the bug was, what you were doing when it happened, and a brief outline 
     of the steps that brought you to that point.
*   If you can reliably reproduce it, tell me how.

Send bug reports to: verteiron+ffbugs@gmail.com.

###Requirements

*   Latest version of Skyrim - Dawnguard and Dragonborn are supported but not required.
*   SKSE 1.7.0 - Not included. Download and install if you're not using it already. Earlier versions WILL NOT WORK. The mod will notice if SKSE is missing and will shut down.
*   SkyUI 4.1 - Not included. Required for using MCM.
*   JContainers 0.66 or higher - Included. This is an SKSE plugin that is packaged with this testing edition.
*   CharGen.dll - Included. This is a special testing version of Expired's CharGen Extender SKSE plugin. See the Warnings section below. If you are running the release versions of CharGen Extender or RaceMenu, BACK THEM UP BEFORE INSTALLING FAMILIAR FACES.

###Compatibility

*   Dawnguard and Dragonborn are supported but not required.
*   Enhanced Character Edit (ECE) is NOT compatible with Familiar Faces and likely won't be any time in the near future. This is not due to any particular flaw in ECE, it just uses a different system than CharGen Extender, which is what I'm relying on.
*   Body replacer mods such CBBE should be compatible. Face replacer mods should work (provided they don't rely on ECE), but exported characters will probably not load properly if the face-altering mod is removed.
*   Mods that add NIOverride overlays (body tattoos, scars, glowing face tattoos, etc) to RaceMenu will be supported, but don't work yet.
*   Some ENB setups may interfere with ImageSpaceOverrides, meaning some animations that normally fade to white to hide animation glitches will not do so. Please let me know if you're using ENB before reporting animation bugs.

###Testing setup

If your current mod setup is stable, feel free to use it with Familiar Faces. Please make sure it is stable, though. If you find a bug, I may ask you to try to reproduce without certain mods loaded, so be sure you know how to enable/disable mods on your load list.

If you find a bug, it will be really helpful to have a Papyrus log to send me so I can try to figure out what happened. Make sure the following settings are present in your Skyrim.ini:
```ini
[Papyrus] 
EnableLogging=1 
EnableTrace=1 
LoadDebugInformation=1
```

The Papyrus logs will be located in your Documents folders under My Games/Skyrim/Logs/Script/ and will be named Papyrus.0.log.

###Installation

You can use NMM to install the mod from the 7z file. It should also work with Mod Organizer, but be aware that files will be created in MO's Override directory during gameplay. This is normal but it makes MO show a warning. If you need to send me the contents of Data/vMYC, you'll have to pull them from MO's Override directory instead of your Skyrim installation.

You can install manually simply by extracting the 7z file to the Skyrim/Data directory.

###Uninstallation

Make sure all followers provided by Familiar Faces are dismissed from your service before removing the mod.

If you plan to reinstall the mod, leave the Data/vMYC directory intact or at least back it up. It contains all the saved character data. Otherwise...

If you used NMM to install, uninstallation should work but may leave some files behind. If you used MO, files may remain in your Override directory.

Search for and remove ALL files and folders in Skyrim/Data that begin with "vMYC". Remove JContainers.dll and the included version of CharGen.dll if you aren't using them for any other mods.

###Getting started

Shortly after starting or loading a game, you should receive a Portal Stone in your inventory. You can use that stone from your Inventory (under misc items) to warp to the Shrine of Heroes. Activate the "Tome of the Dragonborn" in front of an empty shrine to save your character there. The save process will take some time, dependent on how many skills, perks, and inventory items your character has.

Now load up a different game, use the Portal Stone (there may be a delay before it gets placed in your inventory, just wait), and you can open the Tome of your saved character to send them into the world. They will have a default spawn point which can be changed from within MCM. Upon talking to them, you should be able to recruit them as followers.

After that, just play around with your imported character as a follower!
What to test first (aka the sanity check)

This early release basically serves to make sure the core functionality is working across multiple computer and mod setups (within reason). Please check for all of the following and report if ANY of them aren't working properly:

*   The Portal Stone is placed in your inventory shortly after starting or loading a game. This may take a minute, see Quirks.
*   The Portal Stone warps you into the Shrine, and the central portal of the Shrine warps you back to where you used the stone. An animation should play in both instances.
*   The books allow you to save your character.
*   The save animation is relatively smooth and does not take longer than about 60 seconds.
*   After saving, various trophies should appear in the shrine based on what side-quests you have completed. Most of these should be obvious. A complete list is given below.
*   Character statues should be an exact duplicate of the player. Face tattoos, dirt, scars, eye color, hair style and color (including mod-provided styles and custom colors from RaceMenu), and skin tones should match exactly. The Shrine statues are oversized on purpose, but when brought into the world the character should be the correct height.
*   If you have customized/named armor and weapons equipped, they should be duplicated exactly as well, with tempering and any custom enchantments intact. This can be checked by recruiting the character and opening the trade menu. Or make them non-essential, kill them, and loot them. You monster. Equipped armor and weapons provided by installed mods should also be duplicated.
*   The character should have all the same ammo and most of the same spells as the player.
*   Upon entering the Shrine from another saved game, all saved characters should look correct and be loaded in the same alcove they were saved in.
*   Characters can be summoned into the world via the book from other saves. The book should open and the character should vanish from the Shrine.
*   You should get a quest called Familiar Faces, with a marker pointing to your character's location. This marker should vanish once they have been recruited.
*   Characters can be recruited as Followers once located in the world. If the recruiting dialog doesn't appear, see the Known Problems section before reporting a bug.
*   Characters can be "banished" back to the shrine by closing their book again. This should remove them from the world and place them back in their Shrine in a mannequin pose.
*   SkyUI's MCM can be used to control the character's class (how their points get distributed based on the player's level), spawn point, and voicetype. You can also use the MCM to warp to the character's location to speed things up.

If the mod does all of the above, everything is working as it should! Please let me know if this is the case, and continue to play with the mod to find bugs or issues!
