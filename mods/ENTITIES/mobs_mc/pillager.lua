local only_peaceful_mobs
	= core.settings:get_bool ("only_peaceful_mobs", false)
local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local posing_humanoid = mcl_mobs.posing_humanoid
local illager = mobs_mc.illager

local pillager = table.merge (illager, table.merge (posing_humanoid, {
	description = S("Pillager"),
	type = "monster",
	_spawn_category = "monster",
	spawn_class = "hostile",
	hp_min = 24,
	hp_max = 24,
	xp_min = 6,
	xp_max = 6,
	breath_max = -1,
	eye_height = 1.5,
	shoot_interval = 3,
	shoot_offset = 0.5,
	armor = {fleshy = 100},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.95, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_pillager.b3d",
	visual_size = {
		x = 2.75,
		y = 2.75,
	},
	makes_footstep_sound = true,
	movement_speed = 7.0,
	attack_type = "crossbow",
	specific_attack = {
		"mobs_mc:iron_golem",
		"mobs_mc:villager",
		"mobs_mc:wandering_trader",
	},
	group_attack = {
		"mobs_mc:evoker",
		"mobs_mc:vindicator",
		"mobs_mc:pillager",
		"mobs_mc:illusioner",
		"mobs_mc:witch",
	},
	sounds = {
		random = {name = "mobs_mc_pillager_grunt2", gain=0.5},
		war_cry = {name = "mobs_mc_pillager_grunt1", gain=0.5},
		death = "mobs_mc_pillager_ow2",
		damage = "mobs_mc_pillager_ow1",
		distance = 16,
	},
	textures = {
		{
			"mobs_mc_pillager.png", -- Skin
		}
	},
	drops = {
		{
			name = "mcl_bows:arrow",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
	},
	animation = {
		stand_start = 0,
		stand_end = 0,
		stand_speed = 0,
		walk_start = 0,
		walk_end = 39,
		walk_speed = 25,
		run_start = 0,
		run_end = 39,
		run_speed = 25,
	},
	can_wield_items = "no_pickup",
	wielditem_drop_probability = 0.085,
	wielditem_info = {
		toollike_position = vector.new (1.3, 1.8, -0.1),
		toollike_rotation = vector.new (0, 0, -45),
		crossbow_position = vector.new (0.475, 1.8, -0.1),
		crossbow_rotation = vector.new (-90, 45, -90),
		blocklike_position = vector.new (0.8, 1.8, 0),
		blocklike_rotation = vector.new (180, -45, 0),
		position = vector.new (0.8, 1.8, 0),
		rotation = vector.new (-90, 0, 0),
		bone = "wield",
		rotate_bone = true,
	},
	pace_bonus = 0.6,
	_humanoid_superclass = illager,
	view_range = 32.0,
	tracking_distance = 32.0,
}))

------------------------------------------------------------------------
-- Pillager mechanics.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () - 377)

function pillager:on_spawn ()
	illager.on_spawn (self)

	local self_pos = self.object:get_pos ()
	local mob_factor = mcl_worlds.get_special_difficulty (self_pos)
	self:set_wielditem (ItemStack ("mcl_bows:crossbow"))
	self:enchant_default_weapon (mob_factor, pr)
end

function pillager:enchant_default_weapon (mob_factor, pr)
	mob_class.enchant_default_weapon (self, mob_factor, pr)

	if pr:next (1, 300) == 1 then
		local wielditem = self:get_wielditem ()
		local name = wielditem:get_name ()
		if name ~= "mcl_bows:crossbow"
			and name ~= "mcl_bows:crossbow_enchanted" then
			return
		end
		mcl_enchanting.enchant (wielditem, "piercing", 1)
		self:set_wielditem (wielditem)
	end
end

function pillager:apply_raid_buffs (stage)
	illager.apply_raid_buffs (self, stage)

	local raid = self:_get_active_raid ()
	if mcl_raids.should_enchant (raid) then
		local wielditem = self:get_wielditem ()
		local name = wielditem:get_name ()
		if name ~= "mcl_bows:crossbow"
			and name ~= "mcl_bows:crossbow_enchanted" then
			return
		end
		if stage > 5 then -- Max number of stages on Normal difficulty.
			mcl_enchanting.enchant (wielditem, "quick_charge", 2)
		elseif stage > 3 then -- Max number of stages on Easy difficulty.
			mcl_enchanting.enchant (wielditem, "quick_charge", 1)
		end
		mcl_enchanting.enchant (wielditem, "multishot", 1)
		self:set_wielditem (wielditem)
	end
