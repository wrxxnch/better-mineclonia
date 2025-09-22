--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")

local slime_chunk_spawn_max = mcl_worlds.layer_to_y(40)

local only_peaceful_mobs
	= core.settings:get_bool ("only_peaceful_mobs", false)

local mapgen_seed = core.get_mapgen_setting("seed")

local function in_slime_chunk(pos)
	local encoded_pos = (math.floor(pos.x / 16) + 2048) * 4096 + (math.floor(pos.z / 16) + 2048)
	encoded_pos = PcgRandom(encoded_pos):next() + mapgen_seed
	return PcgRandom(encoded_pos):next(1, 10) == 1   -- 1/10th chance that mapblock column is a slime chunk
end

-- If the light level is equal to or less than a random integer (from 0 to 7)
-- If the fraction of the moon that is bright is greater than a random number (from 0 to 1)
-- If these conditions are met and the altitude is acceptable, there is a 50% chance of spawning a slime.
-- https://minecraft.wiki/w/Slime#Swamps

local function swamp_spawn(pos)
	local light = (core.get_node_light (pos) or core.LIGHT_MAX)
	if light > math.random(0,7) then return false end
	if math.abs(4 - mcl_moon.get_moon_phase()) / 4 < math.random() then return false end --moon phase 4 is new moon in mcl_moon
	if math.random(2) == 2 then return false end
	return true
end

-- Returns a function that spawns children in a circle around pos.
-- To be used as on_die callback.
-- self: mob reference
-- pos: position of "mother" mob
-- child_mod: Mob to spawn
-- spawn_distance: Spawn distance from "mother" mob
-- eject_speed: Initial speed of child mob away from "mother" mob
local spawn_children_on_die = function(child_mob, spawn_distance, eject_speed)
	return function(self, pos)
		local posadd, newpos, dir
		if not eject_speed then
			eject_speed = 1
		end
		local mndef = core.registered_nodes[core.get_node(pos).name]
		local mother_stuck = mndef and mndef.walkable
		local angle = math.random(0, math.pi*2)
		local spawn_count = math.random(2, 4)
		for _ = 1, spawn_count do
			dir = vector.new(math.cos(angle), 0, math.sin(angle))
			posadd = vector.normalize(dir) * spawn_distance
			newpos = pos + posadd
			-- If child would end up in a wall, use position of the "mother", unless
			-- the "mother" was stuck as well
			if not mother_stuck then
				local cndef = core.registered_nodes[core.get_node(newpos).name]
				if cndef and cndef.walkable then
					newpos = pos
					eject_speed = eject_speed * 0.5
				end
			end
			local mob = core.add_entity(newpos, child_mob, core.serialize({ persist_in_peaceful = self.persist_in_peaceful }))
			if mob and mob:get_pos() and not mother_stuck then
				mob:set_velocity(dir * eject_speed)
			end
		end
	end
end

local swamp_light_max = 7

local function slime_check_light(pos, _, artificial_light, sky_light)
	local maxlight = swamp_light_max

	if pos.y <= slime_chunk_spawn_max and in_slime_chunk(pos) then
		maxlight = core.LIGHT_MAX + 1
	end

	return math.max(artificial_light, sky_light) <= maxlight
end

-- Slime movement.

local function slime_do_go_pos (self, dtime, moveresult)
	-- The target position is ignored.
	local speed = self.movement_velocity

	if not self._next_jump then
		self._next_jump = 0
	end

	local delay = math.max (0, self._next_jump - dtime)
	if delay == 0 or self._in_water
		or not (moveresult.touching_ground
			or moveresult.standing_on_object) then
		if delay == 0 then
			self._jump = true
			delay = (math.random (60) + 40) / 20 * self.jump_delay_multiplier
			if self.attack then
				delay = delay / 3
			end
		end
		self.acc_dir.z = speed / 20
		self.acc_speed = speed
	else
		self.acc_dir.z = 0
		self.acc_speed = 0
	end
	self._next_jump = delay
end

local function slime_turn (self, dtime, self_pos)
	if not self.attack then
		local standing_on = core.registered_nodes[self.standing_on]
		local remaining = self._next_turn
		if not remaining or remaining == 0 then
			remaining = (math.random (60) + 40) / 20
		end

		if standing_on and (standing_on.walkable
				    or standing_on.liquidtype ~= "none") then
			remaining = math.max (0, remaining - dtime)
			if remaining == 0 then
				local angle = math.random () * 2 * math.pi
				self:set_yaw (angle)
			end
		end
		self._next_turn = remaining
	else
		local target_pos = self.attack:get_pos ()
		local dz, dx = target_pos.z - self_pos.z, target_pos.x - self_pos.x
		local yaw = math.atan2 (dz, dx) - math.pi / 2

		self:set_yaw (yaw)
	end
