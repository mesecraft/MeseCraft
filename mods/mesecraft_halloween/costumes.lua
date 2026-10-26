-- Costumes
costumes = {}

-- Function for registering suits
function costumes.register(costume, nodename, def)
	if not def then
		def = {}
	end

	local gen_prev = "((([combine:16x32:-16,-12=halloween_suit_" .. nodename .. ".png^[mask:mask_chest.png)^([combine:16x32:-36,-8=halloween_suit_" .. nodename .. ".png^[mask:mask_head.png)^([combine:16x32:-44,-12=halloween_suit_" .. nodename .. ".png^[mask:mask_arm.png^[transformFX)^([combine:16x32:-44,-12=halloween_suit_" .. nodename .. ".png^[mask:mask_arm.png)^([combine:16x32:4,0=halloween_suit_" .. nodename .. ".png^[mask:mask_leg.png^[transformFX)^([combine:16x32:4,0=halloween_suit_" .. nodename .. ".png^[mask:mask_leg.png))^[resize:32x64)^[mask:mask_preview.png"

	local grouptypes = {
		["suit"] = {armor_head=1, armor_torso=1, armor_legs=1, armor_feet=1, armor_use=1000},
		["mask"] = {armor_head=1, armor_use=1000},
		["shirt"] = {armor_torso=1, armor_use=1000},
	}

	local function is_type(key)
		return grouptypes[key] ~= nil
	end

	local grouptype = "suit"

	if def.type then
		if is_type(def.type) then
			grouptype = def.type
		end
	end

	local armor_groups = grouptypes[grouptype]
	local node_str = grouptype.."_"..nodename

	if def.name then
		node_str = def.name
	end

	armor:register_armor("mesecraft_halloween:"..node_str, {
		description = costume,
		inventory_image = "inv_"..grouptype.."_"..nodename..".png",
		groups = armor_groups,
		on_equip = def.on_equip or nil,
		on_unequip = def.on_unequip or nil,
		on_destroy = def.on_destroy or nil,
		on_damage = def.on_damage or nil,
		on_punched = def.on_punched or nil,
	})

	local override_prev = gen_prev

	if def.preview then
		override_prev = def.preview
	end

	minetest.override_item("mesecraft_halloween:"..node_str, {
		preview = override_prev
	})
end

-- Register Costumes
costumes.register("Dark Unicorn", "dark_unicorn")
costumes.register("Dinosaur", "dino")
costumes.register("Frankenstein", "frank")
costumes.register("Ghost", "ghost")
costumes.register("Grim Reaper", "reaper")
costumes.register("Boy Wizard", "wizard")
costumes.register("Killer", "killer")
costumes.register("Glow-in-the-dark Skeleton", "skeleton", {
	on_equip = function(player)
		player:set_properties({glow=5})
	end,
	on_unequip = function(player)
		player:set_properties({glow=0})
	end
})
costumes.register("Pink Dinosaur", "dino_pink")
costumes.register("Pumpkin Monster", "pumpkin")
costumes.register("Forest Spirit", "forest_spirit")
costumes.register("Unicorn", "unicorn")
costumes.register("Vampire", "vampire")
costumes.register("Wearwolf", "wearwolf")
costumes.register("Pumpkin Mask", "pumpkin", {
	type = "mask",
	preview = "((([combine:16x32:-16,-12=halloween_mask_pumpkin.png^[mask:mask_chest.png)^([combine:16x32:-36,-8=halloween_mask_pumpkin.png^[mask:mask_head.png)^([combine:16x32:-44,-12=halloween_mask_pumpkin.png^[mask:mask_arm.png^[transformFX)^([combine:16x32:-44,-12=halloween_mask_pumpkin.png^[mask:mask_arm.png)^([combine:16x32:4,0=halloween_mask_pumpkin.png^[mask:mask_leg.png^[transformFX)^([combine:16x32:4,0=halloween_mask_pumpkin.png^[mask:mask_leg.png))^[resize:32x64)^[mask:mask_preview.png"
})
costumes.register("Halloween Hoodie", "halloween_hoodie", {
	type = "shirt",
	preview = "((([combine:16x32:-28,-12=halloween_shirt_halloween_hoodie.png^[mask:mask_chest.png)^([combine:16x32:-36,-8=halloween_shirt_halloween_hoodie.png^[mask:mask_head.png)^([combine:16x32:-52,-12=halloween_shirt_halloween_hoodie.png^[mask:mask_arm.png^[transformFX)^([combine:16x32:-52,-12=halloween_shirt_halloween_hoodie.png^[mask:mask_arm.png)^([combine:16x32:4,0=halloween_shirt_halloween_hoodie.png^[mask:mask_leg.png^[transformFX)^([combine:16x32:4,0=halloween_shirt_halloween_hoodie.png^[mask:mask_leg.png))^[resize:32x64)^[mask:mask_preview.png"
})
costumes.register("Cat Mask", "cat", {
	type = "mask",
	preview = "((([combine:16x32:-16,-12=halloween_mask_cat.png^[mask:mask_chest.png)^([combine:16x32:-36,-8=halloween_mask_cat.png^[mask:mask_head.png)^([combine:16x32:-44,-12=halloween_mask_cat.png^[mask:mask_arm.png^[transformFX)^([combine:16x32:-44,-12=halloween_mask_cat.png^[mask:mask_arm.png)^([combine:16x32:4,0=halloween_mask_cat.png^[mask:mask_leg.png^[transformFX)^([combine:16x32:4,0=halloween_mask_cat.png^[mask:mask_leg.png))^[resize:32x64)^[mask:mask_preview.png"
})

minetest.register_alias("mesecraft_halloween:helmet_pumpkin_mask", "mesecraft_halloween:mask_pumpkin")
minetest.register_alias("mesecraft_halloween:chestplate_halloween_hoodie", "mesecraft_halloween:shirt_halloween_hoodie")
