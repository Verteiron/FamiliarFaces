Familiar Faces 1.1.1

1.1 has been released!


Version 1.1 requires JContainers 3.1.0 or higher! Install it BEFORE upgrading, or you will risk losing character data!


Upgrading from 1.0.x


Make absolutely certain you have installed JContainers 3.1.0 or higher. You'll also want to have RaceMenu 2.9.1 or higher. Just install the new Familiar Faces on top of the current one (if you're using Mod Organizer, it should be safe to use "Merge" instead of "Replace"). The first time you load a game that was saved with 1.0.x installed, your Shrine will shut down and restart. This may take up to a minute if you have 12 characters loaded. Characters you have with you may disappear. If this happens, you can bring them back by visiting the Shrine or using the Shrine page of MCM to re-summon them. Their old custom location may be lost, as well, so be sure to assign them a Hangout! Once JContainers has been upgraded you MUST upgrade FF, as the older version will not work with the new version of JContainers.


New features in 1.1.0


Hangout Manager

This replaces the old, half-finished custom Location with a customizable Hangout system for controlling where your characters live when they're imported.

    A character will have the location where they used the Portal Stone saved in their character file, and will appear there by default when imported to another game.
    All imported Hangouts are viewable via MCM. Any character may be assigned to any Hangout, and in most cases multiple characters may be assigned to a single Hangout. In other words, those of you wanting to build an army of Blades or Companions or Wizards will now be able to do so.
    Additional custom Hangouts may be created by simply traveling to the location and using the Portal stone a second time. You will have the option to add the current location as a Hangout.
    Characters may also be set to wander from town to town, rather than living in a single place.
    Your Hangouts are stored in their own file and are persistent throughout all your saved games. 



Better NPC behavior

Characters will now use IdleMarkers (wall-leaning, etc) and exhibit more appropriate behavior based on where their Hangout is.

    Towns or cities The character will wander from shop to shop, visit people in open houses, visit an Inn or Temple if there is one, and sleep if they can find a free bed.
    Guild homes Characters assigned to Hangouts in or near Guild locations will behave for the most part like members of that Guild's faction, eating and sleeping there if there are available places for them. Note that they will attempt to do this even if the Guild is not open or friendly to you in your current playthrough.
    Dungeons Characters that are friendly to you will wait just inside the entrance of Dungeon Hangouts. They may also try to enter deeper into the Dungeon if they were originally saved there, but they will not proceed if the way is blocked by doors they can't open or unlock, such as Puzzle or Dragon Claw Doors.
    Wanderers Instead of living in a single place, a character can be set to wander from city to city. Characters summoned to the world without a Hangout assigned to them will do this by default.
    Preset locations Some preset Hangouts have customized AI packages that will give the imported character extra behaviors suited to that location. For example, a character imported to the Winterhold College will spend some time practicing magic in the Hall of Elements, or reading in the Arcaneum. These custom behaviors will only apply to the first character assigned to a preset Hangout, though; additional characters will use the more general AI packages described above. As these are quite time-consuming to create, there are not many of them.



Armor dyes

    Dyeable armor from the newest versions of RaceMenu/NIOverride is now fully supported. RaceMenu 2.9.1 or higher is required for this!



Character features

    Auto-leveling may now be disabled. This allows your character to retain the exact same stats they were saved with, regardless of your level.
    It is now possible to recruit yourself. To do this, simply check the "Summon" box next to your character's name on the Shrine page of the MCM.
    You may now enforce the character's original armor, so that they will never equip any other gear than what they were saved with, or have them use their original gear to fill in any missing slots in their current setup.



Spells

    ALL Spells are now saved with the character data. Spell filtering is now done at the time of loading.
    A global option may be set to always allow characters to use self-healing and armor spells, if they know them, regardless of whether they are allowed to use other magic.
    There are now MCM options to load Spells provided by mods. "Select mods" will load certain mods with preset compatibility, or use spells explicitly listed as compatible by the mod's author (see Spell Compatibility section below). "All mods" will attempt to load all spells a character had when they were saved. This option is NOT recommended for general use, as many mod-provided spells are utilities or quest-related abilities that are designed for the player alone to use.



