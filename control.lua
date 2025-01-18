global.biter_shields = {}  -- �O���[�o���ȃe�[�u���Ŋe�o�C�^�[�̃V�[���h�ʂ�ǐ�

-- �V�[���h�l���v�Z���O���[�o���ϐ��ɕۑ�����֐�
require("scripts.calculate_and_store_shield_values")
-- �o�C�^�[�p�V�[���h
require("scripts.add_biter_shield")
-- ���[���p�V�[���h
require("scripts.add_warm_shield")
-- �o�C�^�[�̑��̃V�[���h
require("scripts.add_spawner_shield")
-- GUI�X�V
require("scripts.update_selected_biter_gui")

-- �Q�[���J�n���ɃV�[���h�l���v�Z
script.on_init(function()
	calculate_and_store_shield_values()
end)

-- �}���`�v���C�Q��
script.on_event(defines.events.on_player_joined_game, function(event)
    calculate_and_store_shield_values()
end)

-- �}���`�v���C���E
script.on_event(defines.events.on_player_left_game, function(event)
    calculate_and_store_shield_values()
end)

-- �����z�u���[���Ƒ��ɑΉ�
script.on_event(defines.events.on_chunk_generated, function(event)
	local area = event.area
	local surface = event.surface
	local worms = surface.find_entities_filtered{
		area = area
		, type = "turret"
		, name = {
			"small-worm-turret"
			, "medium-worm-turret"
			, "big-worm-turret"
			, "behemoth-worm-turret"
			-- cold
			, "small-cold-worm-turret"
			, "medium-cold-worm-turret"
			, "big-cold-worm-turret"
			, "behemoth-cold-worm-turret"
			, "leviathan-cold-worm-turret"
			, "mother-cold-worm-turret"
			-- explosive
			, "small-explosive-worm-turret"
			, "medium-explosive-worm-turret"
			, "big-explosive-worm-turret"
			, "behemoth-explosive-worm-turret"
			, "leviathan-explosive-worm-turret"
			, "mother-explosive-worm-turret"
			-- toxic
			, "small-toxic-worm-turret"
			, "medium-toxic-worm-turret"
			, "big-toxic-worm-turret"
			, "behemoth-toxic-worm-turret"
			, "leviathan-toxic-worm-turret"
			, "mother-toxic-worm-turret"
		}
	}
	for _, worm in pairs(worms) do
		add_warm_shield(worm)
	end
	local spawners = surface.find_entities_filtered{area = area, name = {"biter-spawner", "spitter-spawner"}}
	for _, spawner in pairs(spawners) do
		add_spawner_shield(spawner)
	end
end)

-- �G���������ꂽ�Ƃ��ɃV�[���h��ǉ�
script.on_event(defines.events.on_entity_spawned, function(event)
	local entity = event.entity
	-- �o�C�^�[
	if entity.type == "unit" and entity.force.name == "enemy" then
		add_biter_shield(entity)
	end
	-- ���[��
	if entity.type == "turret" and entity.force.name == "enemy" then
		add_warm_shield(entity)
	end
	-- ��
	if entity.name == "biter-spawner" then
		add_spawner_shield(entity)
	end
end)

-- �o�C�^�[���j�󂳂ꂽ�Ƃ��ɃV�[���h�l���폜
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if entity.type == "unit" and entity.force.name == "enemy" then
		global.biter_shields[entity.unit_number] = nil
	end
end)

-- �o�C�^�[���f�X�|�[�����ꂽ�Ƃ��ɃV�[���h�l���폜
script.on_event(defines.events.on_entity_destroyed, function(event)
	global.biter_shields[event.unit_number] = nil
end)


-- �_���[�W�n���h��
function handle_damage(event)
	-- �Ώ�entity
	local entity = event.entity
	
	-- �������C�̓��[���̃V�[���h�����
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and entity.type == "turret" and entity.force.name == "enemy" then
			local shield = global.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1����6������
				global.biter_shields[entity.unit_number] = 0.4 * shield
			
			end
		end
	end
	
	-- �������C�͑��̃V�[���h�����
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and (entity.name == "biter-spawner" or entity.name == "spitter-spawner") then
			local shield = global.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1����2������
				global.biter_shields[entity.unit_number] = 0.8 * shield
			
			end
		end
	end
	
	-- ���q���e�́A�o�C�^�[��ϐg������
--	if event and event.damage_type and event.damage_type.name == "nuclear" then
--		if entity and entity.type == "unit" and entity.force.name == "enemy" then
--		
--			-- surface�̎擾
--			local surface = entity.surface
--			-- ���̃o�C�^�[������
--			entity.destroy()
--
--			-- �V�����o�C�^�[�𐶐�
--			surface.create_entity{name = "my-new-biter", position = position, force = "enemy"}
--
--		end
--	
--	-- �ϐg���Ȃ��ꍇ�̓_���[�W
--	else
	
		-- �_���[�W����
		if entity and (((entity.type == "unit" or entity.type == "turret") and entity.force.name == "enemy") or entity.name == "biter-spawner" or entity.name == "spitter-spawner") then
			local shield = global.biter_shields[entity.unit_number] or 0
			if shield > 0 then
				local damage = event.final_damage_amount
				local new_shield_value = shield - damage
				if new_shield_value < 0 then
					entity.health = entity.health + new_shield_value  -- �}�C�i�X�l
					global.biter_shields[entity.unit_number] = 0
				else
					global.biter_shields[entity.unit_number] = new_shield_value
					entity.health = entity.health + damage  -- ����
				end
			end
		end
--	end
end

-- �_���[�W���󂯂��Ƃ��ɃV�[���h���l��
script.on_event(defines.events.on_entity_damaged, handle_damage)

-- �G���e�B�e�B�I���C�x���g
script.on_event(defines.events.on_selected_entity_changed, function(event)
	local player = game.players[event.player_index]
	local entity = player.selected
	-- GUI�X�V
	update_selected_biter_gui(player, entity)
end)