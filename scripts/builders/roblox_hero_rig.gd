class_name RobloxHeroRig
extends Node3D

var hero_id: String = "laylul"
var left_leg_pivot: Node3D
var right_leg_pivot: Node3D
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var head_group: Node3D
var torso_group: Node3D
var weapon_group: Node3D
var left_weapon_group: Node3D = null
var left_tail_group: Node3D = null
var right_tail_group: Node3D = null
var aura_ring: MeshInstance3D = null
var foot_ring: MeshInstance3D = null

var walk_phase: float = 0.0
var attack_timer: float = 0.0
var combo_step: int = 0

func _ready() -> void:
	walk_phase = randf() * TAU

func animate_character(dt: float, is_moving: bool, trigger_attack: bool) -> void:
	var spd_mult: float = 12.5
	if hero_id in ["sabro", "masteryee", "gusionox"]:
		spd_mult = 15.5
	elif hero_id in ["minotor", "yuzong"]:
		spd_mult = 10.2
	elif hero_id in ["kimee", "esteez"]:
		spd_mult = 8.5

	walk_phase += dt * (spd_mult if is_moving else 2.8)

	if is_moving:
		var swing: float = sin(walk_phase) * 0.68
		if hero_id == "kimee":
			if left_leg_pivot:
				left_leg_pivot.rotation.x = -0.35 + sin(walk_phase) * 0.15
			if right_leg_pivot:
				right_leg_pivot.rotation.x = -0.45 - sin(walk_phase) * 0.15
			if torso_group:
				torso_group.position.y = 1.75 + sin(walk_phase) * 0.12
				torso_group.rotation.x = 0.22
			if head_group:
				head_group.position.y = 2.72 + sin(walk_phase) * 0.12
		elif hero_id == "esteez":
			if left_leg_pivot:
				left_leg_pivot.rotation.x = sin(walk_phase) * 0.22
			if right_leg_pivot:
				right_leg_pivot.rotation.x = -sin(walk_phase) * 0.22
			if torso_group:
				torso_group.position.y = 1.72 + sin(walk_phase) * 0.1
			if head_group:
				head_group.position.y = 2.68 + sin(walk_phase) * 0.1
		elif hero_id in ["sabro", "masteryee", "gusionox"]:
			if left_leg_pivot:
				left_leg_pivot.rotation.x = swing * 1.15
			if right_leg_pivot:
				right_leg_pivot.rotation.x = -swing * 1.15
			if torso_group:
				torso_group.position.y = 1.5 + absf(cos(walk_phase)) * 0.09
				torso_group.rotation.x = 0.28
			if head_group:
				head_group.position.y = 2.48 + absf(cos(walk_phase)) * 0.09
		else:
			if left_leg_pivot:
				left_leg_pivot.rotation.x = swing
			if right_leg_pivot:
				right_leg_pivot.rotation.x = -swing
			var bounce: float = absf(cos(walk_phase)) * 0.08
			if torso_group:
				torso_group.position.y = 1.56 + bounce
				torso_group.rotation.z = sin(walk_phase) * 0.06
				torso_group.rotation.x = 0.08
			if head_group:
				head_group.position.y = 2.55 + bounce

		if attack_timer <= 0.0:
			_apply_unique_arm_stance(swing, true)

		if left_tail_group and right_tail_group:
			left_tail_group.rotation.x = -0.28 + sin(walk_phase * 2.0) * 0.16
			right_tail_group.rotation.x = -0.28 + cos(walk_phase * 2.0) * 0.16
	else:
		var idle_bob: float = sin(walk_phase) * 0.05
		if hero_id in ["kimee", "esteez"]:
			idle_bob = sin(walk_phase) * 0.11
			if torso_group:
				torso_group.position.y = 1.68 + idle_bob
				torso_group.rotation.x *= 0.85
			if head_group:
				head_group.position.y = 2.65 + idle_bob
		else:
			if torso_group:
				torso_group.position.y = 1.56 + idle_bob
				torso_group.rotation.z *= 0.85
				torso_group.rotation.x *= 0.85
			if head_group:
				head_group.position.y = 2.55 + idle_bob

		if left_leg_pivot:
			left_leg_pivot.rotation.x *= 0.84
		if right_leg_pivot:
			right_leg_pivot.rotation.x *= 0.84

		if attack_timer <= 0.0:
			_apply_unique_arm_stance(idle_bob, false)

		if left_tail_group and right_tail_group:
			left_tail_group.rotation.z = 0.18 + sin(walk_phase) * 0.05
			right_tail_group.rotation.z = -0.18 - sin(walk_phase) * 0.05
			left_tail_group.rotation.x *= 0.85
			right_tail_group.rotation.x *= 0.85

	if trigger_attack:
		attack_timer = 0.30
		combo_step = (combo_step + 1) % 2

	if attack_timer > 0.0:
		attack_timer -= dt
		var p: float = clampf((0.30 - attack_timer) / 0.30, 0.0, 1.0)
		_apply_unique_attack_motion(p)
	else:
		if torso_group:
			torso_group.rotation.y *= 0.82