Shouts

    Global option has been added to automatically disable Shouts when your characters are in a town. This really helps with keeping the guards out of your hair.
    You may now restrict your characters to only using Shouts your own character has unlocked.
    The "Call Storm" and "Dragon Aspect" shouts may now be permanently disabled for all imported characters.



MCM

    A report of what mods are required to properly recreate a character can be viewed from that character's MCM page.
    Shrine of Heroes page now allows you to summon your character from the Shrine without actually visiting it. This can also be used to summon your own character as a doppelgänger, a much-demanded feature!
    Shrine of Heroes page can now be used to reset individual Alcoves by scrolling to the bottom of the character list. This can be used to clear a locked-up Alcove.
    Tracking can now be switch on or off for all characters at once.
    Added Hangouts, Global Options and Debug pages to the MCM. 



Miscellaneous

    Config, Shrine and Hangout files are now stored in the My Games/Skyrim folder rather than in Data/vMYC.
    Faster initial loading of character files.
    Spells, Perks, Shouts, and non-equipped gear are now deferred until after the character is actually summoned into the world. This greatly reduces the initial load time and reduces appearance problems in the Shrine.
    Character files now include a list of the mods required for their appearance and armor to be recreated correctly. Any missing mods will be shown in the character's MCM panel. If the required mods are installed later, the character's appearance will be updated.
    The mod now checks for write access to the Data/vMYC folder before attempting to start up.
    Notify player if a character's .slot, .dds or .nif (if using external heads) is missing and will optionally auto-delete the character.
    Character tracking should now be auto-disabled when they are recruited as a follower.
    Reduced duration of the character glow in the Shrine to bring it more in line with trophies.



Compatibility

    FF should now work better with AFT. Note: This is accomplished by disabling nearly all of the stat, spell, and perk assignments provided by Familiar Faces in lieu of AFT's handling of these options. AFT *must* be used to manage these if it is installed!
    FF now works with the latest beta of EFF and should update the names in the UI panels much more quickly.
    Mods that add spells to the game may now tell FF whether they're safe to load on imported NPCs. See "Spell Compatibility Lists" below.



Fixes in 1.1.0


Tons. The following list is not exhaustive. Pretty much every part of the mod got at least some revisions, and several modules were completely rewritten.

Character Manager

    Fixed various threading-related issues during the initial startup and loading of characters. This should both speed up the initial load and prevent odd problems like multiple characters' data being assigned to a single actor.
    Characters now dismount before applying their appearance, which should prevent physics bugs.
    When a Character's actor is deleted or otherwise unloaded, their corresponding FaceGen DDS and NIFs are deleted as well. This is needed when using Racemenu's External Head/ECE support.
    Fixed actors sometimes showing up naked.



Shrine of Heroes

    Complete rewrite of the Shrine/Alcove code. New system is much faster, more stable, much more difficult to get into an invalid configuration, and attempts to self-correct if it does.
    Deleting the Shrine file now correctly empties out all Alcoves on the next load and resets the Shrine to its default state.
    Validation is now done for things like the lighting state, the book's open/closed state, etc.
    An Alcove that gets stuck in an invalid state for a long time will generate a warning message, so it can be cleared via MCM if necessary. *Note:* Individual Alcoves can be reset without resetting the entire Shrine! To do this, go to the Shrine MCM page, scroll to the bottom of the character list for the Alcove that is malfunctioning, and choose "* RESET *". Exit the MCM and wait for the Alcove to clear, then you may assign it as usual.
    Portal Stone is now given to the character only once the initial character loading process is complete. This may take as long as two minutes for the first load.
    Alcoves that are emptied via MCM now banish their characters to limbo, where the character's Actor will be deleted after 15 seconds of being unclaimed.
    Alcoves that are erased using "Destroy the book" now delete their Actors and corresponding FormID-based DDS and NIFs immediately.
    Characters with an invalid Race (due to missing mods) no longer hang the load process.
    Fixed book names not always showing up after saving.
    Added an option to break out of the Save process after 60 seconds, and every 30 seconds thereafter, just in case the Save hangs (which should never happen, of course!)



