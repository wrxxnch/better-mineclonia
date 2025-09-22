local S = core.get_translator(core.get_current_modname())
local has_doc = core.get_modpath("doc")

mcl_flowerpots = {}
mcl_flowerpots.registered_pots = {}

local pot_box = {
	type = "fixed",
	fixed = {
		{ -0.1875, -0.5, -0.1875, 0.1875, -0.125, 0.1875 },
	},
}

core.register_node("mcl_flowerpots:flower_pot", {
	description = S("Flower Pot"),
	_tt_help = S("Can hold a small flower or plant"),
	_doc_items_longdesc = S("Flower pots are decorative blocks in which flowers and other small plants can be placed."),
	_doc_items_usagehelp = S("Just place a plant on the flower pot. Flower pots can hold small flowers (not higher than 1 block), saplings, ferns, dead bushes, mushrooms and cacti. Rightclick a potted plant to retrieve the plant."),
	drawtype = "mesh",
	mesh = "flowerpot.obj",
	tiles = {"mcl_flowerpots_flowerpot.png"},
	use_texture_alpha = "clip",
	wield_image = "mcl_flowerpots_flowerpot_inventory.png",
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = pot_box,
	collision_box = pot_box,
	is_ground_content = false,
	inventory_image = "mcl_flowerpots_flowerpot_inventory.png",
	groups = { dig_immediate = 3, deco_block = 1, attached_node = 1, dig_by_piston = 1, flower_pot = 1, unsticky = 1, pathfinder_partial = 2, },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rightclick = function(pos, _, clicker, itemstack)
		local name = clicker:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return itemstack
		end
		local item = clicker:get_wielded_item():get_name()
		if mcl_flowerpots.registered_pots[item] then
			core.swap_node(pos, { name = "mcl_flowerpots:flower_pot_" .. mcl_flowerpots.registered_pots[item] })
			if not core.is_creative_enabled(clicker:get_player_name()) then
				itemstack:take_item()
			end
		end

		return itemstack
	end,
})

core.register_craft({
	output = "mcl_flowerpots:flower_pot",
	recipe = {
		{ "mcl_core:brick", "", "mcl_core:brick" },
		{ "", "mcl_core:brick", "" },
		{ "", "", "" },
	},
})

function mcl_flowerpots.register_potted(name, def)
	mcl_flowerpots.registered_pots[name] = def.name

	core.register_node(":mcl_flowerpots:flower_pot_" .. def.name, {
		description = def.desc .. " " .. S("Flower Pot"),
		_doc_items_create_entry = false,
		drawtype = "mesh",
		mesh = def.mesh or "flowerpot.obj",
		visual_scale = def.visual_scale,
		tiles = def.tiles or {"[combine:32x32:0,0=mcl_flowerpots_flowerpot.png:0,0=" .. def.image},
		use_texture_alpha = "clip",
		paramtype = "light",
		sunlight_propagates = true,
		selection_box = pot_box,
		collision_box = pot_box,
		is_ground_content = false,
		groups = { dig_immediate = 3, attached_node = 1, dig_by_piston = 1, not_in_creative_inventory = 1, flower_pot = 2, unsticky = 1},
		sounds = mcl_sounds.node_sound_stone_defaults(),
		on_rightclick = function(pos, _, clicker)
			local player_name = clicker:get_player_name()
			if core.is_protected(pos, player_name) then
				core.record_protection_violation(pos, player_name)
				return
			end
			core.add_item(vector.offset(pos, 0, 0.5, 0), name)
			core.set_node(pos, { name = "mcl_flowerpots:flower_pot" })
		end,
		drop = {
			items = {
				{ items = { "mcl_flowerpots:flower_pot", name } },
			},
		},
	})
	-- Add entry alias for the Help
	if has_doc then
		doc.add_entry_alias("nodes", "mcl_flowerpots:flower_pot", "nodes", "mcl_flowerpots:flower_pot_" .. name)
	end
end

-- Deprecated functions

---Deprecated. Use mcl_flowerpots.register_potted instead. See API.md.
function mcl_flowerpots.register_potted_flower(name, def)
	mcl_flowerpots.register_potted(name, def)
end

---Deprecated. Use mcl_flowerpots.register_potted instead. See API.md.
function mcl_flowerpots.register_potted_cube(name, def)
	mcl_flowerpots.register_potted(name, table.merge(def, {
		mesh = "flowerpot_with_long_cube.obj",
		tiles = {def.image},
		visual_scale = 0.5
	}))
end
