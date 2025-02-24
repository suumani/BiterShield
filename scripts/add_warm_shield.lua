-- ���[���p�V�[���h
function add_warm_shield(entity)
	local play_time_hours = game.tick / (60 * 60 * 60)
	local shield_value = 10 + entity.max_health * 0.1
	if play_time_hours < 80 then
		shield_value = shield_value + math.floor(entity.max_health * 0.05 * play_time_hours)  -- 1���Ԃ��ƂɃV�[���h5%
	else
		shield_value = shield_value + math.floor(entity.max_health * 0.05 * 80)  -- 1���Ԃ��ƂɃV�[���h5% (80���ԕ�)
		if play_time_hours < 800 then
			shield_value = shield_value + math.floor(entity.max_health * 0.025 * play_time_hours)  -- 1���Ԃ��ƂɃV�[���h2.5%
		else
			shield_value = shield_value + math.floor(entity.max_health * 0.025 * 800)  -- 1���Ԃ��ƂɃV�[���h2.5% (800���ԕ�)
			shield_value = shield_value + math.floor(entity.max_health * 0.01 * play_time_hours)  -- 1���Ԃ��Ƃ�1%�̍ő�HP���V�[���h�Ƃ��Ēǉ�
		end
	end

	-- �����_���ŋ����{�[�i�X
	local r = math.random(100)
	-- ����(���Z��)
	local x = entity.position.x
	local y = entity.position.y
	if x < 0 then
		x = x * -1
	end
	if y < 0 then
		y = y * -1
	end	
	local distance = x + y
	if r < 4 then
		shield_value = shield_value + entity.max_health + distance * 0.3
	end
	-- �����_���ŃV�[���h3�{
	if r < 10 then
		shield_value = shield_value * 3
	end
	-- �Ƃ��ǂ������{�[�i�X���Z
	if r < 30 then
		shield_value = shield_value + distance * 0.3
	end
	-- �T�ˋ����{�[�i�X���Z
	if r < 60 then
		shield_value = shield_value + distance * 0.3
	end
	-- ���Ȃ炸�����{�[�i�X
	shield_value = shield_value + distance * 0.3
	
	-- �ߏ�Ȃ�V�[���h����
	if distance < 400 then
		shield_value = shield_value / 5
	elseif distance < 600 then
		shield_value = shield_value / 4
	elseif distance < 800 then
		shield_value = shield_value / 3
	elseif distance < 1000 then
		shield_value = shield_value / 2
	end
	
	-- �ݒ�ɂ��V�[���h�l�̑���
	shield_value = shield_value * storage.total_shield_rate + storage.additional_shield
	
	storage.biter_shields = storage.biter_shields or {}
	storage.biter_shields[entity.unit_number] = shield_value  -- ���j�b�g�ԍ����L�[�Ƃ��ăV�[���h�l��ۑ�
end