MCM

    Fixed "Gopher's Bug", where making a Follower into a Foe would break their Follower AI permanently. Current Followers now cannot be made into foes ;)
    Fixed numerous instances of options not being updated or disabled correctly.
    Most options now apply only after MCM is closed, rather than immediately. This should fix the problem with MCM locking up from time to time.



Miscellaneous

    Frozen giant versions of your characters should no longer appear at your wedding, though other imported characters may.
    FF's startup is now deferred until MQ101 (Unbound) is completed. This can be overridden with ```set vMYC_WaitForMQ to 0```



What Familiar Faces does


Familiar Faces allows you to create persistent copies of your character that exist independently of saved games. You can then visit those characters from any of your saved games; send them into the world to interact with, recruit as followers, marry or kill.

What gets saved

    Character's appearance. The imported character should look exactly like their original self. All morphs, skins, and replacers supported by RaceMenu are supported by Familiar Faces because they use the same system. This includes custom colors, body tattoos, glowing marks and other overlay-specific features.
    Imported characters will retain all equipped armor, including names and customizations if any are present, as well as all custom weapons both equipped and in inventory. This includes weapons and armor provided by other mods. Items that are un-droppable due to being Quest objects may not be copied.
    All ammunition in inventory, including crossbow bolts and ammunition provided by other mods.
    Imported characters will have most of their spell list available, provided the spells are from the vanilla game or official DLC. The spell list can be restricted by school through MCM.
    Imported characters retain and will use all Shouts they learned, though the list is trimmed slightly for compatibility purposes. New: Call Storm and Dragon Aspect may now be disabled via the Global Options MCM page.
    Imported characters retain all perks they have learned. Some perks may have their effects disabled for compatibility purposes, but most will function as intended.


What won't get saved

    Gold and other items, such as potions and scrolls. Support for potions, possibly even custom potions, is planned in a future release. Most other inventory items can be transferred (from a technical standpoint) but there are good reasons not to do so. Full inventory transfer may become available as an option if there is demand.
    Certain perks and shouts are either ignored or disabled for compatibility reasons. So far these include: Slow Time, Kyne's Peace, and the dragon-summoning Shouts. Perks that improve decapitation odds are disabled when the imported character is fighting the player, since decapitating the player causes a crash. Perks that do player-specific things like slow time while blocking are imported, but ignored by the game.
    Most Spells added by unofficial DLCs/mods. Sorry, as a spell-writer and collector, this one pains me too, but it was necessary. A huge number of non-vanilla spells are designed only for use by the player, or are abilities added and used by other mods that are only intended for use on the player. Adding these to NPCs caused a huge number of problems. NEW: There is now support for adding safe mod-provided spells to a central compatibility list, either by me or other mods authors. See "Spell Compatibility Lists" below for more info on this!



What Familiar Faces does not do

    Familiar Faces is not a follower manager. It is intended to be used alongside another follower manager such as EFF.
    Familiar Faces is not a custom follower generator, although it can certainly be used that way. Future features are going to be aimed at improving the playability and accuracy of character duplication, not at making character design faster, easier, or more complete.
    Familiar Faces is not a method for transferring items between save games. Again, it can be used this way (by pickpocketing or trading with your imported characters) but it will never be the mod's first priority. I do, however, plan to add a shared chest of some kind that will allow you to transfer additional customized items between saves.



Requirements

    Latest version of Skyrim - Dawnguard and Dragonborn are supported but not required.
    SKSE 1.7.0 - Not included. Download and install if you're not using it already. Earlier versions WILL NOT WORK. The mod will notice if SKSE is missing and will shut down.
    JContainers 3.1 or higher - Required!
    SkyUI 4.1 or higher - Required for MCM.
    RaceMenu 2.9.1 - Just install RaceMenu. Don't much around trying to extract chargen.dll.




