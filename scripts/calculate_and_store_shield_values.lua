-- �V�[���h�l���v�Z���O���[�o���ϐ��ɕۑ�����֐�
function calculate_and_store_shield_values()

	-- �ڑ����̃v���C���[�����擾
	local player_count = 1
	if game and #game.connected_players then
		player_count = #game.connected_players
	end

	-- �Q�[���J�n���̃}�b�v�����ݒ���擾
	local map_gen_settings = game.surfaces[1].map_gen_settings

	-- �Ⴆ�΁A�����̃��b�`�l�X��T�C�Y�A�����p�x���m�F
	local iron_rates = 0
	for name, resource in pairs(map_gen_settings.autoplace_controls) do
		if name == "iron-ore" then
			local richness = resource.richness
			local size = resource.size
			local frequency = resource.frequency
			-- �V�[���h�l���v�Z
			iron_rates = (richness + size + frequency - 3)
		end
	end

	-- �O���[�o���ϐ��ɕۑ�
	storage.total_shield_rate = 1
	
	-- ������������Δ{����
	if iron_rates > 0 then
		storage.total_shield_rate = 1 + iron_rates * 3 -- �C���ŉe����3�{��
	end
	
	if player_count > 1 then
		storage.total_shield_rate = storage.total_shield_rate * (1 + player_count * 1.5 / 10)
	end
	
	-- ��b�V�[���h�̒�`
	storage.additional_shield = 0
	
	-- ������������Ί�b�l�����Z��
	if iron_rates > 0 then
		storage.additional_shield = 30
	end

	-- �s�[�X�t�����[�h�̊m�F
	local peaceful_mode = map_gen_settings.peaceful_mode
	-- �s�[�X�t�����[�h�ł���΃V�[���h�l��啝�ɑ���
	if peaceful_mode then
		storage.additional_shield = 200000
	end
	
	-- �������I�t�̏ꍇ���V�[���h�l��啝�ɑ���
	if not game.map_settings.pollution.enabled then
		storage.additional_shield = 200000
	end
end
