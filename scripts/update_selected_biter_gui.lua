-- GUI更新
function update_selected_biter_gui(player, entity)
	local frame = player.gui.left["biter_shield_frame"]
	if frame then
		frame.destroy() -- 既存のGUIがあれば削除
	end
	
	if entity and (((entity.type == "unit" or entity.type == "turret") and entity.force.name == "enemy") or entity.name == "biter-spawner" or entity.name == "spitter-spawner") then
		local shield = global.biter_shields[entity.unit_number] or 0
		-- 新しいGUIフレームを作成
		frame = player.gui.left.add{type = "frame", name = "biter_shield_frame", caption = "Biter Info"}
		frame.add{type = "label", caption = "HP: " .. math.floor(entity.health)}
		frame.add{type = "label", caption = "Shield: " .. math.floor(shield)}
	end
end