Recommended

    Extensible Follower Framework (preferably 4.0-beta, though 3.5.6 works fine) - Highly recommended for follower management. EFF is the only follower manager that Familiar Faces explicitly supports. Though others do not cause any major issues and you are free to use them, UFO has not been tested, and AFT has be found to cause some problems with voicetype, perk and spell assignment. See the Compatibility section.
    Auto Unequip Ammo - Recommended to help your imported followers (who frequently have several types of ammo on them) pick the best ammo for their current weapon.



Compatibility


This list is not exhaustive. Generally, if a mod doesn't affect a character's look or skill set, it will probably be fine.

Known to work

    Dawnguard and Dragonborn are supported but not required.
    Extended Follower Framework by Expired.
    Mods that add NIOverride overlays (body tattoos, scars, glowing face tattoos, etc) to RaceMenu are fully supported, though the overlays may not always appear on the Shrine statue. They will appear on your character once they are sent into the world.
    Some ENB setups may interfere with ImageSpaceOverrides, meaning some animations that normally fade to white to hide animation glitches will not do so. This does not cause anything other than cosmetic problems, and only during the save animation in the Shrine.
    Sound effect overhauls, visual overhauls.
    Mods that add weapons and armor, including craftable ones. The mod must remain installed for the imported items to appear; if it is removed, the items it provides will be removed as usual and ignored by Familiar Faces.
    Body replacer mods such CBBE are fine, as long as they are compatible with RaceMenu.
    Follower Commentary Overhaul, as long as you assign your follower a Follower voicetype via MCM. Thanks to SunCe2112 for testing this for me!


Works with caveats

    New: AFT compatibility has been greatly improved, but most FF character management functions will be disabled if AFT is detected.
    New: FF now excludes SkyRE Perks that do not affect combat or cannot be used by NPCs. This should eliminate a lot of compatibility issues with SkyRE. Improving SkyRE compatibility is an ongoing project. Special thanks to Raulfin for providing me with a huge list of SkyRE Perks that needed to be exluded!
    Enhanced Character Edit now has experimental support, thanks to some wizardry by Expired[/b]. This requires RaceMenu 2.8.3 or higher be installed along with ECE. If ECE is found in the current load order, the character's head mesh will be written to a NIF located in Meshes/CharGen/Exported/. If a NIF is found for a character at load time, LoadExternalCharacter will be used to apply it to the actor's appearance. This will copy the NIF to This file will be copied to Meshes/Actors/Character/FaceGenData/FaceGeom/vMYC_MeetYourCharacters.esp/. It may be necessary to quicksave/quickload before the head appearance will update.
    Dual Sheath Redux seems to work okay but the sheathed sword object glitches out on saved characters. This looks fixable, though, so hopefully I can take care of it soon.
    Custom races work fine, but the race mod and skeleton mod they require must be installed on the loading game. That is, Races built on XPMS require XPMS be installed, etc. Ningheim have been tested as working, as have Drakian and several others. If you use or are the author of a popular custom race mod, PM me or create an issue over on the Github page to let me know if your race is not working properly under these circumstances.
    Face replacer mods should work as long as they are compatible with RaceMenu, but characters will probably not load properly if the face-altering mod is removed. Horrific monstrosities may result.
    HDT body mods should work but have not been tested.


Known to NOT work

    HDT physics hair does not work. Or maybe it does. Reports are mixed but generally negative. At least one tester reports it works for them as long as the player does not have HDT hair at the same time.



Installation


You can use NMM or MO (see next section) to install the mod from the 7z file. Other managers such as Wrye have not been tested, but should work. You can install manually simply by extracting the 7z file to the Skyrim/Data directory.

Mod Organizer


Familiar Faces works with Mod Organizer, but files that get created during gameplay will be written to the overwrite directory instead of to FF's mod tree. This is normal, but causes MO show a warning. These files can be safely moved into the Familiar Faces tree after you exit Skyrim, or they can be left in Overwrite.


