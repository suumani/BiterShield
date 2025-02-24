-- バイター用シールド
function add_biter_shield(entity)
	local play_time_hours = game.tick / (60 * 60 * 60)
	local shield_value = 10 + entity.max_health * 0.1  -- 初期からシールド10
	
	-- 80時間以下
	if play_time_hours < 80 then
		shield_value = shield_value + math.floor(entity.max_health * 0.025 * play_time_hours)  -- 1時間ごとにシールド2.5%
	else
	-- 80時間超え
		shield_value = shield_value + math.floor(entity.max_health * 0.025 * 80)  -- 1時間ごとにシールド2.5% (80時間分)
		
		-- 800時間以下
		if play_time_hours < 800 then
			shield_value = shield_value + math.floor(entity.max_health * 0.01 * play_time_hours)  -- 1時間ごとにシールド1%を加算
		else
		-- 800時間超え
			shield_value = shield_value + math.floor(entity.max_health * 0.01 * 800)  -- 1時間ごとに1%の最大HPをシールドとして追加
			shield_value = shield_value + math.floor(entity.max_health * 0.005 * play_time_hours)  -- 1時間ごとに0.5%の最大HPをシールドとして追加
		end
	end
	
	-- ランダムでシールド3倍
	local r = math.random(100)
	if r < 2 then
		shield_value = shield_value * 3 + entity.max_health * 3
	end
	
	-- 設定によるシールド値の増加
	shield_value = shield_value * storage.total_shield_rate + storage.additional_shield
	
	storage.biter_shields = storage.biter_shields or {}
	storage.biter_shields[entity.unit_number] = shield_value  -- ユニット番号をキーとしてシールド値を保存
end