end

function pillager:drop_custom (looting_level)
	illager.drop_custom (self, looting_level)

	-- The MC wiki is wrong when it states that these bottles are
	-- dropped by all raid captains spawned independently of
	-- raids.  They are only dropped by Pillagers.
	if not self:_get_active_raid () and self._raidcaptain then
		local self_pos = self.object:get_pos ()
		local stack = ItemStack ("mcl_potions:ominous")
		core.add_item (self_pos, stack)
	end
end

------------------------------------------------------------------------
-- Pillager visuals.
------------------------------------------------------------------------

function pillager:get_rightarm_with_pitch ()
	local pitch = 0
	if self.attack then
		local target_pos = self.attack:get_pos ()
		if target_pos then
			local self_pos = self.object:get_pos ()
			local dx = target_pos.x - self_pos.x
			local dy = target_pos.y - (self_pos.y + self.head_eye_height)
			local dz = target_pos.z - self_pos.z
			local xz_mag = math.sqrt (dx * dx + dz * dz)
			pitch = math.atan2 (dy, xz_mag)
		end
	end
	return vector.new (math.rad (-110), -pitch, math.rad (90))
end

function pillager:get_leftarm_with_pitch ()
	local pitch = 0
	if self.attack then
		local target_pos = self.attack:get_pos ()
		if target_pos then
			local self_pos = self.object:get_pos ()
			local dx = target_pos.x - self_pos.x
			local dy = target_pos.y - (self_pos.y + self.head_eye_height)
			local dz = target_pos.z - self_pos.z
			local xz_mag = math.sqrt (dx * dx + dz * dz)
			pitch = math.atan2 (dy, xz_mag)
		end
	end
	return vector.new (math.rad (-90) + pitch, math.rad (20), 0)
end

pillager._arm_poses = {
	default = {
		["arm.right"] = {
			nil,
			vector.new (-110, 0, 90),
		},
		["arm.left"] = {
			nil,
			vector.new (-90, 20, 0),
			vector.new (1, 1, 1),
		},
	},
	crossbow_1 = {
		["arm.right"] = {
			nil,
			vector.new (-110, 45, 90),
		},
		["arm.left"] = {
			nil,
			vector.new (-110, 40, 0),
			vector.new (1, 1, 1),
		},
	},
	crossbow_2 = {
		["arm.right"] = {
			nil,
			pillager.get_rightarm_with_pitch,
		},
		["arm.left"] = {
			nil,
			pillager.get_leftarm_with_pitch,
		},
	},
}

pillager._arm_pose_continuous = {
	default = false,
	crossbow_1 = false,
	crossbow_2 = true,
}

function pillager:select_arm_pose ()
	if self.attack then
		if self._crossbow_state == 1 then
			return "crossbow_1"
		elseif self._crossbow_state == 2 then
			return "crossbow_2"
		end
	end
	return "default"
end

function pillager:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	size.x = size.x / 2.75
	size.y = size.y / 2.75
	return rot, pos, size
end

------------------------------------------------------------------------
-- Pillager combat.
------------------------------------------------------------------------

function pillager:shoot_arrow (pos, dir)
	local wielditem = self:get_wielditem ()
	if core.get_item_group (wielditem:get_name (), "crossbow") == 0 then
		wielditem = nil
	end
	mcl_bows.shoot_arrow_crossbow ("mcl_bows:arrow", pos, dir, self:get_yaw (),
				       self.object, 32.0, nil, true, wielditem, false)
	self._time_inactive = 0.0
end

------------------------------------------------------------------------
-- Pillager AI.
------------------------------------------------------------------------

