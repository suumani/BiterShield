-- �o�C�^�[�p�V�[���h
function add_biter_shield(entity)
	local play_time_hours = game.tick / (60 * 60 * 60)
	local shield_value = 10 + entity.max_health * 0.1  -- ��������V�[���h10
	
	-- 80���Ԉȉ�
	if play_time_hours < 80 then
		shield_value = shield_value + math.floor(entity.max_health * 0.025 * play_time_hours)  -- 1���Ԃ��ƂɃV�[���h2.5%
	else
	-- 80���Ԓ���
		shield_value = shield_value + math.floor(entity.max_health * 0.025 * 80)  -- 1���Ԃ��ƂɃV�[���h2.5% (80���ԕ�)
		
		-- 800���Ԉȉ�
		if play_time_hours < 800 then
			shield_value = shield_value + math.floor(entity.max_health * 0.01 * play_time_hours)  -- 1���Ԃ��ƂɃV�[���h1%�����Z
		else
		-- 800���Ԓ���
			shield_value = shield_value + math.floor(entity.max_health * 0.01 * 800)  -- 1���Ԃ��Ƃ�1%�̍ő�HP���V�[���h�Ƃ��Ēǉ�
			shield_value = shield_value + math.floor(entity.max_health * 0.005 * play_time_hours)  -- 1���Ԃ��Ƃ�0.5%�̍ő�HP���V�[���h�Ƃ��Ēǉ�
		end
	end
	
	-- �����_���ŃV�[���h3�{
	local r = math.random(100)
	if r < 2 then
		shield_value = shield_value * 3 + entity.max_health * 3
	end
	
	-- �ݒ�ɂ��V�[���h�l�̑���
	shield_value = shield_value * storage.total_shield_rate + storage.additional_shield
	
	storage.biter_shields = storage.biter_shields or {}
	storage.biter_shields[entity.unit_number] = shield_value  -- ���j�b�g�ԍ����L�[�Ƃ��ăV�[���h�l��ۑ�
end