func _apply_unique_arm_stance(phase_val: float, moving: bool) -> void:
	if left_arm_pivot == null or right_arm_pivot == null:
		return
	match hero_id:
		"laylul", "kimee":
			right_arm_pivot.rotation = Vector3(0.62 + phase_val * 0.15, -0.15, 0.0)
			left_arm_pivot.rotation = Vector3(0.48 + phase_val * 0.15, 0.28, 0.0)
		"ketootoo":
			right_arm_pivot.rotation = Vector3(0.75 + phase_val * 0.3, 0.0, 0.0)
			left_arm_pivot.rotation = Vector3(0.75 - phase_val * 0.3, 0.0, 0.0)
		"sabro", "gusionox":
			right_arm_pivot.rotation = Vector3(-0.45 + phase_val * 0.4, 0.0, 0.25)
			left_arm_pivot.rotation = Vector3(-0.45 - phase_val * 0.4, 0.0, -0.25)
		"yuzong":
			right_arm_pivot.rotation = Vector3(0.35 + phase_val * 0.35, 0.0, 0.38)
			left_arm_pivot.rotation = Vector3(0.35 - phase_val * 0.35, 0.0, -0.38)
		"yeen":
			right_arm_pivot.rotation = Vector3(0.85 + phase_val * 0.25, -0.25, 0.0)
			left_arm_pivot.rotation = Vector3(0.65 - phase_val * 0.25, 0.25, 0.0)
		"minotor":
			right_arm_pivot.rotation = Vector3(0.45 + phase_val * 0.3, 0.15, 0.18)
			left_arm_pivot.rotation = Vector3(-phase_val * 0.5, 0.0, -0.15)
		"esteez":
			right_arm_pivot.rotation = Vector3(0.55 + phase_val * 0.2, 0.0, 0.0)
			left_arm_pivot.rotation = Vector3(0.72, 0.32, 0.0)
		"masteryee":
			right_arm_pivot.rotation = Vector3(0.25 + phase_val * 0.35, -0.2, 0.22)
			left_arm_pivot.rotation = Vector3(-phase_val * 0.6, 0.0, -0.15)
		"alucardox":
			right_arm_pivot.rotation = Vector3(-0.35 + phase_val * 0.35, 0.0, 0.2)
			left_arm_pivot.rotation = Vector3(-phase_val * 0.5, 0.0, -0.18)
		"kajee":
			right_arm_pivot.rotation = Vector3(0.35 + phase_val * 0.4, 0.0, 0.28)
			left_arm_pivot.rotation = Vector3(-phase_val * 0.5, 0.0, -0.2)
		_:
			right_arm_pivot.rotation = Vector3(0.45 + phase_val * 0.4, 0.0, 0.0)
			left_arm_pivot.rotation = Vector3(-phase_val * 0.5, 0.0, 0.0)

func _apply_unique_attack_motion(p: float) -> void:
	if left_arm_pivot == null or right_arm_pivot == null or torso_group == null:
		return
	var wave: float = sin(p * PI)
	match hero_id:
		"laylul", "kimee":
			right_arm_pivot.rotation.x = 0.62 + wave * 0.45
			left_arm_pivot.rotation.x = 0.48 + wave * 0.45
			torso_group.position.z = -wave * 0.18
		"ketootoo":
			if combo_step == 0:
				right_arm_pivot.rotation.x = 0.95 + wave * 0.55
				left_arm_pivot.rotation.x = 0.55
			else:
				left_arm_pivot.rotation.x = 0.95 + wave * 0.55
				right_arm_pivot.rotation.x = 0.55
			torso_group.rotation.y = (0.25 if combo_step == 0 else -0.25) * wave
		"sabro", "gusionox":
			right_arm_pivot.rotation.x = 1.45 - p * 2.2
			left_arm_pivot.rotation.x = 1.45 - p * 2.2
			torso_group.rotation.y = sin(p * TAU) * 0.55
		"yuzong":
			if combo_step == 0:
				right_arm_pivot.rotation.x = 1.6 - p * 2.4
				torso_group.rotation.y = wave * 0.48
			else:
				left_arm_pivot.rotation.x = 1.6 - p * 2.4
				torso_group.rotation.y = -wave * 0.48
		"yeen":
			if combo_step == 0:
				right_arm_pivot.rotation.x = 1.55 * wave
				torso_group.rotation.y = wave * 0.45
			else:
				left_arm_pivot.rotation.x = 1.55 * wave
				torso_group.rotation.y = -wave * 0.45
		"minotor", "alucardox":
			right_arm_pivot.rotation.x = 2.1 - p * 2.8
			left_arm_pivot.rotation.x = 1.6 - p * 2.2
			torso_group.rotation.x = sin(p * PI) * 0.35
		"kajee":
			right_arm_pivot.rotation.y = -0.8 + p * 1.8
			right_arm_pivot.rotation.x = 0.9
			torso_group.rotation.y = wave * 0.52
		"esteez":
			right_arm_pivot.rotation.x = 1.45 * wave
			left_arm_pivot.rotation.x = 1.15 * wave
		"masteryee":
			right_arm_pivot.rotation.x = 1.75 - p * 2.6
			torso_group.rotation.y = (0.6 if combo_step == 0 else -0.6) * wave
		_:
			right_arm_pivot.rotation.x = 1.35 - sin(p * TAU) * 0.75
			torso_group.rotation.y = wave * 0.3
