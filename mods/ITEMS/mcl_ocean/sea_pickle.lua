local S = core.get_translator(core.get_current_modname())

local mod_doc = core.get_modpath("doc")

local function sea_pickle_on_place(itemstack, placer, pointed_thing, level)
	if level == nil then level=1 end
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = core.get_node(pos_under)
	local node_above = core.get_node(pos_above)

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	if core.is_protected(pos_under, player_name) or
			core.is_protected(pos_above, player_name) then
		core.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. core.pos_to_string(pos_under))
		core.record_protection_violation(pos_under, player_name)
		return itemstack
	end

	local submerged = false
	if core.get_item_group(node_above.name, "water") ~= 0 then
		submerged = true
	end
	-- Place
	if node_under.name == "mcl_ocean:dead_brain_coral_block" then
		-- Place on suitable coral block
		if submerged then
			node_under.name = "mcl_ocean:sea_pickle_"..level.."_dead_brain_coral_block"
		else
			node_under.name = "mcl_ocean:sea_pickle_" .. level .. "_off_dead_brain_coral_block"
		end
		core.set_node(pos_under, node_under)
	elseif core.get_item_group(node_under.name, "sea_pickle") ~= 0 then
		-- Grow by 1 stage
		local def = core.registered_nodes[node_under.name]
		if def and def._mcl_sea_pickle_next then
			node_under.name = def._mcl_sea_pickle_next
			core.set_node(pos_under, node_under)
		else
			return itemstack
		end
	else
		return itemstack
	end
	if not core.is_creative_enabled(player_name) then
		itemstack:take_item()
	end
	return itemstack
end

-- Sea Pickle on brain coral

local sounds_coral_plant = mcl_sounds.node_sound_leaves_defaults({footstep = mcl_sounds.node_sound_dirt_defaults().footstep})
local ontop = "dead_brain_coral_block"
local canonical = "mcl_ocean:sea_pickle_1_"..ontop
local light_strength = { 6, 9, 12, core.LIGHT_MAX }

