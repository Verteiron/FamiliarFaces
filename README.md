#FamiliarFaces
Skyrim mod that allow characters to be shared between different playthroughs. Download the current build from Releases or from the [Skyrim Nexus](http://www.nexusmods.com/skyrim/mods/54509).

Familiar Faces allows you to create persistent copies of your character that exist independently of saved games. You can then visit those characters from any of your saved games; send them into the world to interact with, recruit as followers, marry or kill.

###What gets saved

*   Character's appearance. The imported character should look exactly like their original self. All morphs, skins, and replacers supported by RaceMenu are supported by Familiar Faces because they use the same system. This includes custom colors, body tattoos, glowing marks and other overlay-specific features.
*   Imported characters will retain all equipped armor, including names and customizations if any are present, as well as all custom weapons both equipped and in inventory. This includes weapons and armor provided by other mods. Items that are un-droppable due to being Quest objects may not be copied.
*   All ammunition in inventory, including crossbow bolts and ammunition provided by other mods.
*   Imported characters will have most of their spell list available, provided the spells are from the vanilla game or official DLC. The spell list can be restricted by school through MCM.
*   Imported characters retain and will use all Shouts they learned, though the list is trimmed slightly for compatibility purposes and may be trimmed further in a future release. Some shouts, such as Call Storm, do not work properly when used by followers.
*   Imported characters retain all perks they have learned. Some perks may have their effects disabled for compatibility purposes, but most will function as intended.

###What won't get saved

*   Gold and other items, such as potions and scrolls. Support for potions, possibly even custom potions, is planned in a future release. Most other inventory items can be transferred (from a technical standpoint) but there are good reasons not to do so. Full inventory transfer may become available as an option if there is demand.
*   Certain perks and shouts are either ignored or disabled for compatibility reasons. So far these include: Slow Time, Kyne's Peace, and the dragon-summoning Shouts. Perks that improve decapitation odds are disabled when the imported character is fighting the player, since decapitating the player causes a crash. Perks that do player-specific things like slow time while blocking are imported, but ignored by the game.
*   Spells added by unofficial DLCs/mods. Sorry, as a spell-writer and collector, this one pains me too, but it was necessary. A huge number of non-vanilla spells are designed only for use by the player, or are abilities added and used by other mods that are only intended for use on the player. Adding these to NPCs caused a huge number of problems. Support for at least some additional spells will be added in a future update, probably on a case-by-case basis.
 
###What Familiar Faces does not do
Familiar Faces is not a follower manager. It is intended to be used alongside another follower manager such as EFF.
Familiar Faces is not a custom follower generator, although it can certainly be used that way. Future features are going to be aimed at improving the playability and accuracy of character duplication, not at making character design faster, easier, or more complete.
Familiar Faces is not a method for transferring items between save games. Again, it can be used this way (by pickpocketing or trading with your imported characters) but it will never be the mod's first priority. I do, however, plan to add a shared chest of some kind that will allow you to transfer additional customized items between saves.

###Requirements
*   Latest version of Skyrim - Dawnguard and Dragonborn are supported but not required.
*   SKSE 1.7.0 - Not included. Download and install if you're not using it already. Earlier versions WILL NOT WORK. The mod will notice if SKSE is missing and will shut down.
*   SkyUI 4.1 - Not included. Required for using MCM.
*   JContainers 0.67.4 or higher
*   [RaceMenu 2.8.3](http://www.nexusmods.com/skyrim/mods/29624/?). If you don't want to use Racemenu, don't activate its ESP files, but the chargen.dll included with it is required. Technically FF is compatible back to RM 2.8.0, but new features were added to RM with 2.8.2 that immensely improve the experience.

###Recommended
Extensible Follower Framework (preferably 4.0-beta, though 3.5.6 works fine) - Highly recommended for follower management. EFF is the only follower manager that Familiar Faces explicitly supports. Though others do not cause any major issues and you are free to use them, UFO has not been tested, and AFT has be found to cause some problems with voicetype, perk and spell assignment. See the Compatibility section.
Auto Unequip Ammo - Recommended to help your imported followers (who frequently have several types of ammo on them) pick the best ammo for their current weapon.

###Compatibility
*   Dawnguard and Dragonborn are supported but not required.
*   Enhanced Character Edit (ECE) is NOT compatible with Familiar Faces and likely won't be any time in the near future. This is not due to any particular flaw in ECE, it just uses a different system than CharGen Extender, which is what I'm relying on.
*   Body replacer mods such CBBE should be compatible. Face replacer mods should work (provided they don't rely on ECE), but exported characters will probably not load properly if the face-altering mod is removed.
*   Mods that add NIOverride overlays (body tattoos, scars, glowing face tattoos, etc) are *fully* supported.
*   Some ENB setups may interfere with ImageSpaceOverrides, meaning some animations that normally fade to white to hide animation glitches will not do so. Please let me know if you're using ENB before reporting animation bugs.

###Installation
You can use NMM to install the mod from the 7z file. It should also work with Mod Organizer, but be aware that files will be created in MO's Override directory during gameplay. This is normal but it makes MO show a warning. If you need to send me the contents of Data/vMYC, you'll have to pull them from MO's Override directory instead of your Skyrim installation.

You can install manually simply by extracting the 7z file to the Skyrim/Data directory.

###Uninstallation
Make sure all followers provided by Familiar Faces are dismissed from your service before removing the mod.

If you plan to reinstall the mod, leave the Data/vMYC directory intact or at least back it up. It contains all the saved character data. Otherwise...

If you used NMM to install, uninstallation should work but may leave some files behind. If you used MO, files may remain in your Override directory.

Search for and remove ALL files and folders in Skyrim/Data that begin with "vMYC". Remove JContainers.dll and the included version of CharGen.dll if you aren't using them for any other mods.

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

If you find a bug, it will be really helpful to have a Papyrus log to send me so I can try to figure out what happened. Make sure the following settings are present in your Skyrim.ini:

```ini
[Papyrus] 
EnableLogging=1 
EnableTrace=1 
LoadDebugInformation=1
```

The Papyrus logs will be located in your Documents folders under My Games/Skyrim/Logs/Script/ and will be named Papyrus.0.log.

File bug reports as Issues on Github or send them to: verteiron+ffbugs@gmail.com.

Disclaimer
----------
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
