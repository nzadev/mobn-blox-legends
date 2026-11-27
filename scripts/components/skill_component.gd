class_name SkillComponent
extends Node

signal cooldown_updated(slot_key: String, remaining: float, max_cd: float)

var cooldowns: Dictionary = {
	"1": 0.0,
	"2": 0.0,
	"3": 0.0,
	"recall": 0.0,
	"regen": 0.0,
	"spell": 0.0
}

var max_cooldowns: Dictionary = {
	"1": 5.0,
	"2": 8.0,
	"3": 22.0,
	"recall": 8.0,
	"regen": 12.0,
	"spell": 30.0
}

func setup_from_hero(hero: HeroData, spell_cd: float = 30.0) -> void:
	if hero.skills.size() > 1:
		max_cooldowns["1"] = hero.skills[1].cooldown
	if hero.skills.size() > 2:
		max_cooldowns["2"] = hero.skills[2].cooldown
	if hero.skills.size() > 3:
		max_cooldowns["3"] = hero.skills[3].cooldown
	max_cooldowns["recall"] = 8.0
	max_cooldowns["regen"] = 12.0
	max_cooldowns["spell"] = spell_cd
	for k: String in cooldowns.keys():
		cooldowns[k] = 0.0

func tick_cooldowns(dt: float) -> void:
	for k: String in cooldowns.keys():
		var cur: float = float(cooldowns[k])
		if cur > 0.0:
			cur = maxf(0.0, cur - dt)
			cooldowns[k] = cur
			cooldown_updated.emit(k, cur, float(max_cooldowns.get(k, 1.0)))

func is_ready(slot_key: String) -> bool:
	return float(cooldowns.get(slot_key, 0.0)) <= 0.0

func start_cooldown(slot_key: String, custom_cd: float = -1.0) -> void:
	var cd: float = custom_cd if custom_cd > 0.0 else float(max_cooldowns.get(slot_key, 5.0))
	max_cooldowns[slot_key] = cd
	cooldowns[slot_key] = cd
	cooldown_updated.emit(slot_key, cd, cd)

