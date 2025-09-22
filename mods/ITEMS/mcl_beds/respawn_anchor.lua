--TODO: Add sounds for the respawn anchor (charge sounds etc.)

--Nether ends at y -29077
--Nether roof at y -28933
local S = core.get_translator(core.get_current_modname())
--local mod_doc = core.get_modpath("doc") -> maybe add documentation ?

local light_level = { [0] = 0, 3, 7, 11, core.LIGHT_MAX }

for i=0,4 do

	local function rightclick(pos, node, player, itemstack)
		if itemstack.get_name(itemstack) == "mcl_nether:glowstone" and i ~= 4 then
			mcl_redstone.swap_node(pos, {name="mcl_beds:respawn_anchor_charged_" .. i+1})
			itemstack:take_item()
		elseif mcl_worlds.pos_to_dimension(pos) ~= "nether" then
			if node.name ~= "mcl_beds:respawn_anchor" then --only charged respawn anchors are exploding in the overworld & end in minecraft
				minetest.remove_node(pos)
				mcl_explosions.explode(pos, 5, {fire = true})
			end
		elseif string.match(node.name, "mcl_beds:respawn_anchor_charged_") then
			core.chat_send_player(player.get_player_name(player), S("New respawn position set!"))
			mcl_spawn.set_spawn_pos(player, pos, nil)
			if i == 4 then
				awards.unlock(player:get_player_name(), "mcl:notQuiteNineLives")
			end
		end

		return mcl_util.return_itemstack_if_alive(player, itemstack)
		-- returning the old itemstack here would result in it still being in hand *after* death
	end


	if i == 0 then
		core.register_node("mcl_beds:respawn_anchor",{
			description=S("Respawn Anchor"),
			tiles = {
				"respawn_anchor_top_off.png",
				"respawn_anchor_bottom.png",
				"respawn_anchor_side0.png"
			},
			is_ground_content = false,
			on_rightclick = rightclick,
			groups = {pickaxey=1, material_stone=1, deco_block=1, respawn_anchor=1, comparator_signal = 0},
			_mcl_hardness = 50,
			_mcl_blast_resistance = 1200,
			sounds= mcl_sounds.node_sound_stone_defaults(),
			use_texture_alpha = "blend",
			_mcl_baseitem = "mcl_beds:respawn_anchor",
		})
	else
		core.register_node("mcl_beds:respawn_anchor_charged_"..i,{
			description=S("Respawn Anchor"),
			tiles = {
			{
				name = "respawn_anchor_top_on.png",
				animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
			},
				"respawn_anchor_bottom.png",
				"respawn_anchor_side"..i ..".png"
			},
			on_rightclick = rightclick,
			groups = {pickaxey=1, material_stone=1, not_in_creative_inventory=1, respawn_anchor=1, comparator_signal = 4*i-1},
			_mcl_hardness = 50,
			_mcl_blast_resistance = 1200,
			sounds= mcl_sounds.node_sound_stone_defaults(),
			_mcl_baseitem = "mcl_beds:respawn_anchor",
			drop = {
				max_items = 1,
				items = {
					{items = {"mcl_beds:respawn_anchor"}},
				}
			},
			light_source = light_level[i],
		})
	end
 end


core.register_craft({
	output = "mcl_beds:respawn_anchor",
	recipe = {
			{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"},
			{"mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone"},
			{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"}
		}
	})
