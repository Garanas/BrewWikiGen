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
Most of the following values in `Run.lua` will need updating for your setup:

* `Language` should be the two letter language code for which LOC files should be
loaded. They are not ISO_639-1. Non-`'US'` is supported only for strings copied
verbatim. Actual wiki prose and text is not yet translated, or prepared for such.

* `OutputDirectory` needs to point to a real directory. I'd go for wherever you
check out your mods wiki repository, but what you do with the output is up to you.

* `WikiGeneratorDirectory` should point to the folder this readme and `Run.lua`
are located in. Include a slash at the end.

* `ModDirectories` should point to your local copies of the mod(s) you wish to
generate wiki pages for. It assumes, but doesn't require, multiple mods. It
expects a `mod_info.lua` file directly in each item on the list. The order listed
is used in the sidebar navigation ordering.

* `WikiExtraData` can point to an optional extra document of hand written content
for specific sections of specific unit pages. It expects data to be formatted as
a `UnitData` table, keyed with unit IDs (upper case, or however the bp files are
named if they are anything other than entirely lower case), with table values
containing keys that match the syntax `[Section]Prefix` or `[Section]Suffix`, where
`[Section]` matches the English names of sections, like `Weapons` or `Adjacency`,
or `LeadSuffix`, with string values, or keyed with `Videos` with an array of tables
that match the format `{YouTube = '[Video ID]', '[Display name]'}`, where
`[Video ID]` is the 11-ish character YouTube video ID, and `[Display name]` is the
link caption to display. Which is a very wordy way to say to look like this
example:
  ```lua
  UnitData = {
      SSL0403 = {
          Videos = {
              {YouTube = 'IInITjdtaPM', 'Time-lapse'},
          },
          LeadSuffix = "Paragraph to appear after the generated lead paragraph.",
          AdjacencyPrefix = "Paragraph to appear before the Adjacency section."
      },
  }
  ```
  While the `WikiExtraData` value is optional, if you remove the key you will need
  to comment out the line `safecall(dofile, WikiExtraData)`, otherwise it will crash.

* `UnitBlueprintsFolder` is where within the mod folders it should start looking
for blueprints. Standard convention is `units`. This value can be removed, but
execution can take double the time to complete.

* `BlueprintFolderExclusions` and `BlueprintFileExclusions` are arrays of regex
matches for what to exclude from the blueprint search. The first is used against
anything without a . in it, assumed to be folders, the second is used against
anything that ends in `_unit.bp`. It won't look in any folder that matches, or
open any file that matches.

* `BlueprintIdExclusions` is an array of exact blueprint IDs to exclude. Case insensitive.

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

* `Logging` contains several options for verbose logging of additional information
which can be interesting or helpful in the case of any issues.

* `Sanity` contains options for flagging anything in blueprints and their meshes
that I consider anomalous or unnecessary. Exercise discretion when taking its advice.

## Usage notes:
### Home and sidebar:
If you have a pre-existing `Home.md` or `_Sidebar.md` page in your wiki, you can
specify where within those pages you want the generator to output by using the
xml tags `<brewwikihome></brewwikihome>` and `<brewwikisidebar></brewwikisidebar>`
respectively, otherwise it will append said content, tags included to the end.
If you do not wish it to generate one or both of those pages at all, comment out
or remove the lines `safecall(GenerateHomePage)` and/or `safecall(GenerateSidebar)`
from your updated `Run.lua`.

### Environmental blueprints:
If you include blueprints in a sub-folder of the `/Environment/` folder, the
generator will load them for built-by lists and upgrades to/from information. It
won't generate wiki pages for them or include them in navigation/category pages
or include them in engineering build lists.

### Blueprints.lua:
If you have content generated in `Blueprints.lua` that would be important to the
wiki, you can have the wiki run it by adding a `WikiBlueprints` function to that
file. That function is called in much the same way as `ModBlueprints`, except by
the wiki instead of the game. Input argument is the same, except only `.Unit` is
populated currently, and will only contain blueprints from included mods. This
is easier to achieve if your `Blueprints.lua` is formatted such that your
`ModBlueprints` hook is populated with function calls rather than with code ran
directly within that hook.

### Lua validation:
Since this generator runs mod files directly for data, any referenced files must
be valid for Lua 5.4. This notably means **not** using `#` instead of `--`, not
using `!=` instead of `~=`, and probably several other things.

Code in required files that validates as Lua, but wouldn't run, ie: because it
runs a loop without defining an iterator like `pairs` or `ipairs`, or wouldn't
want to be ran for the wiki generation can be selectively ran by changing the
code to check `_VERSION == "Lua 5.0.1"` first so that it only runs in-game.

I don't anticipate this being a huge issue, since these are generally data files
and any code in them shouldn't need to be performed more than once.

Files this affects are as follows:

*    `/mod_info.lua`
*    `/hook/lua/ui/help/tooltips.lua`
*    `/hook/lua/ui/help/unitdescription.lua`
*    `/hook/lua/system/blueprints.lua`
*    `/hook/loc/US/strings_db.lua`

### Included files:
It will skip any mod that doesn't have a valid `mod_info.lua`, and, while
blueprint files are sanitised it will stop running that mod if it reaches a `.bp`
file that still doesn't validate as Lua. For the other files it will continue
with a warning, but may have missing data on the pages.

Only blueprint files that end in `_unit.bp` will be included, and only non-Merge
blueprints in those that contain defined `Display`, `Categories`, `Defense`,
`Physics`, and `General` tables will be given pages and included in navigation.
