![BrewWikiGen logo](BrewWikiGen.png)

***BrewWikiGen***, by Sean 'Balthazar' Wheeldon; automatic Github markdown style
wiki page generation for *Supreme Commander: Forged Alliance* unit mods.

## Installation:
The script requires Lua 5.4 or greater to run. The uncompiled official download
for that is [available here](https://www.lua.org/download.html), however, I downloaded
pre-compiled binaries [from here](http://luabinaries.sourceforge.net/download.html).
`lua-5.4.2_Win64_bin.zip` to be specific.

For convenience, I execute from within [Atom](https://atom.io/) using the
[LuaRunner](https://github.com/shenfll/luarunner) plugin, downloadable from within
the Atom package manager. Ctrl-Shift-x opens the LuaRunner pane, point it at the
lua54.exe, open and [appropriately edit Run.lua](#Configuring) for your personal
environment, and run.

## Configuring:
The following values in `Run.lua` will probably need updating:

* `WikiGeneratorDirectory` should point to the cloned repo directory
or location of `Generators.lua` and the other files. The actual location of
`Run.lua` isn't important as long as it's pointing at the other files correctly.

* `OutputDirectory` needs to point to a real directory. I'd go for wherever you check
out your mods wiki repository, but what you do with the output is up to you.

* `ModDirectories` should point to your local copies of the mod(s) you wish to
generate wiki pages for. It assumes, but doesn't require, multiple mods. It
expects a `mod_info.lua` file directly in each item on the list. The order listed
is used in the sidebar navigation ordering.

* `UnitBlueprintsFolder` is where within the mod folders it should start looking
for blueprints. Standard convention is `units`. This value can be removed, but
execution can take double the time to complete.

* `BlueprintExclusions` is a list of things to exclude from the blueprint search.
It matches the first n characters of any file or folder to decide if it should
proceed to do anything with it; be that open that folder and look in it, or add
that `_unit.bp` file to the list of units to process.

* `ImageRepo` should point to the web directory it will find the image files. If
you maintain my directory structure but don't care about the images working on
the Github edit preview pages specifically, you could use just `"images/"`. If
you have your images on some other web server, that's fine too. As long as the
filenames match what the script is after. It is used currently just for the mod
page large images.

* `IconRepo`, like `ImageRepo`, but for icons; `"icons/"` could work here, with
the same caveats as above. Used directly for helper icons, and mod icons. Mod icons
don't respect the location listed in the `mod_info.lua` icon field, although have
a fall-back if nothing is defined there. This is to prevent mess and potentially
overlapping icon file paths.

* `unitIconRepo` is like the two previous. It expects to find images that match
the pattern `[BlueprintId]_icon.png`. It is case sensitive, and they must match
the case that the blueprint file used.

* `FooterCategories` is a list of unit categories that the generator should create
category pages for, and link to at the bottom of the relevant units. The appear
on unit pages in the order written, so I tried to order them in a natural language
order, or as close to as possible. If you have no units in a given category, no
page will be generated. Add or remove as seems appropriate for your mods needs.
Can be completely removed if you don't need categories.

## Usage notes:
Since this generator is real Lua and runs mod files directly for data, any mod
file loaded must be valid Lua. This notably means **not** using `#` instead of
`--`, not using `!=` instead of `~=`, and probably several other things.

Code in required files that validates as Lua, but wouldn't run, ie: because it
runs a loop without defining an iterator like `pairs` or `ipairs`, or wouldn't
want to be ran for the wiki generation can be selectively ran by changing the
code to check `_VERSION == "Lua 5.0.1"` first so that it only runs in-game.

I don't anticipate this being a huge issue, since these are generally data files
only and the check should at most need to be performed in game at most once.

Mod files that must meet this criteria are `_unit.bp` files, and:

*    `/mod_info.lua`
*    `/hook/lua/ui/help/tooltips.lua'`
*    `/hook/lua/ui/help/unitdescription.lua`
*    `/hook/loc/US/strings_db.lua`

It will skip any mod that doesn't have a valid `mod_info.lua`, and will stop
running that mod if it reaches a bp file that doesn't validate. For the other
files it will continue with a warning, but may have missing data on the pages.
Only blueprint files that end in `_unit.bp` will be included.
