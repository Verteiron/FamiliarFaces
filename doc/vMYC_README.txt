Bring your characters together at last! Visit the Shrine of Heroes, where you can meet your Dragonborn from past play-throughs, create a monument to their achievements, and even bring them to your world as faithful allies... or worthy opponents! Whether you're a role-player trying to build a coherent story of Skyrim or you just think it'd be cool to use your other players as followers, Familiar Faces is the [i]only[/i] way to do it!

 
[b][size=5]What Familiar Faces does[/size][/b]
 
Familiar Faces allows you to create persistent copies of your character that exist independently of saved games. You can then visit those characters from any of your saved games; send them into the world to interact with, recruit as followers, marry or kill.

[b]What gets saved[/b]
[LIST]
[*]Character's appearance. The imported character should look [i]exactly[/i] like their original self. All morphs, skins, and replacers supported by RaceMenu are supported by Familiar Faces because they use the same system. This includes custom colors, body tattoos, glowing marks and other overlay-specific features.[/*]
[*]Imported characters will retain all equipped armor, including names and customizations if any are present, as well as all custom weapons both equipped and in inventory. This includes weapons and armor provided by other mods. Items that are un-droppable due to being Quest objects may not be copied.[/*]
[*]All ammunition in inventory, including crossbow bolts and ammunition provided by other mods.[/*]
[*]Imported characters will have most of their spell list available, provided the spells are from the vanilla game or official DLC. The spell list can be restricted by school through MCM.[/*]
[*]Imported characters retain and will use all Shouts they learned, though the list is trimmed slightly for compatibility purposes and may be trimmed further in a future release. Some shouts, such as Call Storm, do not work properly when used by followers.[/*]
[*]Imported characters retain all perks they have learned. Some perks may have their effects disabled for compatibility purposes, but most will function as intended.[/*]
[/LIST]
[b]What won't get saved[/b]
[LIST]
[*]Gold and other items, such as potions and scrolls. Support for potions, possibly even custom potions, is planned in a future release. Most other inventory items can be transferred (from a technical standpoint) but there are good reasons not to do so. Full inventory transfer may become available as an option if there is demand.[/*]
[*]Certain perks and shouts are either ignored or disabled for compatibility reasons. So far these include: Slow Time, Kyne's Peace, and the dragon-summoning Shouts. Perks that improve decapitation odds are disabled when the imported character is fighting the player, since decapitating the player causes a crash. Perks that do player-specific things like slow time while blocking are imported, but ignored by the game.[/*]
[*]Spells added by unofficial DLCs/mods. Sorry, as a spell-writer and collector, this one pains me too, but it was necessary. A huge number of non-vanilla spells are designed only for use by the player, or are abilities added and used by other mods that are only intended for use on the player. Adding these to NPCs caused a huge number of problems. Support for at least some additional spells will be added in a future update, probably on a case-by-case basis.[/*]
[/LIST]
 
[b][size=5][b][size=5]What Familiar Faces does [i]not[/i] do[/size][/b][/size][/b]
[LIST]
[*][b]Familiar Faces is not a follower manager.[/b] It is intended to be used alongside another follower manager such as EFF.[/*]
[*][b]Familiar Faces is not a custom follower generator[/b], although it can certainly be used that way. Future features are going to be aimed at improving the playability and accuracy of character duplication, not at making character design faster, easier, or more complete.[/*]
[*][b]Familiar Faces is not a method for transferring items between save games.[/b] Again, it can be used this way (by pickpocketing or trading with your imported characters) but it will never be the mod's first priority. I do, however, plan to add a shared chest of some kind that will allow you to transfer additional customized items between saves.[/*]
[/LIST]
 
[b][size=5]Requirements[/size][/b]
[LIST]
[*]Latest version of Skyrim - Dawnguard and Dragonborn are supported but not required.[/*]
[*][url=http://skse.silverlock.org/]SKSE 1.7.0[/url] - Not included. Download and install if you're not using it already. Earlier versions WILL NOT WORK. The mod will notice if SKSE is missing and will shut down.[/*]
[*][url=http://www.nexusmods.com/skyrim/mods/3863/?]SkyUI 4.1 or higher[/url] - Required for MCM.[/*]
[*][url=http://www.nexusmods.com/skyrim/mods/49743]JContainers 0.67.3 or higher[/url] - This is an SKSE plugin that is packaged with this testing edition.[/*]
[*][url=http://www.nexusmods.com/skyrim/mods/29624/?]RaceMenu 2.7.2[/url] - More specifically, the chargen.dll SKSE plugin distributed with that version. RaceMenu itself does not have to be installed, just the chargen.dll SKSE plugin. You should use RaceMenu, though.[/*]
[/LIST]
 
 
[size=5][b]Recommended[/b][/size]
[LIST]
[*][url=http://www.nexusmods.com/skyrim/mods/12933/?]Extensible Follower Framework[/url] (preferably 4.0-beta, though 3.5.6 works fine) - Highly recommended for follower management. EFF is the only follower manager that Familiar Faces explicitly supports. Though others do not cause any major issues and you are free to use them, UFO has not been tested, and AFT has be found to cause some problems with voicetype, perk and spell assignment. See the Compatibility section.[/*]
[*][url=http://www.nexusmods.com/skyrim/mods/10753]Auto Unequip Ammo[/url] - Recommended to help your imported followers (who frequently have several types of ammo on them) pick the best ammo for their current weapon.[/*]
[/LIST]
 
[size=5][b]Compatibility[/b][/size]
 
This list is not exhaustive. Generally, if a mod doesn't affect a character's look or skill set, it will probably be fine.
 
[b]Known to work[/b]
[LIST]
[*]Dawnguard and Dragonborn are supported but not required.[/*]
[*]Extended Follower Framework by Expired.[/*]
[*]Mods that add NIOverride overlays (body tattoos, scars, glowing face tattoos, etc) to RaceMenu are fully supported, though the overlays may not always appear on the Shrine statue. They will appear on your character once they are sent into the world.[/*]
[*]Some ENB setups may interfere with ImageSpaceOverrides, meaning some animations that normally fade to white to hide animation glitches will not do so. This does not cause anything other than cosmetic problems, and only during the save animation in the Shrine.[/*]
[*]Sound effect overhauls, visual overhauls.[/*]
[*]Mods that add weapons and armor, including craftable ones. The mod must remain installed for the imported items to appear; if it is removed, the items it provides will be removed as usual and ignored by Familiar Faces.[/*]
[*]Body replacer mods such CBBE are fine, as long as they are compatible with RaceMenu.[/*]
[/LIST]
[b]Works with caveats[/b]
[LIST]
[*]Perks provided by overhaul mods such as SkyRE should be imported with all attributes intact, but may not function as originally intended. Familiar Faces has not been tested with SkyRE.[/*]
[*]Face replacer mods should work as long as they are compatible with RaceMenu and they don't rely on ECE, but characters will probably not load properly if the face-altering mod is removed. Horrific monstrosities may result.[/*]
[*]AFT seems to be causing problems for some people when it comes to selecting VoiceTypes for characters, as well as setting up spell lists.[/*]
[/LIST]
[b]Known to NOT work[/b]
[LIST]
[*]Enhanced Character Edit (ECE) is **NOT** compatible with Familiar Faces and likely won't be any time in the near future. I have contacted the author about adding compatibility functions to ECE, but thus far they are unwilling or unable to do so. The way the mod is written currently, I have no way to apply ECE information to an NPC.[/*]
[*]HDT physics mods almost certainly will not work properly. See [url=https://code.google.com/p/hdt-pe/issues/detail?id=2]this page[/url] for more information. HDT body mods [i]may[/i] work but have not been tested. HDT hair definitely does not work.[/*]
[/LIST]
 
[size=5][b]Installation[/b][/size]

You can use NMM or MO (see next section) to install the mod from the 7z file. Other managers such as Wrye have not been tested, but should work. You can install manually simply by extracting the 7z file to the Skyrim/Data directory.

[size=4][b]Mod Organizer notes[/b][/size]
 
Familiar Faces works with Mod Organizer, but files that get created during gameplay will be written to the [i]overwrite[/i] directory instead of to FF's mod tree. This is normal, but causes MO show a warning. These files can be safely moved into the Familiar Faces tree after you exit Skyrim, or they can be left in Overwrite.

 
[size=5][b]Uninstallation[/b][/size]

[b]Make sure all followers provided by Familiar Faces are dismissed from your service before removing the mod.[/b]

If you plan to reinstall the mod, leave the Data/vMYC directory intact or at least back it up. It contains all the saved character data. Otherwise...

If you used NMM to install, uninstallation will work but may leave files behind in Data/vYMC. If you used MO, files may remain in your overwrite directory in the same location.

Search for and remove ALL files and folders in Skyrim/Data that begin with "vMYC". The only other files remaining after that will be ffutils.*, which can also be searched for and removed.

[size=5][b]Getting started[/b][/size]
 
Shortly after starting or loading a game, you should receive a Portal Stone in your inventory. You can use that stone from your Inventory (under misc items, where you find your dragon bones and other miscellaneous stuff) to warp to the Shrine of Heroes. Activate the "Tome of the Dragonborn" in front of an empty alcove to save your character there. The save process will take some time; exactly how long depends on how many skills, perks, and inventory items your character has. It should never take longer than a minute of real time and should rarely take longer than 30 seconds unless you have a huge number of inventory items.

Once your character has been saved in an alcove, a statue of them will appear, possibly surrounded by various trophies and banners. These reflect your progress and which paths you chose in your adventures through Skyrim.

[size=5][b]Meeting your character[/b][/size]
 
Now for the fun part! Load up a saved game on a different character. As before, use the Portal Stone (there may be a delay before it gets placed in your inventory, just wait). The first time you visit the Shrine, your other saved characters will be loaded in. This process may take some time, depending on the number of characters, how many custom items they have, etc. Opening the Tome of your saved character will send them into the world as NPCs. They will have a default spawn point based on their own adventures which can be changed from MCM.

Upon locating and talking to your imported character, you should be able to recruit them as followers (see VoiceTypes below). You can also make them a marriageable lover or your worst enemy via MCM.


[size=5][b]Configuration[/b][/size]
 
All configuration is done via MCM. Not all options get applied instantly and some require a refresh of your character, which will cause them to flicker in and out of sight, sometimes several times. This is normal.

[b]Character Options[/b]
 
In the MCM panel, you can change some aspects of your characters' behavior as well as how they level. Under Character Options, first choose the character you want to edit. This will bring up their saved info and the following options:
[LIST]
[*][b]Track this Character[/b] - This creates a quest marker under Miscellaneous that you can toggle to help find your characters once they're imported into the world.[/*]
[*][b]VoiceType[/b] - This changes the voice your character uses. This is more important than you might think: [i]VoiceTypes affect whether you can recruit, marry, or adopt children with your imported character[/i]. If you want to recruit your character, you will need to give them a VoiceType labeled as "Follower". If you are using EFF or another Follower manager, you can switch their VoiceType back to their original one after recruiting, otherwise you will need to keep them on the Follower VT to access the various Follower commands via conversation. [b]AFT users[/b]: I have some problem reports regarding AFT and the Voicetype settings. Some people say you have to change the VoiceType, then travel to a different cell before it will take effect. I'm not sure why this is and it is the subject of continued testing. For now, if your follower manager allows you to switch voicetypes, you might be better off using it instead of the Familiar Faces panel.[/*]
[*][b]Class[/b] - Changing a character's Class determines how their skill points are distributed in the level scaling process. By default, your imported characters will attempt to match their original skill set as closely as possible within the constraints of their current level. This may result in bizarre or unworkable setups, though (i.e. many points in Smithing and Enchanting and few points in combat skills, etc). The other Class listings are the same used by the original game and influence combat style as well as weapon preferences. [b]In general, unless your receiving character is very close to the same level as the imported one, you'll want to use one of these presets.[/b] Experiment to find the Class best suited for your character![/*]
[*][b]Hangout[/b] - This controls where your character will spawn in the world, as well as where they will go if dismissed from your service. At the bottom of the list are custom locations. See the section on using those below.[/*]
[*][b]Magic[/b] - By default, Familiar Faces imports only the spells for which the saved character has applicable perks. This may not be what you want, though; many a magic-shunning warrior has resorted to a quick healing spell in a pinch! Here you can disable the default behavior and manually select which schools of magic the character will have access to. Note that this actually adds and removes spells from the character's list, and will probably overwrite any manually added spells taught to the follower by other mods. This will be fixed in the very near future. If you want to completely disable magic for your character, just uncheck all the options in this category.[/*]
[/LIST]

[b]Shrine of Heroes[/b]
 
Here you can rearrange the order in which characters appear in the Shrine of Heroes. You can also use this to clear out some Shrines if you have more than 12 characters to save. Remember that characters are not deleted when their Shrine is emptied, so it is possible to have more than 12 saved characters. Only 12 can be present in the world at one time, though.

[size=5][b]Quirks[/b][/size]
 
The following are not bugs (or are unavoidable) and should not be reported:
[LIST]
[*]The game will hiccup or hang for a moment when entering the Shrine. This is a side effect of loading the CharGen data and can't be avoided. It should only occur when the character models are loading or when changing a character's Class via MCM.[/*]
[*]Characters will vanish for a second when their Class is changed via MCM. This is normal.[/*]
[*]Saved characters will quickly vanish and reappear after you load your game. Prior to disappearing they may be headless or have distorted faces. This is not normal, but on Familiar Faces it is.[/*]
[*]Some characters in the shrines may be in mannequin poses, others may not. This is due to how Skyrim handles loading models and can't be avoided easily.[/*]
[*]The Portal Stone may take nearly a minute to appear in your inventory. This is normal and will vary based on how many characters you have saved in the Shrine.[/*]
[*]If your character is a Vampire/Vampire Lord, they may suffer from the gray-face bug. This is an issue with Dawnguard vampires and probably can't be fixed without making the mod dependent on Dawnguard.esm. If I can find no other way to fix this I will release a Dawnguard-dependent version.[/*]
[/LIST]

[b][size=5]FAQ[/size][/b]
[LIST]
[*][b]Q: I'm getting a warning about SKSE/JContainers/CharGen![/b]
[b]A: [/b]You're missing some dependencies. See the requirements list up above and make sure you have the newest versions of each one installed. You can also try using the "plus Deps" version on the download page, but this is intended ONLY for people who are not already using RaceMenu. To keep everything running smoothly, install all the required mods separately.
 [/*]
[*]Q: SKSE 1.7 is labeled Alpha, is it safe? Is it compatible with my other mods? Why is it required?
A: Yes. This mod was developed entirely using 1.7, and uses a huge amount of SKSE calls. SKSE 1.7 is already very widely adopted and heavily used. It is entirely backward-compatible with 1.6: If you have mods that require 1.6, they will work with 1.7.  As for why, the simplest answer is that it provides the features that make Familiar Faces possible. Without 1.7 this mod would not exist.
 [/*]
[*]Q: Why isn't the stone appearing in my inventory?
A: Either the mod isn't installed properly or your scripting engine is incredibly bogged down by other mods. Install the USKP, put the ClearInvalidRegistrations line in SKSE.ini, try starting a from a clean save or even a new game and see what happens.
 [/*]
[*]Q: Everything seems to be working but my characters aren't getting saved!
A: Make sure the Data/vMYC folder got created during the installation and that you have permission to write to it.
 [/*]
[*]Q: My game crashed and I'm pretty sure this mod is the culprit!
A: Sorry to hear that. Crashes were a problem early on but have not been reported by any testers in the versions leading up to public release. Get me the Papyrus log and the details surrounding the crash and I'll check it out.[/*]
[/LIST]