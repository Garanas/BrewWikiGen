--------------------------------------------------------------------------------
-- Supreme Commander mod automatic unit wiki generation script for Github wikis
-- Copyright 2021 Sean 'Balthazar' Wheeldon                           Lua 5.4.2
--------------------------------------------------------------------------------

GetUnitInfoboxData = function(ModInfo, bp)
    return {
        {'', "Note: Several units have stats defined at the<br />start of the game based on the stats of others."},
        {'Source:', '<a href="'..stringSanitiseFile(ModInfo.name)..'">'..ModInfo.name..'</a>'},
        {'Unit ID:', '<code>'..bp.id..'</code>',},
        {'Faction:', (bp.General and bp.General.FactionName)},
        {'Tech level:', bp.unitTIndex and bp.unitTIndex..(bp.unitTIndex == 4 and ' (Experimental)' or '') },
        {''},
        {'Health:',
            (
                not bp.CategoriesHash.INVULNERABLE
                and iconText(
                    'Health',
                    bp.Defense and bp.Defense.MaxHealth,
                    (bp.Defense and bp.Defense.RegenRate and ' (+'..bp.Defense.RegenRate ..'/s)')
                )
                or 'Invulnerable'
            )
        },
        {'Armour:', (bp.Defense and not bp.CategoriesHash.INVULNERABLE and bp.Defense.ArmorType and '<code>'..bp.Defense.ArmorType..'</code>')},
        {'Shield health:',
            iconText(
                'Shield',
                tableSafe(bp.Defense, 'Shield', 'ShieldMaxHealth'),
                (tableSafe(bp.Defense, 'Shield', 'ShieldRegenRate') and ' (+'..bp.Defense.Shield.ShieldRegenRate..'/s)')
            )
        },
        {'Shield radius:', (tableSafe(bp.Defense, 'Shield', 'ShieldSize') and numberFormatNoTrailingZeros(bp.Defense.Shield.ShieldSize / 2))}, --Shield size is a scale multiplier, and so is effectively diameter
        {'Flags:',
            InfoboxFlagsList{
                bp.CategoriesHash.UNTARGETABLE and 'Untargetable' or '',
                (bp.CategoriesHash.UNSELECTABLE or not bp.CategoriesHash.SELECTABLE) and 'Unselectable' or '',
                (bp.Display and bp.Display.HideLifebars or bp.LifeBarRender == false) and 'Lifebars hidden' or '',
                tableSafe(bp.Defense,'Shield','AntiArtilleryShield') and 'Artillery shield' or '',
                tableSafe(bp.Defense,'Shield','PersonalShield') and 'Personal shield' or '',
            }
        },
        {''},
        {'Energy cost:', iconText('Energy', bp.Economy and bp.Economy.BuildCostEnergy)},
        {'Mass cost:', iconText('Mass', bp.Economy and bp.Economy.BuildCostMass)},
        {'Build time:', iconText('Time-but-not', bp.Economy and bp.Economy.BuildTime, arraySubfind(bp.Categories, 'BUILTBY') and ' (<a href="#construction">Details</a>)' or '' )}, --I don't like the time icon for this, it looks too much and it's also not in real units
        {'Maintenance cost:', iconText('Energy', bp.Economy and bp.Economy.MaintenanceConsumptionPerSecondEnergy,'/s')},
        {'Build rate:', iconText('Build', bp.Economy and bp.Economy.BuildRate)},
        {'Energy production:', iconText('Energy', bp.Economy and bp.Economy.ProductionPerSecondEnergy, '/s')},
        {'Mass production:', iconText('Mass', bp.Economy and bp.Economy.ProductionPerSecondMass, '/s')},
        {'Energy storage:', iconText('Energy', bp.Economy and bp.Economy.StorageEnergy)},
        {'Mass storage:', iconText('Mass', bp.Economy and bp.Economy.StorageMass)},
        {''},
        {'Vision radius:', (bp.Intel and bp.Intel.VisionRadius or 10)},
        {'Water vision radius:', (bp.Intel and bp.Intel.WaterVisionRadius or 10)},
        {'Radar radius:', (bp.Intel and bp.Intel.RadarRadius)},
        {'Sonar radius:', (bp.Intel and bp.Intel.SonarRadius)},
        {'Omni radius:', (bp.Intel and bp.Intel.OmniRadius)},
        {'Jammer blips (radii):',
            (bp.Intel and bp.Intel.JamRadius)
            and
            (bp.Intel.JammerBlips or 0)..' ('..
            (bp.Intel.JamRadius.Min)..'‒'..
            (bp.Intel.JamRadius.Max)..')'
        },
        {'Cloak radius:', (bp.Intel and bp.Intel.CloakFieldRadius)},
        {'Radar stealth radius:', (bp.Intel and bp.Intel.RadarStealthFieldRadius)},
        {'Sonar stealth radius:', (bp.Intel and bp.Intel.SonarStealthFieldRadius)},
        {'Flags:',
            bp.Intel and InfoboxFlagsList{
                (bp.Intel.Cloak and 'Cloak' or ''),
                (bp.Intel.RadarStealth and 'Radar stealth' or ''),
                (bp.Intel.SonarStealth and 'Sonar stealth' or ''),
            }
        },
        {''},
        {'Motion type:', bp.Physics.MotionType and ('<code>'..bp.Physics.MotionType..'</code>')},
        {'Buildable layers:', (bp.Physics.MotionType == 'RULEUMT_None') and BuildableLayer(bp.Physics)},
        {'Movement speed:', (bp.Air and bp.Air.MaxAirspeed or bp.Physics.MaxSpeed)},
        {'Fuel:', (bp.Physics.FuelUseTime and iconText('Fuel', string.format('%02d:%02d', math.floor(bp.Physics.FuelUseTime/60), math.floor(bp.Physics.FuelUseTime % 60)), '') )},
        {'Elevation:', (bp.Air and bp.Physics.Elevation)},
        {'Transport class:', (
            (
                bp.Physics.MotionType ~= 'RULEUMT_None' and (
                    bp.General and bp.General.CommandCaps and (
                        bp.General.CommandCaps.RULEUCC_CallTransport or bp.General.CommandCaps.RULEUCC_Dock
                    )
                )
            ) and iconText('Attached',
                transportClassHookType(bp.Transport and bp.Transport.TransportClass or 1)
            )
        )},
        {'Transport capacity:', iconText('Attached',
            (
                bp.General and
                bp.General.CommandCaps and
                bp.General.CommandCaps.RULEUCC_Transport
                and bp.Transport
            ) and (
                bp.Transport.Class1Capacity and
                bp.Transport.Class1Capacity..' (<a href="#transport-capacity">Details</a>)'
            )
        )},
        {''},
        {'Misc radius:', bp.CategoriesHash.OVERLAYMISC and bp.AI and bp.AI.StagingPlatformScanRadius, 'Defined by the air staging radius value. Often used to indicate things without a dedicated range ring.' },
        {'Weapons:', bp.Weapon and #bp.Weapon..' (<a href="#weapons">Details</a>)'},
    }
end

InfoboxFlagsList = function(spec)
    return setmetatable(spec, {

        __tostring = function(self)
            local s = ''
            for i, v in ipairs(self) do
                if v and tostring(v) ~= '' then
                    if s ~= '' then
                        s = s..'<br />'
                    end
                    s = s..tostring(v)
                end
            end
            return s
        end,

        __eq = function(t1, t2)
            return tostring(t1) == tostring(t2)
        end,

    })
end

local InfoboxHeader = function(style, data)
    local styles = {
        ['main-right1'] = [[
<table align=right>
    <thead>
        <tr>
            <th colspan='2' align=left>
                %s
            </th>
        </tr>
    </thead>
    <tbody>
]],
        ['main-right2'] = [[
<table align=right>
    <thead>
        <tr>
            <th colspan='2'>
                %s
            </th>
        </tr>
        <tr>
            <th colspan='2'>
                %s
            </th>
        </tr>
    </thead>
    <tbody>
]],
        ['detail-left1'] = "<details>\n<summary>%s</summary>\n<p>\n    <table>\n",
    }
    return string.format(styles[style..#data], table.unpack(data))
end

local InfoboxRow = function(th, td, tip)
    if th == '' then
        return "        <tr><td colspan='2' align=center>"..(td or '').."</td></tr>\n"
    elseif td and tostring(td) ~= '' then
        return "        <tr>\n            <td align=right><strong>"
        ..(th or '').."</strong></td>\n            <td>"
        ..tostring(td)..hoverTip(tip).."</td>\n        </tr>\n"
    end
    return ''
end

local InfoboxEnd = function(style)
    local styles = {
        ['main-right'] = "    </tbody>\n</table>\n\n",
        ['detail-left'] = "    </table>\n</p>\n</details>\n",
    }
    return styles[style]
end

Infobox = function(spec)
    return setmetatable(spec, {

        __tostring = function(self)
            local infoboxstring = InfoboxHeader(self.Style, self.Header )
            if type(self.Data) == 'string' then
                infoboxstring = infoboxstring .. self.Data
            else
                for i, field in ipairs(self.Data) do
                    infoboxstring = infoboxstring .. InfoboxRow( table.unpack(field) )
                end
            end
            return infoboxstring .. InfoboxEnd(self.Style)
        end,

    })
end

DoToInfoboxDataCell = function(fun, infodata, key, value)
    for i, v in ipairs(infodata) do
        if v[1] == key then
            fun(v[2], value)
            break
        end
    end
end
