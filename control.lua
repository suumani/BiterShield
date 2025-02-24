
-- ----------------------------
-- �J�n
-- ----------------------------
script.on_init(function()
	storage.biter_shields = storage.biter_shields or {}
	storage.shield_check = "false"
end)

-- ----------------------------
-- ���[�h
-- ----------------------------
script.on_load(function()
end)

local function find_all_enemies(surface)
	return surface.find_entities_filtered{area = area, force = "enemy", type = {"unit", "turret", "unit-spawner"}}
end

local function add_shields_all_nauvis_enemies(all_nauvis_enemies)
	for key, entity in pairs(all_nauvis_enemies) do
		-- �o�C�^�[
		if entity.type == "unit" and entity.force.name == "enemy" then
			add_biter_shield(entity)
		end
		-- ���[��
		if entity.type == "turret" and entity.force.name == "enemy" then
			add_warm_shield(entity)
		end
		-- ��
		if entity.type == "unit-spawner" and entity.force.name == "enemy" then
			add_spawner_shield(entity)
		end
	end
end

-- ----------------------------
-- �^�C�}�[�C�x���g
-- ----------------------------
script.on_event(defines.events.on_tick, function(event)

	-- �V�[���h����
	if storage.shield_check == nil or storage.shield_check == "false" then
		local nauvis_surface = game.surfaces["nauvis"]
		if nauvis_surface ~= nil then
			-- �S�Ẵo�C�^�[�E�X�s�b�^�[�E���[���E��������
			local all_nauvis_enemies = find_all_enemies(nauvis_surface)
			
			-- �S�ẴV�[���h�z�񂩂�A�����ł�����Ȃ��G���폜
			-- delete_shield_unfound_enemies(all_nauvis_enemies)
			
			-- ���ׂĂ̓G�̂����A�V�[���h��ێ����Ă��Ȃ��G�ɃV�[���h�t�^
			add_shields_all_nauvis_enemies(all_nauvis_enemies)
		end
		storage.shield_check = "true"
	end
end)

-- ----------------------------
-- �S�Ẵo�C�^�[�E�X�s�b�^�[�E���[���E��������
-- ----------------------------

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
	
	local worms = surface.find_entities_filtered{area = area, type = "turret"}
	for _, worm in pairs(worms) do
		add_warm_shield(worm)
	end
	local spawners = surface.find_entities_filtered{area = area, type = "unit-spawner"}
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
	if entity.type == "unit-spawner" and entity.force.name == "enemy" then
		add_spawner_shield(entity)
	end
end)

-- �o�C�^�[���j�󂳂ꂽ�Ƃ��ɃV�[���h�l���폜
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if entity.type == "unit" and entity.force.name == "enemy" then
		storage.biter_shields[entity.unit_number] = nil
	end
end)

-- �o�C�^�[���f�X�|�[�����ꂽ�Ƃ��ɃV�[���h�l���폜
script.on_event(defines.events.on_entity_died, function(event)
	if event.entity and event.entity.unit_number then
		storage.biter_shields = storage.biter_shields or {}
		storage.biter_shields[event.entity.unit_number] = nil
	end
end)


-- ----------------------------
-- �_���[�W�n���h��
-- ----------------------------
function handle_damage(event)
	-- �Ώ�entity
	local entity = event.entity
	
	-- �������C�̓��[���̃V�[���h�����
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and entity.type == "turret" and entity.force.name == "enemy" then
			local shield = storage.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1����6������
				storage.biter_shields[entity.unit_number] = 0.4 * shield
			
			end
		end
	end
	
	-- �������C�͑��̃V�[���h�����
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and entity.type == "unit-spawner" then
			local shield = storage.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1����2������
				storage.biter_shields[entity.unit_number] = 0.8 * shield
			
			end
		end
	end
	
	-- �_���[�W����
	if entity and ((entity.type == "unit" or entity.type == "turret" or entity.type == "unit-spawner") and entity.force.name == "enemy") then
		local shield = storage.biter_shields[entity.unit_number] or 0
		if shield > 0 then
			local damage = event.final_damage_amount
			local new_shield_value = shield - damage
			if new_shield_value < 0 then
				entity.health = entity.health + new_shield_value  -- �}�C�i�X�l
				storage.biter_shields[entity.unit_number] = 0
			else
				storage.biter_shields[entity.unit_number] = new_shield_value
				entity.health = entity.health + damage  -- ����
			end
		end
	end
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