global.biter_shields = {}  -- グローバルなテーブルで各バイターのシールド量を追跡

-- シールド値を計算しグローバル変数に保存する関数
require("scripts.calculate_and_store_shield_values")
-- バイター用シールド
require("scripts.add_biter_shield")
-- ワーム用シールド
require("scripts.add_warm_shield")
-- バイターの巣のシールド
require("scripts.add_spawner_shield")
-- GUI更新
require("scripts.update_selected_biter_gui")

-- ゲーム開始時にシールド値を計算
script.on_init(function()
	calculate_and_store_shield_values()
end)

-- マルチプレイ参加
script.on_event(defines.events.on_player_joined_game, function(event)
    calculate_and_store_shield_values()
end)

-- マルチプレイ離脱
script.on_event(defines.events.on_player_left_game, function(event)
    calculate_and_store_shield_values()
end)

-- 初期配置ワームと巣に対応
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

-- 敵が生成されたときにシールドを追加
script.on_event(defines.events.on_entity_spawned, function(event)
	local entity = event.entity
	-- バイター
	if entity.type == "unit" and entity.force.name == "enemy" then
		add_biter_shield(entity)
	end
	-- ワーム
	if entity.type == "turret" and entity.force.name == "enemy" then
		add_warm_shield(entity)
	end
	-- 巣
	if entity.name == "biter-spawner" then
		add_spawner_shield(entity)
	end
end)

-- バイターが破壊されたときにシールド値を削除
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if entity.type == "unit" and entity.force.name == "enemy" then
		global.biter_shields[entity.unit_number] = nil
	end
end)

-- バイターがデスポーンされたときにシールド値を削除
script.on_event(defines.events.on_entity_destroyed, function(event)
	global.biter_shields[event.unit_number] = nil
end)


-- ダメージハンドラ
function handle_damage(event)
	-- 対象entity
	local entity = event.entity
	
	-- 長距離砲はワームのシールドを削る
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and entity.type == "turret" and entity.force.name == "enemy" then
			local shield = global.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1撃で6割削れる
				global.biter_shields[entity.unit_number] = 0.4 * shield
			
			end
		end
	end
	
	-- 長距離砲は巣のシールドを削る
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and (entity.name == "biter-spawner" or entity.name == "spitter-spawner") then
			local shield = global.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1撃で2割削れる
				global.biter_shields[entity.unit_number] = 0.8 * shield
			
			end
		end
	end
	
	-- 原子爆弾は、バイターを変身させる
--	if event and event.damage_type and event.damage_type.name == "nuclear" then
--		if entity and entity.type == "unit" and entity.force.name == "enemy" then
--		
--			-- surfaceの取得
--			local surface = entity.surface
--			-- 元のバイターを消去
--			entity.destroy()
--
--			-- 新しいバイターを生成
--			surface.create_entity{name = "my-new-biter", position = position, force = "enemy"}
--
--		end
--	
--	-- 変身しない場合はダメージ
--	else
	
		-- ダメージ処理
		if entity and (((entity.type == "unit" or entity.type == "turret") and entity.force.name == "enemy") or entity.name == "biter-spawner" or entity.name == "spitter-spawner") then
			local shield = global.biter_shields[entity.unit_number] or 0
			if shield > 0 then
				local damage = event.final_damage_amount
				local new_shield_value = shield - damage
				if new_shield_value < 0 then
					entity.health = entity.health + new_shield_value  -- マイナス値
					global.biter_shields[entity.unit_number] = 0
				else
					global.biter_shields[entity.unit_number] = new_shield_value
					entity.health = entity.health + damage  -- 減少
				end
			end
		end
--	end
end

-- ダメージを受けたときにシールドを考慮
script.on_event(defines.events.on_entity_damaged, handle_damage)

-- エンティティ選択イベント
script.on_event(defines.events.on_selected_entity_changed, function(event)
	local player = game.players[event.player_index]
	local entity = player.selected
	-- GUI更新
	update_selected_biter_gui(player, entity)
end)