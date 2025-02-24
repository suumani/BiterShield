-- ワーム用シールド
function add_warm_shield(entity)
	local play_time_hours = game.tick / (60 * 60 * 60)
	local shield_value = 10 + entity.max_health * 0.1
	if play_time_hours < 80 then
		shield_value = shield_value + math.floor(entity.max_health * 0.05 * play_time_hours)  -- 1時間ごとにシールド5%
	else
		shield_value = shield_value + math.floor(entity.max_health * 0.05 * 80)  -- 1時間ごとにシールド5% (80時間分)
		if play_time_hours < 800 then
			shield_value = shield_value + math.floor(entity.max_health * 0.025 * play_time_hours)  -- 1時間ごとにシールド2.5%
		else
			shield_value = shield_value + math.floor(entity.max_health * 0.025 * 800)  -- 1時間ごとにシールド2.5% (800時間分)
			shield_value = shield_value + math.floor(entity.max_health * 0.01 * play_time_hours)  -- 1時間ごとに1%の最大HPをシールドとして追加
		end
	end

	-- ランダムで距離ボーナス
	local r = math.random(100)
	-- 距離(加算で)
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
	-- ランダムでシールド3倍
	if r < 10 then
		shield_value = shield_value * 3
	end
	-- ときどき距離ボーナス加算
	if r < 30 then
		shield_value = shield_value + distance * 0.3
	end
	-- 概ね距離ボーナス加算
	if r < 60 then
		shield_value = shield_value + distance * 0.3
	end
	-- かならず距離ボーナス
	shield_value = shield_value + distance * 0.3
	
	-- 近場ならシールド減少
	if distance < 400 then
		shield_value = shield_value / 5
	elseif distance < 600 then
		shield_value = shield_value / 4
	elseif distance < 800 then
		shield_value = shield_value / 3
	elseif distance < 1000 then
		shield_value = shield_value / 2
	end
	
	-- 設定によるシールド値の増加
	shield_value = shield_value * storage.total_shield_rate + storage.additional_shield
	
	storage.biter_shields = storage.biter_shields or {}
	storage.biter_shields[entity.unit_number] = shield_value  -- ユニット番号をキーとしてシールド値を保存
end