for s=1,4 do
	local desc, doc_desc, doc_use, doc_create, tt_help, nici, img, img_off, on_place, cookoutput
	if s == 1 then
		desc = S("Sea Pickle")
		doc_desc = S("Sea pickles grow on dead brain coral blocks and provide light when underwater. They come in 4 sizes that vary in brightness.")
		doc_use = S("It can only be placed on top of dead brain coral blocks. Placing a sea pickle on another sea pickle will make it grow and brighter.")
		tt_help = S("Glows in the water").."\n"..S("4 possible sizes").."\n"..S("Grows on dead brain coral block")
		img = "mcl_ocean_sea_pickle_item.png"
		cookoutput = "mcl_dyes:lime"
		on_place = sea_pickle_on_place
	else
		doc_create = false
		nici = 1
		img = "mcl_ocean_"..ontop..".png^(mcl_ocean_sea_pickle_"..s.."_anim.png^[verticalframe:2:1)"
		cookoutput = nil
	end
	img_off = "mcl_ocean_"..ontop..".png^mcl_ocean_sea_pickle_"..s.."_off.png"
	local next_on, next_off
	if s < 4 then
		next_on = "mcl_ocean:sea_pickle_" .. tostring(s + 1) .. "_" .. ontop
		next_off = "mcl_ocean:sea_pickle_" .. tostring(s + 1) .. "_off_" .. ontop
	end

	local function spread_sea_pickle(pos, placer)
		local possible_position = {
			{ x =  2, y =  0, z =  0 },
			{ x = -2, y =  0, z =  0 },
			{ x =  1, y =  0, z =  0 },
			{ x = -1, y =  0, z =  0 },
			{ x =  0, y =  0, z =  1 },
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  0, z =  2 },
			{ x =  0, y =  0, z = -2 },
			{ x =  1, y = -1, z =  0 },
			{ x = -1, y = -1, z =  0 },
			{ x =  0, y = -1, z =  1 },
			{ x =  0, y = -1, z = -1 },
			{ x =  1, y =  0, z =  1 },
			{ x =  1, y =  0, z = -1 },
			{ x = -1, y =  0, z =  1 },
			{ x = -1, y =  0, z = -1 },
		}

		for _, v in pairs(possible_position) do
			sea_pickle_on_place(
				ItemStack("mcl_ocean:sea_pickle"),
				placer,
				{type="node", under=vector.offset(pos,v.x,v.y,v.z), above=vector.offset(pos,v.x,v.y-1,v.z)},
				math.random(1, 3))
		end
	end

	local function on_bone_meal(_, placer, pointed_thing, pos, node)
		if pointed_thing.type ~= "node" then return end
		if 4 ~= s then
			node.name = "mcl_ocean:sea_pickle_" .. (s + 1) .. "_" .. ontop
			core.swap_node(pos, node)
		end
		spread_sea_pickle(pos, placer)
	end

	core.register_node("mcl_ocean:sea_pickle_"..s.."_"..ontop, {
		description = desc,
		_tt_help = tt_help,
		_doc_items_create_entry = doc_create,
		_doc_items_longdesc = doc_desc,
		_doc_items_usagehelp = doc_use,
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		tiles = { "mcl_ocean_"..ontop..".png" },
		special_tiles = {
			{
			name = "mcl_ocean_sea_pickle_"..s.."_anim.png",
			animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=1.7},
			}
		},
		inventory_image = img,
		wield_image = img,
		groups = {
			dig_immediate = 3, deco_block = 1, sea_pickle = 1,
			not_in_creative_inventory=nici, compostability = 65, dig_by_piston = 1, unsticky = 1
		},
		light_source = light_strength[s],
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.15, 0.5, -0.15, 0.15, 0.5+2/16+(2/16)*s, 0.15 },
			}
		},
		sounds = sounds_coral_plant,
		drop = canonical .. " "..s,
		node_placement_prediction = "",
		node_dig_prediction = "mcl_ocean:"..ontop,
		after_dig_node = function(pos)
			local node = core.get_node(pos)
			if core.get_item_group(node.name, "sea_pickle") == 0 then
				core.set_node(pos, {name="mcl_ocean:"..ontop})
			end
		end,
		on_place = on_place,
		_mcl_sea_pickle_off = "mcl_ocean:sea_pickle_"..s.."_off_"..ontop,
		_mcl_sea_pickle_next = next_on,
		_mcl_baseitem = "mcl_ocean:sea_pickle_1_dead_brain_coral_block",
		_mcl_hardness = 0,
		_mcl_cooking_output = cookoutput,
		_on_bone_meal = on_bone_meal,
	})

	core.register_node("mcl_ocean:sea_pickle_"..s.."_off_"..ontop, {
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "meshoptions",
		tiles = { "mcl_ocean_"..ontop..".png" },
		special_tiles = { "mcl_ocean_sea_pickle_"..s.."_off.png", },
		groups = { dig_immediate = 3, deco_block = 1, sea_pickle=2, not_in_creative_inventory=1 },
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.15, 0.5, -0.15, 0.15, 0.5+2/16+(2/16)*s, 0.15 },
			}
		},
		inventory_image = img_off,
		wield_image = img_off,
		sounds = sounds_coral_plant,
		drop = canonical .. " "..s,
		node_placement_prediction = "",
		node_dig_prediction = "mcl_ocean:"..ontop,
		after_dig_node = function(pos)
			local node = core.get_node(pos)
			if core.get_item_group(node.name, "sea_pickle") == 0 then
				core.set_node(pos, {name="mcl_ocean:"..ontop})
			end
		end,
		_mcl_sea_pickle_on = "mcl_ocean:sea_pickle_"..s.."_"..ontop,
		_mcl_sea_pickle_next = next_off,
		_mcl_baseitem = "mcl_ocean:sea_pickle_1_dead_brain_coral_block",
		_mcl_hardness = 0,
	})

	if mod_doc then
		if s == 1 then
			doc.add_entry_alias("nodes", "mcl_ocean:sea_pickle_1_dead_brain_coral_block", "nodes", "mcl_ocean:sea_pickle_1_off_"..ontop)
		else
			doc.add_entry_alias("nodes", "mcl_ocean:sea_pickle_1_dead_brain_coral_block", "nodes", "mcl_ocean:sea_pickle_"..s.."_off_"..ontop)
			doc.add_entry_alias("nodes", "mcl_ocean:sea_pickle_1_dead_brain_coral_block", "nodes", "mcl_ocean:sea_pickle_"..s.."_"..ontop)
		end
	end
end

core.register_abm({
	label = "Sea pickle update",
	nodenames = { "group:sea_pickle" },
	interval = 17,
	chance = 5,
	catch_up = false,
	action = function(pos, node)
		-- Check if it's lit
		local state = core.get_item_group(node.name, "sea_pickle")
		-- Check for water
		local checknode = core.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		local def = core.registered_nodes[node.name]
		if core.get_item_group(checknode.name, "water") ~= 0 then
			-- Sea pickle is unlit
			if state == 2 then
				node.name = def._mcl_sea_pickle_on
				core.set_node(pos, node)
				return
			end
		else
			-- Sea pickle is lit
			if state == 1 then
				node.name = def._mcl_sea_pickle_off
				core.set_node(pos, node)
				return
			end
		end
	end,
})