Uninstallation


Make sure all followers provided by Familiar Faces are dismissed from your service before removing the mod.

If you plan to reinstall the mod, leave the My Games/Skyrim/JCUser/vMYC folder intact or at least back it up. It contains all the saved character data. Otherwise...

If you are going to remove the mod for good, use the "Shutdown" option on the Debug page of the MCM, save your game, quit, and follow the rest of the instructions.

If you used NMM to install, uninstallation will work but may leave files behind in Data/vYMC. If you used MO, files may remain in your overwrite directory in the same location.

Search for and remove ALL files and folders in Skyrim/Data that begin with "vMYC". The only other files remaining after that will be ffutils.*, which can also be searched for and removed.


Getting started


Shortly after starting or loading a game, you should receive a Portal Stone in your inventory. You can use that stone from your Inventory (under misc items, where you find your dragon bones and other miscellaneous stuff) to warp to the Shrine of Heroes. Activate the "Tome of the Dragonborn" in front of an empty alcove to save your character there. The save process will take some time; exactly how long depends on how many skills, perks, and inventory items your character has. It should never take longer than a minute of real time and should rarely take longer than 30 seconds unless you have a huge number of inventory items.

Once your character has been saved in an alcove, a statue of them will appear, possibly surrounded by various trophies and banners. These reflect your progress and which paths you chose in your adventures through Skyrim. An index of the available trophies can be found here.

Meeting your character


Now for the fun part! Load up a saved game on a different character. As before, use the Portal Stone (there may be a delay before it gets placed in your inventory, just wait). The first time you visit the Shrine, your other saved characters will be loaded in. This process may take some time, depending on the number of characters, how many custom items they have, etc. Opening the Tome of your saved character will send them into the world as NPCs. They will have a default spawn point based on their own adventures which can be changed from MCM.

Upon locating and talking to your imported character, you should be able to recruit them as followers (see VoiceTypes below). You can also make them a marriageable lover or your worst enemy via MCM.


Configuration/MCM


All configuration is done via MCM. Not all options get applied instantly and some require a refresh of your character, which will cause them to flicker in and out of sight, sometimes several times. This is normal.


Character Option page

In the MCM panel, you can change some aspects of your characters' behavior as well as how they level. Under Character Options, first choose the character you want to edit. This will bring up their saved info and the following options:

    Track this Character - This creates a quest marker under Miscellaneous that you can toggle to help find your characters once they're imported into the world.
    VoiceType - This changes the voice your character uses. This is more important than you might think: VoiceTypes affect whether you can recruit, marry, or adopt children with your imported character. If you want to recruit your character, you will need to give them a VoiceType labeled as "Follower". If you are using EFF or another Follower manager, you can switch their VoiceType back to their original one after recruiting, otherwise you will need to keep them on the Follower VT to access the various Follower commands via conversation. AFT users: I have some problem reports regarding AFT and the Voicetype settings. Some people say you have to change the VoiceType, then travel to a different cell before it will take effect. I'm not sure why this is and it is the subject of continued testing. For now, if your follower manager allows you to switch voicetypes, you might be better off using it instead of the Familiar Faces panel.
    Class - Changing a character's Class determines how their skill points are distributed in the level scaling process. By default, your imported characters will attempt to match their original skill set as closely as possible within the constraints of their current level. This may result in bizarre or unworkable setups, though (i.e. many points in Smithing and Enchanting and few points in combat skills, etc). The other Class listings are the same used by the original game and influence combat style as well as weapon preferences. In general, unless your receiving character is very close to the same level as the imported one, you'll want to use one of these presets. Experiment to find the Class best suited for your character!
    Hangout - This controls where your character will spawn in the world, as well as where they will go if dismissed from your service. At the bottom of the list are custom locations. See the section on using those below.
    Magic - By default, Familiar Faces imports only the spells for which the saved character has applicable perks. This may not be what you want, though; many a magic-shunning warrior has resorted to a quick healing spell in a pinch! Here you can disable the default behavior and manually select which schools of magic the character will have access to. Note that this actually adds and removes spells from the character's list, and will probably overwrite any manually added spells taught to the follower by other mods. This will be fixed in the very near future. If you want to completely disable magic for your character, just uncheck all the options in this category.