pillager.ai_functions = {
	illager.check_recover_banner,
	mob_class.check_attack,
	illager.check_pathfind_to_raid,
	illager.check_distant_patrol,
	illager.check_navigate_village,
	illager.check_celebrate,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:pillager", pillager)
mcl_mobs.register_egg ("mobs_mc:pillager", S("Pillager"), "#532f36", "#959b9b", 0)

------------------------------------------------------------------------
-- Pillager spawning.
------------------------------------------------------------------------

local mobs_spawn = core.settings:get_bool ("mobs_spawn", true)
local mushroom_island = core.get_biome_id ("MushroomIsland")
local mushroom_island_shore = core.get_biome_id ("MushroomIslandShore")

local next_spawn_attempt = (12000 + pr:next (0, 1200)) / 20

local function is_clear (nodepos, x, y, z)
	local nodepos = vector.offset (nodepos, x, y, z)
	local node = core.get_node (nodepos)
	local def = core.registered_nodes[node.name]
	return def and not def.walkable and def.liquidtype == "none"
end

local function is_solid (nodepos, x, y, z)
	local nodepos = vector.offset (nodepos, x, y, z)
	local node = core.get_node (nodepos)
	local def = core.registered_nodes[node.name]
	return def and def.walkable and def.groups.opaque
end

local function spawn_patrolman (nodepos, as_leader)
	-- Ensure adequate clearance.
	local clearance = is_clear (nodepos, 0, 1, 0)
		and is_clear (nodepos, 0, 0, 0)
	-- Ensure solid footing.
	local solid = is_solid (nodepos, 0, -1, 0)
	-- Ensure that the block is spawnable and is sufficiently
	-- dark.
	local node = core.get_node (nodepos)
	local light = core.get_artificial_light (node.param1)
	if clearance and solid and light <= 8 then
		-- Success.
		local staticdata = {
			_raidcaptain = as_leader,
			_patrolling = true,
			_patrol_spawn = true,
		}
		local str = core.serialize (staticdata)
		local surface = vector.offset (nodepos, 0, -0.5, 0)
		local object = core.add_entity (surface, "mobs_mc:pillager", str)
		if as_leader and object then
			local entity = object:get_luaentity ()
			entity:select_patrol_target (nodepos)
		end
		return object ~= nil
	end
	return false
end

core.register_globalstep (function (dtime)
	if mcl_vars.difficulty == 0 or not mobs_spawn or only_peaceful_mobs then
		return
	end
	next_spawn_attempt = next_spawn_attempt - dtime
	if next_spawn_attempt <= 0 then
		next_spawn_attempt = (12000 + pr:next (0, 1200)) / 20

		local days = core.get_day_count ()
		if days < 5 or not mcl_util.is_daytime ()
			or pr:next (1, 5) ~= 1 then
			return
		end

		-- Select a player in the overworld at random.
		local players_in_overworld = {}
		for player in mcl_util.connected_players () do
			local pos = player:get_pos ()
			local dim = mcl_worlds.pos_to_dimension (pos)

			if dim == "overworld" then
				table.insert (players_in_overworld, player)
			end
		end
		local nplayers = #players_in_overworld
		if nplayers == 0 then
			return
		end
		local player = players_in_overworld[pr:next (1, nplayers)]
		local pos = player:get_pos ()
		local nodepos = mcl_util.get_nodepos (pos)
		if mcl_villages.get_poi_heat (nodepos) >= 4 then
			-- The player is too close to a village.
			return
		end

		local s1 = pr:next (1, 2) == 1 and -1 or 1
		local s2 = pr:next (1, 2) == 1 and -1 or 1
		nodepos.x = nodepos.x + (pr:next (24, 48) * s1)
		nodepos.z = nodepos.z + (pr:next (24, 48) * s2)

		-- Verify that spawning will not take place in an
		-- ineligible biome.
		local biome = core.get_biome_data (nodepos)
		if not biome
			or biome.biome == mushroom_island
			or biome.biome == mushroom_island_shore then
			return
		end

		-- Spawn pillagers.
		local n_pillagers
			= mcl_worlds.get_regional_difficulty (nodepos)
		n_pillagers = math.ceil (n_pillagers)

		for i = 1, n_pillagers do
			nodepos = mobs_mc.find_surface_position (nodepos)
			-- Fail if the leader cannot be spawned.
			if not spawn_patrolman (nodepos, i == 1) and i == 1 then
				break
			end
			nodepos.x = nodepos.x + pr:next (0, 4) - pr:next (0, 4)
			nodepos.y = nodepos.y + pr:next (0, 4) - pr:next (0, 4)
		end
	end
end)

core.register_chatcommand ("spawn_patrol_now", {
	privs = { server = true, },
	func = function (playername, param)
		next_spawn_attempt = 0
	end,
})
