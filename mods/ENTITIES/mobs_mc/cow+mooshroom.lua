--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local cow_def = {
	description = S("Cow"),
	type = "animal",
	spawn_class = "passive",
	_spawn_category = "creature",
	runaway = true,
	passive = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.45, 0.0, -0.45, 0.45, 1.4, 0.45},
	spawn_in_group = 4,
	spawn_in_group_min = 3,
	visual = "mesh",
	mesh = "mobs_mc_cow.b3d",
	textures = {
		{
			"mobs_mc_cow.png",
			"blank.png",
		},
	},
	head_swivel = "head.control",
	bone_eye_height = 10,
	head_eye_height = 1.3,
	horizontal_head_height=-1.8,
	curiosity = 2,
	head_yaw = "z",
	makes_footstep_sound = true,
	movement_speed = 4.0,
	drops = {
		{
			name = "mcl_mobitems:beef",
			chance = 1,
			min = 1,
			max = 3,
			looting = "common",
		},
		{
			name = "mcl_mobitems:leather",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
	},
	sounds = {
		random = {name = "mobs_mc_cow", gain = 0.5},
		damage = "mobs_mc_cow_hurt",
		death = "mobs_mc_cow_hurt",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 40,
		run_start = 0, run_end = 40, run_speed = 40,
	},
	_child_animations = {
		stand_start = 41, stand_end = 41,
		walk_start = 41, walk_end = 81, walk_speed = 80,
		run_start = 41, run_end = 81, run_speed = 80,
	},
	follow = {
		"mcl_farming:wheat_item",
	},
	run_bonus = 2.0,
}

------------------------------------------------------------------------
-- Cow interaction.
------------------------------------------------------------------------

function cow_def:on_rightclick (clicker)
	if self:follow_holding(clicker) and self:feed_tame(clicker, 4, true, false) then return end
	if self.child then return end

	local item = clicker:get_wielded_item()
	if item:get_name() == "mcl_buckets:bucket_empty" and clicker:get_inventory() then
		local inv = clicker:get_inventory()
		inv:remove_item("main", "mcl_buckets:bucket_empty")
		core.sound_play("mobs_mc_cow_milk", {pos=self.object:get_pos(), gain=0.6})
		-- if room add bucket of milk to inventory, otherwise drop as item
		if inv:room_for_item("main", {name = "mcl_mobitems:milk_bucket"}) then
			clicker:get_inventory():add_item("main", "mcl_mobitems:milk_bucket")
		else
			local pos = self.object:get_pos()
			pos.y = pos.y + 0.5
			core.add_item(pos, {name = "mcl_mobitems:milk_bucket"})
		end
	end
end

------------------------------------------------------------------------
-- Cow AI.
------------------------------------------------------------------------

cow_def.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.follow_herd,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:cow", cow_def)

------------------------------------------------------------------------
-- Mooshroom.
------------------------------------------------------------------------

local mooshroom = table.merge(cow_def, {
	description = S("Mooshroom"),
	spawn_in_group_min = 4,
	spawn_in_group = 8,
	textures = {
		{"mobs_mc_mooshroom.png", "mobs_mc_mushroom_red.png"},
		{"mobs_mc_mooshroom_brown.png", "mobs_mc_mushroom_brown.png" },
	},
})

function mooshroom:on_rightclick (clicker)
	if self:follow_holding(clicker) and self:feed_tame(clicker, 4, true, false) then return end
	if self.child then return end

	local item = clicker:get_wielded_item()
	local item_name = item:get_name()
	-- Use shears to get mushrooms and turn mooshroom into cow
	if core.get_item_group(item_name, "shears") > 0 then
		local pos = self.object:get_pos()
		core.sound_play("mcl_tools_shears_cut", {pos = pos}, true)

		if self.base_texture[1] == "mobs_mc_mooshroom_brown.png" then
			core.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, "mcl_mushrooms:mushroom_brown 5")
		else
			core.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, "mcl_mushrooms:mushroom_red 5")
		end
		mcl_util.replace_mob(self.object, "mobs_mc:cow")

		if not core.is_creative_enabled(clicker:get_player_name()) then
			local wear = mcl_autogroup.get_wear(item_name, "shearsy")
			item:add_wear(wear)
			clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
		end
		-- Use bucket to milk
	elseif item_name == "mcl_buckets:bucket_empty" and clicker:get_inventory() then
		local inv = clicker:get_inventory()
		inv:remove_item("main", "mcl_buckets:bucket_empty")
		core.sound_play("mobs_mc_cow_milk", {pos=self.object:get_pos(), gain=0.6})
		-- If room, add milk to inventory, otherwise drop as item
		if inv:room_for_item("main", {name="mcl_mobitems:milk_bucket"}) then
			clicker:get_inventory():add_item("main", "mcl_mobitems:milk_bucket")
		else
			local pos = self.object:get_pos()
			pos.y = pos.y + 0.5
			core.add_item(pos, {name = "mcl_mobitems:milk_bucket"})
		end
		-- Use bowl to get mushroom stew
	elseif item_name == "mcl_core:bowl" and clicker:get_inventory() then
		local inv = clicker:get_inventory()
		inv:remove_item("main", "mcl_core:bowl")
		core.sound_play("mobs_mc_cow_mushroom_stew", {pos=self.object:get_pos(), gain=0.6})
		-- If room, add mushroom stew to inventory, otherwise drop as item
		if inv:room_for_item("main", {name="mcl_mushrooms:mushroom_stew"}) then
			clicker:get_inventory():add_item("main", "mcl_mushrooms:mushroom_stew")
		else
			local pos = self.object:get_pos()
			pos.y = pos.y + 0.5
			core.add_item(pos, {name = "mcl_mushrooms:mushroom_stew"})
		end
	end