end

local function slime_jump_continuously (self)
	local factor = 1
	self._in_water = false
	if core.get_item_group (self.standing_in, "water") ~= 0
		or core.get_item_group (self.standing_in, "lava") ~= 0 then
		factor = 1.2
		self._in_water = true
	end
	self.movement_goal = "go_pos"
	self.movement_velocity = self.movement_speed * factor
	-- movement_target is disregarded by slimes.
end

local function slime_check_attack (self, self_pos, dtime)
	if not self.attack then
		return
	end
	self._attack_cooldown = math.max (self._attack_cooldown - dtime, 0)
	local target_pos = self.attack:get_pos ()
	local girth = self.collisionbox[6] - self.collisionbox[3]
	if vector.distance (target_pos, self_pos) <= girth + 0.25
	   and self._attack_cooldown == 0 then
		self:custom_attack ()
		self._attack_cooldown = 0.5
	end
end

local function slime_run_ai (self, dtime)
	local self_pos = self.object:get_pos ()

	if self.dead then
		return
	end

	self:check_attack (self_pos, dtime)
	slime_turn (self, dtime, self_pos)
	slime_jump_continuously (self)
	slime_check_attack (self, self_pos, dtime)
end

local function slime_check_particle (self, dtime, moveresult)
	if not self._slime_was_touching_ground
		and moveresult.touching_ground
		and self._get_slime_particle then
		local cbox = self.collisionbox
		local radius = (cbox[6] - cbox[3]) * 0.75
		local self_pos = self.object:get_pos ()
		local v = 1
		core.add_particlespawner ({
			amount = math.round (radius * 32),
			minpos = vector.offset (self_pos, -radius, 0, -radius),
			maxpos = vector.offset (self_pos, radius, 0, radius),
			minvel = vector.new (-v, 0, -v),
			maxvel = vector.new (v, 0, v),
			minacc = vector.new (0, 0, 0),
			maxacc = vector.new (0, 0, 0),
			texture = self._get_slime_particle (),
			time = 0.1,
			minexptime = 0.1,
			maxexptime = 0.6,
			minsize = 0.5,
			maxsize = 1.5,
			glow = self._slime_particle_glow,
		})
	end
	self._slime_was_touching_ground = moveresult.touching_ground
end

local function slime_do_attack (self, target)
	self.attack = target
	self.target_invisible_time = 3.0
	self._sight_persistence = 3.0
	if self._next_jump then
		self._next_jump = self._next_jump / 3
	end
	self._attack_cooldown = 0.5 -- Minecraft damage immunity.
end

-- Slime
local slime_big = {
	description = S("Slime - big"),
	type = "monster",
	spawn_class = "hostile",
	_spawn_category = "monster",
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, 0.0, -1.02, 1.02, 2.0, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{"mobs_mc_slime.png", "mobs_mc_slime.png"}},
	visual = "mesh",
	mesh = "mobs_mc_slime.b3d",
	makes_footstep_sound = true,
	can_ride_boat = false,
	does_not_prevent_sleep = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
		distance = 16,
	},
	sound_params = {
		gain = 1,
	},
	damage = 4,
	reach = 3,
	armor = 100,
	drops = {},
	animation = {
		jump_start = 1,
		jump_end = 20,
		jump_speed = 24,
		jump_loop = false,
		stand_speed = 0,
		walk_speed = 0,
		stand_start = 1,
		stand_end = 1,
		walk_start = 1,
		walk_end = 1,
	},
	do_go_pos = slime_do_go_pos,
	run_ai = slime_run_ai,
	do_attack = slime_do_attack,
	do_custom = slime_check_particle,
	jump_delay_multiplier = 1,
	fall_damage = 0,
	passive = false,
	movement_speed = 10, -- (0.2 + 0.1 * size) * 20
	spawn_small_alternative = "mobs_mc:slime_small",
	on_die = spawn_children_on_die("mobs_mc:slime_small", 1.0, 1.5),
	use_texture_alpha = true,
	check_light = slime_check_light,
	specific_attack = {
		"mobs_mc:iron_golem",
	},
	attack_type = "null",
	_get_slime_particle = function ()
		return "[combine:" .. math.random (3)
			.. "x" .. math.random (3) .. ":-"
			.. math.random (4) .. ",-"
			.. math.random (4) .. "=mcl_core_slime.png"
	end
}
mcl_mobs.register_mob("mobs_mc:slime_big", slime_big)

