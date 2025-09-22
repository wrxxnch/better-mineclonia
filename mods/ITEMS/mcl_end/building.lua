-- Building blocks and decorative nodes
local S = core.get_translator(core.get_current_modname())

local mod_screwdriver = core.get_modpath("screwdriver")

local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

core.register_node("mcl_end:end_stone", {
	description = S("End Stone"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_end_stone.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_dig_node = mcl_end.check_detach_chorus_plant,
	_mcl_blast_resistance = 9,
	_mcl_hardness = 3,
	_mcl_crafting_output = {square2 = {output = "mcl_end:end_bricks 4"}}
})

core.register_node("mcl_end:end_bricks", {
	description = S("End Stone Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_end_bricks.png"},
	is_ground_content = false,
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 9,
	_mcl_hardness = 3,
	_mcl_stonecutter_recipes = {"mcl_end:end_stone"},
})

core.register_node("mcl_end:purpur_block", {
	description = S("Purpur Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_purpur_block.png"},
	is_ground_content = false,
	groups = {pickaxey=1, building_block=1, material_stone=1, purpur_block=1, stonecuttable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

core.register_node("mcl_end:purpur_pillar", {
	description = S("Purpur Pillar"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	tiles = {"mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, purpur_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	_mcl_stonecutter_recipes = {"mcl_end:purpur_block"}
})

core.register_node("mcl_end:end_rod", {
	description = S("End Rod"),
	_doc_items_longdesc = S("End rods are decorative light sources."),
	tiles = {
		"mcl_end_end_rod_top.png",
		"mcl_end_end_rod_bottom.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 14,
	sunlight_propagates = true,
	groups = { dig_immediate=3, deco_block=1, destroy_by_lava_flow=1, },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, -0.4375, 0.125}, -- Base
			{-0.0625, -0.4375, -0.0625, 0.0625, 0.5, 0.0625}, -- Rod
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:get_pos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = core.dir_to_facedir(dir)
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return core.item_place(itemstack, placer, pointed_thing, param2)
	end,

	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_hardness = 0,
})

core.register_node("mcl_end:dragon_egg", {
	description = S("Dragon Egg"),
	_doc_items_longdesc = S("A dragon egg is a decorative item which can be placed."),
	tiles = {
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	light_source = 1,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{-0.5, -0.4375, -0.5, 0.5, -0.1875, 0.5},
			{-0.4375, -0.1875, -0.4375, 0.4375, 0, 0.4375},
			{-0.375, 0, -0.375, 0.375, 0.125, 0.375},
			{-0.3125, 0.125, -0.3125, 0.3125, 0.25, 0.3125},
			{-0.25, 0.25, -0.25, 0.25, 0.3125, 0.25},
			{-0.1875, 0.3125, -0.1875, 0.1875, 0.375, 0.1875},
			{-0.125, 0.375, -0.125, 0.125, 0.4375, 0.125},
			{-0.0625, 0.4375, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	selection_box = {
		type = "regular",
	},
	groups = {handy = 1, falling_node = 1, deco_block = 1, dig_by_piston = 1, unsticky =1, rarity = 3},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 9,
	_mcl_hardness = 3,
	on_punch = function(pos, node, puncher)
		if not core.is_protected(pos, puncher:get_player_name()) then
			local max_dist = vector.new(15, 7, 15)
			local positions = core.find_nodes_in_area(vector.subtract(pos, max_dist), vector.add(pos, max_dist), "air", false)
			if #positions > 0 then
				local tpos = positions[math.random(#positions)]
				core.remove_node(pos)
				core.set_node(tpos, node)
				core.check_for_falling(tpos)
			end
		end
	end,
})

mcl_stairs.register_stair_and_slab("end_bricks", {
	baseitem = "mcl_end:end_bricks",
	description_stair = S("End Stone Brick Stairs"),
	description_slab = S("End Stone Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_end:end_bricks","mcl_end:end_stone"}},{_mcl_stonecutter_recipes = {"mcl_end:end_bricks","mcl_end:end_stone"}}
})

mcl_stairs.register_stair_and_slab("purpur_block", {
	baseitem = "mcl_end:purpur_block",
	description_stair = S("Purpur Stairs"),
	description_slab = S("Purpur Slab"),
	recipeitem = "group:purpur_block",
	overrides = {_mcl_stonecutter_recipes = {"mcl_end:purpur_block"}}
})

-- Crafting recipes
core.register_craft({
	output = "mcl_end:end_rod 4",
	recipe = {
		{"mcl_mobitems:blaze_rod"},
		{"mcl_end:chorus_fruit_popped"},
	},
})

