class_name HealthComponent
extends Node

signal hp_changed(current_hp: float, max_hp: float)
signal mana_changed(current_mana: float, max_mana: float)
signal damage_taken(attacker: Node, amount: int, is_crit: bool)
signal healed(amount: int)
signal health_depleted(killer: Node)

@export var max_hp: float = 2272.0
@export var current_hp: float = 2272.0
@export var max_mana: float = 480.0
@export var current_mana: float = 480.0
@export var defense: float = 18.0
@export var is_dead: bool = false

func setup(p_hp: float, p_mana: float, p_def: float) -> void:
	max_hp = p_hp
	current_hp = p_hp
	max_mana = p_mana
	current_mana = p_mana
	defense = p_def
	is_dead = false
	hp_changed.emit(current_hp, max_hp)
	mana_changed.emit(current_mana, max_mana)

func reset_full() -> void:
	is_dead = false
	current_hp = max_hp
	current_mana = max_mana
	hp_changed.emit(current_hp, max_hp)
	mana_changed.emit(current_mana, max_mana)

func spend_mana(amount: float) -> bool:
	if current_mana < amount:
		return false
	current_mana = maxf(0.0, current_mana - amount)
	mana_changed.emit(current_mana, max_mana)
	return true

func restore_mana(amount: float) -> void:
	if is_dead:
		return
	current_mana = minf(max_mana, current_mana + amount)
	mana_changed.emit(current_mana, max_mana)

func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	current_hp = minf(max_hp, current_hp + float(amount))
	hp_changed.emit(current_hp, max_hp)
	healed.emit(amount)

func take_damage(attacker: Node, raw_dmg: float, is_crit: bool = false) -> int:
	if is_dead:
		return 0
	var mitigated: float = raw_dmg * (100.0 / (100.0 + maxf(0.0, defense)))
	if is_crit:
		mitigated *= 1.75
	var final_dmg: int = maxi(18, roundi(mitigated))
	current_hp = maxf(0.0, current_hp - float(final_dmg))
	hp_changed.emit(current_hp, max_hp)
	damage_taken.emit(attacker, final_dmg, is_crit)
	if current_hp <= 0.0 and not is_dead:
		is_dead = true
		health_depleted.emit(attacker)
	return final_dmg

