--###################
--################### ENDERMITE
--###################

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local endermite = {
	description = S("Endermite"),
	type = "monster",
	spawn_class = "hostile",
	_spawn_category = "monster",
	passive = false,
	hp_min = 8,
	hp_max = 8,
	xp_min = 3,
	xp_max = 3,
	armor = {fleshy = 100, arthropod = 100},
	group_attack = true,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.29, 0.2},
	visual = "mesh",
	mesh = "mobs_mc_endermite.b3d",
	textures = {
		{"mobs_mc_endermite.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_mc_endermite_random",
		damage = "mobs_mc_endermite_hurt",
		death = "mobs_mc_endermite_death",
		distance = 16,
	},
	movement_speed = 5.0,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 20, walk_speed = 55
	},
	damage = 2,
	reach = 1,
	head_eye_height = 0.13,
	climb_powder_snow = true,
}

endermite.ai_functions = {
	mob_class.ascend_in_powder_snow,
	mob_class.check_attack,
	mob_class.check_pace,
}

mcl_mobs.register_mob("mobs_mc:endermite", endermite)
mcl_mobs.register_egg("mobs_mc:endermite", S("Endermite"), "#161616", "#6d6d6d", 0)