local slime_small = table.copy(slime_big)
slime_small.description = S("Slime - small")
slime_small.sounds.base_pitch = 1.15
slime_small.hp_min = 4
slime_small.hp_max = 4
slime_small.xp_min = 2
slime_small.xp_max = 2
slime_small.collisionbox = {-0.51, 0.0, -0.51, 0.51, 1.00, 0.51}
slime_small.visual_size = {x=6.25, y=6.25}
slime_small.damage = 3
slime_small.reach = 2.75
slime_small.movement_speed = 6.0
slime_small.spawn_small_alternative = "mobs_mc:slime_tiny"
slime_small.on_die = spawn_children_on_die("mobs_mc:slime_tiny", 0.6, 1.0)
slime_small.sound_params.gain = slime_big.sound_params.gain / 3
mcl_mobs.register_mob("mobs_mc:slime_small", slime_small)

local slime_tiny = table.copy(slime_big)
slime_tiny.description = S("Slime - tiny")
slime_tiny.sounds.base_pitch = 1.3
slime_tiny.hp_min = 1
slime_tiny.hp_max = 1
slime_tiny.xp_min = 1
slime_tiny.xp_max = 1
slime_tiny.collisionbox = {-0.2505, 0.0, -0.2505, 0.2505, 0.50, 0.2505}
slime_tiny.visual_size = {x=3.125, y=3.125}
slime_tiny.damage = 0
slime_tiny.reach = 2.5
slime_tiny.drops = {
	-- slimeball
	{name = "mcl_mobitems:slimeball",
	chance = 1,
	min = 0,
	max = 2,},
}
slime_tiny.can_ride_boat = true
slime_tiny.movement_speed = 4.0
slime_tiny.spawn_small_alternative = nil
slime_tiny.on_die = nil
slime_tiny.sound_params.gain = slime_small.sound_params.gain / 3

mcl_mobs.register_mob("mobs_mc:slime_tiny", slime_tiny)

local water_level = mobs_mc.water_level

local cave_biomes = {
	"FlowerForest_underground",
	"JungleEdge_underground",
	"BambooJungle_underground",
	"StoneBeach_underground",
	"MesaBryce_underground",
	"Mesa_underground",
	"RoofedForest_underground",
	"Jungle_underground",
	"Swampland_underground",
	"MushroomIsland_underground",
	"BirchForest_underground",
	"Plains_underground",
	"MesaPlateauF_underground",
	"ExtremeHills_underground",
	"MegaSpruceTaiga_underground",
	"BirchForestM_underground",
	"SavannaM_underground",
	"MesaPlateauFM_underground",
	"Desert_underground",
	"Savanna_underground",
	"Forest_underground",
	"SunflowerPlains_underground",
	"ColdTaiga_underground",
	"IcePlains_underground",
	"IcePlainsSpikes_underground",
	"MegaTaiga_underground",
	"Taiga_underground",
	"ExtremeHills+_underground",
	"JungleM_underground",
	"ExtremeHillsM_underground",
	"JungleEdgeM_underground",
	"MangroveSwamp_underground"
}

local cave_min = mcl_vars.mg_overworld_min
local cave_max = water_level - 23

local swampy_biomes = {"Swampland", "MangroveSwamp"}
local swamp_min = water_level
local swamp_max = water_level + 27

for slime_name,slime_chance in pairs({
	["mobs_mc:slime_tiny"] = 1000,
	["mobs_mc:slime_small"] = 1000,
	["mobs_mc:slime_big"] = 1000
}) do
	mcl_mobs.spawn_setup({
		name = slime_name,
		type_of_spawning = "ground",
		dimension = "overworld",
		biomes = cave_biomes,
		min_light = 0,
		max_light = core.LIGHT_MAX+1,
		min_height = cave_min,
		max_height = cave_max,
		chance = slime_chance,
		check_position = in_slime_chunk,
	})

	mcl_mobs.spawn_setup({
		name = slime_name,
		type_of_spawning = "ground",
		dimension = "overworld",
		biomes = swampy_biomes,
		min_light = 0,
		max_light = swamp_light_max,
		min_height = swamp_min,
		max_height = swamp_max,
		chance = slime_chance,
		check_position = swamp_spawn,
	})
