
-- ----------------------------
-- 開始
-- ----------------------------
script.on_init(function()
	storage.biter_shields = storage.biter_shields or {}
	storage.shield_check = "false"
end)

-- ----------------------------
-- ロード
-- ----------------------------
script.on_load(function()
end)

local function find_all_enemies(surface)
	return surface.find_entities_filtered{area = area, force = "enemy", type = {"unit", "turret", "unit-spawner"}}
end

local function add_shields_all_nauvis_enemies(all_nauvis_enemies)
	for key, entity in pairs(all_nauvis_enemies) do
		-- バイター
		if entity.type == "unit" and entity.force.name == "enemy" then
			add_biter_shield(entity)
		end
		-- ワーム
		if entity.type == "turret" and entity.force.name == "enemy" then
			add_warm_shield(entity)
		end
		-- 巣
		if entity.type == "unit-spawner" and entity.force.name == "enemy" then
			add_spawner_shield(entity)
		end
	end
end

-- ----------------------------
-- タイマーイベント
-- ----------------------------
script.on_event(defines.events.on_tick, function(event)

	-- シールド整理
	if storage.shield_check == nil or storage.shield_check == "false" then
		local nauvis_surface = game.surfaces["nauvis"]
		if nauvis_surface ~= nil then
			-- 全てのバイター・スピッター・ワーム・巣を検索
			local all_nauvis_enemies = find_all_enemies(nauvis_surface)
			
			-- 全てのシールド配列から、検索でかからない敵を削除
			-- delete_shield_unfound_enemies(all_nauvis_enemies)
			
			-- すべての敵のうち、シールドを保持していない敵にシールド付与
			add_shields_all_nauvis_enemies(all_nauvis_enemies)
		end
		storage.shield_check = "true"
	end
end)

-- ----------------------------
-- 全てのバイター・スピッター・ワーム・巣を検索
-- ----------------------------

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
	
	local worms = surface.find_entities_filtered{area = area, type = "turret"}
	for _, worm in pairs(worms) do
		add_warm_shield(worm)
	end
	local spawners = surface.find_entities_filtered{area = area, type = "unit-spawner"}
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
	if entity.type == "unit-spawner" and entity.force.name == "enemy" then
		add_spawner_shield(entity)
	end
end)

-- バイターが破壊されたときにシールド値を削除
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if entity.type == "unit" and entity.force.name == "enemy" then
		storage.biter_shields[entity.unit_number] = nil
	end
end)

-- バイターがデスポーンされたときにシールド値を削除
script.on_event(defines.events.on_entity_died, function(event)
	if event.entity and event.entity.unit_number then
		storage.biter_shields = storage.biter_shields or {}
		storage.biter_shields[event.entity.unit_number] = nil
	end
end)


-- ----------------------------
-- ダメージハンドラ
-- ----------------------------
function handle_damage(event)
	-- 対象entity
	local entity = event.entity
	
	-- 長距離砲はワームのシールドを削る
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and entity.type == "turret" and entity.force.name == "enemy" then
			local shield = storage.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1撃で6割削れる
				storage.biter_shields[entity.unit_number] = 0.4 * shield
			
			end
		end
	end
	
	-- 長距離砲は巣のシールドを削る
	local cause = event.cause
	if cause and cause.name == "artillery-turret" then
		if entity and entity.type == "unit-spawner" then
			local shield = storage.biter_shields[entity.unit_number] or 0
			if shield > 0 then
			
				-- 1撃で2割削れる
				storage.biter_shields[entity.unit_number] = 0.8 * shield
			
			end
		end
	end
	
	-- ダメージ処理
	if entity and ((entity.type == "unit" or entity.type == "turret" or entity.type == "unit-spawner") and entity.force.name == "enemy") then
		local shield = storage.biter_shields[entity.unit_number] or 0
		if shield > 0 then
			local damage = event.final_damage_amount
			local new_shield_value = shield - damage
			if new_shield_value < 0 then
				entity.health = entity.health + new_shield_value  -- マイナス値
				storage.biter_shields[entity.unit_number] = 0
			else
				storage.biter_shields[entity.unit_number] = new_shield_value
				entity.health = entity.health + damage  -- 減少
			end
		end
	end
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