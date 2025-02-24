-- シールド値を計算しグローバル変数に保存する関数
function calculate_and_store_shield_values()

	-- 接続中のプレイヤー数を取得
	local player_count = 1
	if game and #game.connected_players then
		player_count = #game.connected_players
	end

	-- ゲーム開始時のマップ生成設定を取得
	local map_gen_settings = game.surfaces[1].map_gen_settings

	-- 例えば、資源のリッチネスやサイズ、生成頻度を確認
	local iron_rates = 0
	for name, resource in pairs(map_gen_settings.autoplace_controls) do
		if name == "iron-ore" then
			local richness = resource.richness
			local size = resource.size
			local frequency = resource.frequency
			-- シールド値を計算
			iron_rates = (richness + size + frequency - 3)
		end
	end

	-- グローバル変数に保存
	storage.total_shield_rate = 1
	
	-- 資源増加あれば倍率で
	if iron_rates > 0 then
		storage.total_shield_rate = 1 + iron_rates * 3 -- 気分で影響は3倍に
	end
	
	if player_count > 1 then
		storage.total_shield_rate = storage.total_shield_rate * (1 + player_count * 1.5 / 10)
	end
	
	-- 基礎シールドの定義
	storage.additional_shield = 0
	
	-- 資源増加あれば基礎値も加算で
	if iron_rates > 0 then
		storage.additional_shield = 30
	end

	-- ピースフルモードの確認
	local peaceful_mode = map_gen_settings.peaceful_mode
	-- ピースフルモードであればシールド値を大幅に増加
	if peaceful_mode then
		storage.additional_shield = 200000
	end
	
	-- 汚染がオフの場合もシールド値を大幅に増加
	if not game.map_settings.pollution.enabled then
		storage.additional_shield = 200000
	end
end