end

-- Magma cube
local magma_cube_big = {
	description = S("Magma Cube - big"),
	type = "monster",
	spawn_class = "hostile",
	_spawn_category = "monster",
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, 0.0, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{ "mobs_mc_magmacube.png", "mobs_mc_magmacube.png" }},
	visual = "mesh",
	mesh = "mobs_mc_magmacube.b3d",
	makes_footstep_sound = true,
	can_ride_boat = false,
	does_not_prevent_sleep = true,
	sounds = {
		jump = "mobs_mc_magma_cube_big",
		death = "mobs_mc_magma_cube_big",
		attack = "mobs_mc_magma_cube_attack",
		distance = 16,
	},
	sound_params = {
		gain = 1,
		max_hear_distance = 16,
	},
	movement_speed = 10.0,
	damage = 6,
	reach = 3,
	armor = 53,
	drops = {
		{name = "mcl_mobitems:magma_cream",
		chance = 4,
		min = 1,
		max = 1,},
	},
	animation = {
		jump_speed = 40,
		jump_loop = false,
		stand_speed = 0,
		walk_speed = 0,
		jump_start = 0,
		jump_end = 50,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 0,
	},
	do_go_pos = slime_do_go_pos,
	run_ai = slime_run_ai,
	do_attack = slime_do_attack,
	do_custom = slime_check_particle,
	jump_delay_multiplier = 4,
	water_damage = 0,
	_mcl_freeze_damage = 5,
	lava_damage = 0,
        fire_damage = 0,
	fall_damage = 0,
	jump_height = 14.4,
	passive = false,
	spawn_small_alternative = "mobs_mc:magma_cube_small",
	on_die = spawn_children_on_die("mobs_mc:magma_cube_small", 0.8, 1.5),
	fire_resistant = true,
	specific_attack = {
		"mobs_mc:iron_golem",
	},
	_get_slime_particle = function ()
		return "mcl_particles_fire_flame.png"
	end,
	attack_type = "null",
	_slime_particle_glow = 14,
}
mcl_mobs.register_mob("mobs_mc:magma_cube_big", magma_cube_big)

local magma_cube_small = table.copy(magma_cube_big)
magma_cube_small.description = S("Magma Cube - small")
magma_cube_small.sounds.jump = "mobs_mc_magma_cube_small"
magma_cube_small.sounds.death = "mobs_mc_magma_cube_small"
magma_cube_small.hp_min = 4
magma_cube_small.hp_max = 4
magma_cube_small.xp_min = 2
magma_cube_small.xp_max = 2
magma_cube_small.collisionbox = {-0.51, 0.0, -0.51, 0.51, 1.00, 0.51}
magma_cube_small.visual_size = {x=6.25, y=6.25}
magma_cube_small.damage = 3
magma_cube_small.reach = 2.75
magma_cube_small.movement_speed = 6.0
magma_cube_small.jump_height = 12.4
magma_cube_small.damage = 4
magma_cube_small.reach = 2.75
magma_cube_small.armor = 66
magma_cube_small.spawn_small_alternative = "mobs_mc:magma_cube_tiny"
magma_cube_small.on_die = spawn_children_on_die("mobs_mc:magma_cube_tiny", 0.6, 1.0)
magma_cube_small.sound_params.gain = 0.7 -- has different sound file from big
mcl_mobs.register_mob("mobs_mc:magma_cube_small", magma_cube_small)

local magma_cube_tiny = table.copy(magma_cube_big)
magma_cube_tiny.description = S("Magma Cube - tiny")
magma_cube_tiny.sounds.jump = "mobs_mc_magma_cube_small"
magma_cube_tiny.sounds.death = "mobs_mc_magma_cube_small"
magma_cube_tiny.sounds.base_pitch = 1.25
magma_cube_tiny.hp_min = 1
magma_cube_tiny.hp_max = 1
magma_cube_tiny.xp_min = 1
magma_cube_tiny.xp_max = 1
magma_cube_tiny.collisionbox = {-0.2505, 0.0, -0.2505, 0.2505, 0.50, 0.2505}
magma_cube_tiny.visual_size = {x=3.125, y=3.125}
magma_cube_tiny.can_ride_boat = true
magma_cube_tiny.movement_speed = 4.0
magma_cube_tiny.jump_height = 8.4
magma_cube_tiny.damage = 3
magma_cube_tiny.reach = 2.5
magma_cube_tiny.armor = 50
magma_cube_tiny.drops = {}
magma_cube_tiny.spawn_small_alternative = nil
magma_cube_tiny.on_die = nil
magma_cube_tiny.sound_params.gain = magma_cube_small.sound_params.gain / 3