Shrine of Heroes page

Here you can rearrange the order in which characters appear in the Shrine of Heroes. You can also use this to clear out some Shrines if you have more than 12 characters to save. Remember that characters are not deleted when their Shrine is emptied, so it is possible to have more than 12 saved characters. Only 12 can be present in the world at one time, though.

New: As of 1.1.0, you may now Summon your characters (equivalent to opening their book) without actually visiting the Shrine! You can also reset an Alcove that is malfunctioning by scrolling to the bottom of its Character list and choosing * RESET *.


New: ?Hangouts page
Hangouts are new in version 1.1.0, and are used to determine where your character... well... hangs out! Hangouts are created when a character is saved, based on the location they used the Portal Stone. You can also create a new Hangout at any time simply by traveling to the desired location and using the Portal Stone again.

Some Hangouts are presets that may provide extra behavior to characters assigned to them. Otherwise, a complex AI package will attempt to give your character realistic behavior based on where they are assigned. Up to 12 characters may be assigned to a single Hangout, though the special behavior provided by some presets will only be applied to one of them. The rest will do the best they can with the default AI package. Note that assigning many characters to a single location may lead to some crowding and a brief delay when that area is loaded.

If no Hangout is assigned to a character, they will be a Wanderer. Wanderers travel to a random habitation, spend the night in an Inn, then wander somewhere else the next day.


New: Global Options page

This page allows you to pick defaults for various options, or mass-set certain character-specific options. From here you can disable certain Shouts, Spells, or change options relating to displaying warning and other messages. If an option's function isn't clear, hover your cursor over it to get an explanation displayed at the bottom of the page.

?New: Debugging page
Here you can reset various parts of the mod if they are having serious problems, tweak some performance options or even prepare the mod to be uninstalled. The resets are LAST RESORT options; use them only if you're having serious problems. Under normal circumstances (and Talos willing you'll never need to use anything on this page ;)


Quirks


The following are not bugs (or are unavoidable) and should not be reported:

    The game will hiccup or hang for a moment when entering the Shrine. This is a side effect of loading the CharGen data and can't be avoided. It should only occur when the character models are loading or when changing a character's Class via MCM.
    Characters will vanish for a second when their Class is changed via MCM. This is normal.
    Saved characters will quickly vanish and reappear after you load your game. Prior to disappearing they may be headless or have distorted faces. This is not normal, but on Familiar Faces it is.
    Some characters in the shrines may be in mannequin poses, others may not. This is due to how Skyrim handles loading models and can't be avoided easily.
    The Portal Stone may take nearly a minute to appear in your inventory. This is normal and will vary based on how many characters you have saved in the Shrine.



