-- No-op in MCL2 (capturing mobs is not possible).
-- Provided for compability with Mobs Redo
function mcl_mobs.capture_mob() return false end

-- No-op in MCL2 (protecting mobs is not possible).
function mcl_mobs.protect() return false end

-- this is to make the register_mob and register egg functions commonly used by mods not break
-- when they use the weird old : notation AND self as first argument
local oldregmob = mcl_mobs.register_mob
function mcl_mobs.register_mob(self,name,def) ---@diagnostic disable-line: duplicate-set-field
	if type(self) == "string" then
		def = name
		name = self
	end
	return oldregmob(name,def)
end
local oldregegg = mcl_mobs.register_egg
function mcl_mobs.register_egg(self, mob, desc, background_color, overlay_color, addegg, no_creative) ---@diagnostic disable-line: duplicate-set-field
	if type(self) == "string" then
		no_creative = addegg
		addegg = overlay_color
		overlay_color = background_color
		background_color = desc
		desc = mob
		mob = self
	end
	return oldregegg(mob, desc, background_color, overlay_color, addegg, no_creative)
end

local oldregarrow = mcl_mobs.register_arrow
function mcl_mobs.register_arrow(self,name,def) ---@diagnostic disable-line: duplicate-set-field
	if type(self) == "string" then
		def = name
		name = self
	end
	return oldregarrow(name,def)
end

function mcl_mobs.spawn_specific(name, dimension, type_of_spawning, biomes, min_light, max_light, _, chance, aoc, min_height, max_height, day_toggle, on_spawn)
	mcl_mobs.spawn_setup({
		name             = name,
		dimension        = dimension,
		type_of_spawning = type_of_spawning,
		biomes           = biomes,
		min_light        = min_light,
		max_light        = max_light,
		chance           = chance,
		aoc              = aoc,
		min_height       = min_height,
		max_height       = max_height,
		day_toggle       = day_toggle,
		on_spawn         = on_spawn,
	})
end

------------------------------------------------------------------------
-- Mobs Redo compatibility.  Undefine the is_mob field of every mob
-- registered through Mobs Redo, which field is not used by Mobs Redo
-- and is only counterproductively defined for compatibility with
-- Mineclone.
------------------------------------------------------------------------

if core.global_exists ("mobs") then
	core.register_on_mods_loaded (function ()
		for name, mob in pairs (core.registered_entities) do
			if mob._cmi_is_mob and mob.is_mob then
				mob.is_mob = false
				local blurb = "[mcl_mobs_combat]: Undefining gratuitous"
					.. " is_mob field in " .. name
				core.log ("action", blurb)
			end
		end
	end)
end