mcl_mobs.register_mob("mobs_mc:magma_cube_tiny", magma_cube_tiny)

for magma_name,magma_chance in pairs({
	["mobs_mc:magma_cube_tiny"] = 100,
	["mobs_mc:magma_cube_small"] = 100,
	["mobs_mc:magma_cube_big"] = 100
}) do
	mcl_mobs.spawn_setup({
		name = magma_name,
		type_of_spawning = "ground",
		dimension = "nether",
		min_light = 0,
		max_light = core.LIGHT_MAX+1,
		chance = magma_chance,
		biomes = {"Nether", "BasaltDelta"},
	})
end

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:magma_cube_big", S("Magma Cube"), "#350000", "#fcfc00")

mcl_mobs.register_egg("mobs_mc:slime_big", S("Slime"), "#52a03e", "#7ebf6d")

------------------------------------------------------------------------
-- Modern Slime & Magma Cube spawning.
------------------------------------------------------------------------

local default_spawner = mcl_mobs.default_spawner
local slime_spawner = table.merge (default_spawner, {
	spawn_placement = "ground",
	spawn_category = "monster",
	name = "mobs_mc:slime_big", -- Nominal name; governs collision tests.
	weight = 100,
	pack_max = 4,
	pack_min = 4,
	biomes = mobs_mc.monster_biomes,
})

function slime_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache)
	if mcl_vars.difficulty == 0 or only_peaceful_mobs then
		return false
	end

	local biome = core.get_biome_data (node_pos)
	if biome then
		local name = core.get_biome_name (biome.biome)
		if name == "Swampland" or name == "MangroveSwamp" then
			if swamp_spawn (spawn_pos) then
				if default_spawner.test_spawn_position (self, spawn_pos,
									node_pos, sdata,
									node_cache) then
					return true
				end
			end
		end

		if spawn_pos.y <= slime_chunk_spawn_max + 0.5
			and math.random (1, 10) == 1
			and in_slime_chunk (spawn_pos) then
			return default_spawner.test_spawn_position (self, spawn_pos,
								    node_pos, sdata,
								    node_cache)
		end
	end
	return false
end

function slime_spawner:spawn (spawn_pos, _)
	local slime_type = "mobs_mc:slime_tiny"

	local random = math.random (1, 3)
	if math.random () < 0.5 * mcl_worlds.get_special_difficulty (spawn_pos) then
		random = math.max (random + 1, 3)
	end
	if random == 2 then
		slime_type = "mobs_mc:slime_small"
	elseif random == 3 then
		slime_type = "mobs_mc:slime_big"
	end

	return core.add_entity (spawn_pos, slime_type)
end

mcl_mobs.register_spawner (slime_spawner)

local default_spawner = mcl_mobs.default_spawner

local magma_cube_spawner = {
	name = "mobs_mc:magma_cube_big",
	spawn_category = "monster",
	weight = 2,
	pack_min = 4,
	pack_max = 4,
	biomes = {
		"Nether",
	},
}

function magma_cube_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache)
	return mcl_vars.difficulty > 0
		and default_spawner.test_spawn_position (self, spawn_pos,
							 node_pos, sdata,
							 node_cache)
end

function magma_cube_spawner:spawn (spawn_pos, _)
	local slime_type = "mobs_mc:magma_cube_tiny"

	local random = math.random (1, 3)
	if math.random () < 0.5 * mcl_worlds.get_special_difficulty (spawn_pos) then
		random = math.max (random + 1, 3)
	end
	if random == 2 then
		slime_type = "mobs_mc:magma_cube_small"
	elseif random == 3 then
		slime_type = "mobs_mc:magma_cube_big"
	end

	return core.add_entity (spawn_pos, slime_type)
end

local magma_cube_spawner_basalt_delta = table.merge (magma_cube_spawner, {
	weight = 100,
	pack_min = 2,
	pack_max = 5,
	biomes = {
		"BasaltDelta",
	},
})

mcl_mobs.register_spawner (magma_cube_spawner)
mcl_mobs.register_spawner (magma_cube_spawner_basalt_delta)