FAQ

    NEW: Q: One or more of my Shrine's Alcoves are stuck/I can't save my character because all books say my story is already written!
    A: The Shrine and Alcove code was greatly improved in 1.1.0. If a single Alcove is still stuck after upgrading to 1.1.0, you can reset it by choosing * RESET * from the list of Character Names in the Shrine MCM page. If your whole Shrine is still hopelessly screwed up, you can completely reset it from the Debugging page. Try the individual reset first, as the full reset will reset your character data and banish all characters back to the Shrine. 


    NEW: Q: The mod is not starting up/I'm not getting the Portal Stone!
    A: FF's startup is now deferred until MQ101 (Unbound) is completed. This can be overridden by typing ```set vMYC_WaitForMQ to 0``` in the console and waiting about 10 seconds. If this doesn't get things moving, try saving and reloading.


    Q: I'm getting a warning about SKSE/JContainers/Racemenu!
    A: You're missing some dependencies. See the requirements list up above and make sure you have the newest versions of each one installed. To keep everything running smoothly, install all the required mods separately.


    Q: Why isn't the stone appearing in my inventory?
    A: Either the mod isn't installed properly or your scripting engine is incredibly bogged down by other mods. Install the USKP, put the ClearInvalidRegistrations line in SKSE.ini, try starting a from a clean save or even a new game and see what happens.



    Q: Everything seems to be working but my characters aren't getting saved!
    A: Make sure the Data/vMYC folder got created during the installation and that you have permission to write to it.



    Q: The save animation never finishes/alcove stays lit forever!
    A: Check the above question for some first steps. There are a few reasons this could be happening, but the most likely culprit is a bogged-down script engine from other badly-behaved mods. Try enabling the ClearInvalidRegistrations feature of SKSE, or start from your clean save and see if it works there. If these don't work, send me your Papyrus log (you can use Pastebin and PM me the link) and I'll see what I can figure out for you. This could also happen if you have thousands and thousands of inventory items and spend all your time in god mode, in which case if you wait long enough, it should finish, but it shouldn't take more than a couple of minutes.



    Q: I'm stuck in the Shrine with collision disabled!
    A: See the previous answer. Basically your scripting engine is too bogged down to function properly. If nothing else works, you can try adding the following lines to your Skyrim.ini in the Papyrus section:
    fUpdateBudgetMS=800
    fExtraTaskletBudgetMS=800
    fPostLoadUpdateTimeMS=2000
    Note that this basically papering over the problem rather than actually fixing it, but it may allow you to continue using your current save until you can fix it for good.



    Q: My game crashed and I'm pretty sure this mod is the culprit!
    A: Sorry to hear that. Crashes were a problem early on but have not been reported by any testers in the versions leading up to public release. The only remaining one I am aware of is a very rare crash when first entering the Shrine which is caused by the Sovngarde portal mesh. Get me the Papyrus log and the details surrounding the crash and I'll check it out.


    Q: Can I get my character files out and send them to people?
    A: You can! The character file will be named after your character and be located in Skyrim/Data/vMYC (1.0.x) or in My Games/Skyrim/JCUser/vMYC (1.1.0). You will also need the RaceMenu slot file, located in Skyrim/Data/SKSE/Plugins/Chargen/Exported, and the texture, located in Skyrim/Data/Textures/CharGen/Exported. Copy these three files to another system in the same location, and your character will become available for selection in the Shrine of Heroes MCM page, as well importable by RaceMenu


    Q: What is this trophy/banner/symbol in my character's alcove?
    A: An index of the available trophies can be found here.


    Q: I'm getting a warning about SKSE/JContainers/CharGen!
    A: You're missing some dependencies. See the requirements list up above and make sure you have the newest versions of each one installed.



Spell Compatibility lists

If you're a mod author who would like to have FF load (or ignore) your mod's spells on imported characters, you may add your spells to the following Formlists:

    vMYC_ModCompatibility_SpellList_Unsafe (0x02024c6c): Spells added to this list will *never* be loaded, even if the character knows them and "Allow all mods" is toggled on. This list overrides all the others.
    vMYC_ModCompatibility_SpellList_Safe (0x02024c6b): Spells added to this list will be loaded if the character knows them and "Allow select mods" or "Allow all mods" is toggled on.
    vMYC_ModCompatibility_SpellList_Healing (0x02024c6d): Only self-healing spells that can be safely used by NPCs should be added to this list. They will be loaded if the character knows them and "Always allow healing" is toggled on.
    vMYC_ModCompatibility_SpellList_Armor (0x02024c6e): Only self-targeted armor-boosting spells that can be safely used by NPCs should be added to this list. They will be loaded if the character knows them and "Always allow armor spells" is toggled on.




Special thanks to...

    Syrcaid - My wifey, both for providing a decent name for this mod and putting up with being a mod widow. Also for the neat face graphic used in the logo.
    Expired - Without whom this mod would not have been even remotely possible. You need to go and download/endorse ALL his mods.
    SilverIce - For the incredible JContainers plugin, which provides a powerful and much-needed data storage mechanism to Papyrus.
    Brodual - For getting a video out in an impossibly short time.
    Gopher - For a very positive Twitch review that got me a lot of new downloaders.