end

function mooshroom:_on_lightning_strike ()
	if self.base_texture[1] == "mobs_mc_mooshroom_brown.png" then
		self.base_texture = { "mobs_mc_mooshroom.png", "mobs_mc_mushroom_red.png" }
	else
		self.base_texture = { "mobs_mc_mooshroom_brown.png", "mobs_mc_mushroom_brown.png" }
	end
	self:set_textures (self.base_texture)
	return true
end

function mooshroom:_on_dispense (dropitem, pos, droppos, dropnode, dropdir)
	if core.get_item_group(dropitem:get_name(), "shears") > 0 then
		local droppos = vector.offset(pos, 0, 1.4, 0)
		if self.base_texture[1] == "mobs_mc_mooshroom_brown.png" then
			core.add_item(droppos, "mcl_mushrooms:mushroom_brown 5")
		else
			core.add_item(droppos, "mcl_mushrooms:mushroom_red 5")
		end
		mcl_util.replace_mob(self.object, "mobs_mc:cow")
		return dropitem
	end
	return mcl_mobs.mob_class._on_dispense(self, dropitem, pos, droppos, dropnode, dropdir)
end

mcl_mobs.register_mob ("mobs_mc:mooshroom", mooshroom)

------------------------------------------------------------------------
-- Cow & Mooshroom spawning.
------------------------------------------------------------------------

mcl_mobs.spawn_setup({
	name = "mobs_mc:cow",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	min_height = mobs_mc.water_level,
	biomes = {
		"flat",
		"MegaTaiga",
		"MegaSpruceTaiga",
		"ExtremeHills",
		"ExtremeHills_beach",
		"ExtremeHillsM",
		"ExtremeHills+",
		"StoneBeach",
		"Plains",
		"Plains_beach",
		"SunflowerPlains",
		"Taiga",
		"Taiga_beach",
		"Forest",
		"Forest_beach",
		"FlowerForest",
		"FlowerForest_beach",
		"BirchForest",
		"BirchForestM",
		"RoofedForest",
		"Savanna",
		"Savanna_beach",
		"SavannaM",
		"Jungle",
		"BambooJungle",
		"Jungle_shore",
		"JungleM",
		"JungleM_shore",
		"JungleEdge",
		"JungleEdgeM",
		"Swampland",
		"Swampland_shore"
	},
	chance = 80,
})

mcl_mobs.spawn_setup({
	name = "mobs_mc:mooshroom",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	min_height = mobs_mc.water_level,
	biomes = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 80,
})

-- spawn egg
mcl_mobs.register_egg("mobs_mc:cow", S("Cow"), "#443626", "#a1a1a1", 0)
mcl_mobs.register_egg("mobs_mc:mooshroom", S("Mooshroom"), "#a00f10", "#b7b7b7", 0)

------------------------------------------------------------------------
-- Modern Cow & Mooshroom spawning.
------------------------------------------------------------------------

local cow_spawner = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:cow",
	biomes = mobs_mc.farm_animal_biomes,
	weight = 12,
})

mcl_mobs.register_spawner (cow_spawner)

local mooshroom_spawner = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:mooshroom",
	biomes = {
		"MushroomIslandShore",
		"MushroomIsland",
	},
	weight = 8,
	pack_min = 4,
	pack_max = 8,
})

function mooshroom_spawner:test_supporting_node (node)
	return core.get_item_group (node.name, "mycelium") > 0
end

mcl_mobs.register_spawner (mooshroom_spawner)