Testers

For making sure the mod actually ran on computers other than my own.

    Cad'ika Orade - Also the catalyst for the mod's creation
    BLourenco
    SunCe2112 - For extra work in testing AFT and Dual Sheath Redux.
    BerenOneHanded
    Cryptoss
    Terrorfox1234
    DaveC
    Terrorfox1234




Older changelog
1.0.5

    Shouts can now be disabled for a character via MCM.



1.0.4

    Race, Armor, Weapon, Perk, and Spell dependencies are now written to the character save file. Files without dependency info will be automatically upgraded to include it the next time they are loaded. Dependency data is not yet read but this will support future features.
    Perks will now be loaded even if some are missing due to missing dependencies.
    A missing Race (for example because of missing plugins/mods) will now no longer hang the character loading process. Characters with an invalid Race will be set up as Nords, but will be updated to the correct Race if the required mods are later installed.
    If a Hangout is use, you will now receive a message telling you who is using it. Hangouts will receive an overhaul in the first feature release.
    NINode scale sizes are now saved with the character file. This allows for saving and loading of RaceMenu's extra sliders for things like Biceps. All NINodes provided by the vanilla skeletons and XPMS are checked. You must resave your characters for this to take effect.
    In combination with RaceMenu 2.8.3, experimental support for ECE. See the section under Compatibility below.



1.0.3

    Character items, armor, and weapons will now be updated properly if their Shrine save is updated. This may cause them to flicker when loaded but should be fine otherwise. Items you have given your imported characters should remain with them unchanged.
    Fix for getting stuck floating in the air while saving.
    Destroying the Tome now actually frees up the Shrine. If you delete the last character in the Alcove, the Tome will still be named after them, but you can still use it.
    Related to the previous, fixed every Tome saying "You've already written down your story."
    Gracefully handle deletion of the the _shrineofheroes.json file. If your Shrine has become unusable, deleting the data file will cause it to be completely emptied without deleting your character data. You can then use MCM to refill it without having to re-save everybody manually.
    Fixed a bug where the Portal Stone would strand you in the Shrine forever if used there.
    Thanks to an update to RaceMenu (2.8.2), Vampire characters should now be saved without a gray face, though you'll need to update their Tome to fix their appearance.
    Fixed trophies remaining in the shrine after character removal.



1.0.2

    Required for compatibility with RaceMenu 2.8.1.
    GREATLY improved character appearance loading. Characters now load faster, more reliably, and flicker-free thanks to a change in the CharGen.dll plugin. No more ElderRace followers! RaceMenu 2.8.1 is required for this new system to take effect. Familiar Faces 1.0.2 is backward compatible with RM 2.8.0 but it is recommended that you upgrade to take advantage of the new system. After upgrading RaceMenu, it may be necessary to re-save Khajiit and Argonian characters in the Shrine to avoid a distorted appearance. Or it may not, results seem to be mixed.
    Support for weapons with up to 8 enchantment effects (where are you people GETTING these?)
    EFF compatibility moved to a quest to prevent issues with having the module attached to actors when EFF is installed and removed.
    Additional checks on some translations in the Shrine that could cause a CTD in rare circumstances.
    Fix for MCM Character Tracking box still not responding properly.



1.0.1

    Expired has updated RaceMenu to version 2.8.0. It is very strongly recommended that you upgrade to 2.8.0 ASAP to ensure compatibility with Familiar Faces.
    Fixed issue that caused imported characters to get stuck as ElderRace if they took too long to load. If you are still getting this bug, either your system is very slow to load or you don't have the right version of RaceMenu installed.
    Fixed "Character Tracking" option not working in MCM.
    Fixed VoiceTypes being reset after a save/load.
    Removed a ton of debug messages that were spamming the Papyrus file.[*]Fixed a potential (but unlikely) CTD that could occur while applying perks or shouts.

