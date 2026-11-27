class_name RobloxHeroRig
extends Node3D

var left_leg_pivot: Node3D
var right_leg_pivot: Node3D
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var head_group: Node3D
var torso_group: Node3D
var weapon_group: Node3D
var left_tail_group: Node3D = null
var right_tail_group: Node3D = null
var aura_ring: MeshInstance3D = null
var foot_ring: MeshInstance3D = null

var walk_phase: float = 0.0
var attack_timer: float = 0.0

func _ready() -> void:
	walk_phase = randf() * TAU

func animate_character(dt: float, is_moving: bool, trigger_attack: bool) -> void:
	walk_phase += dt * (12.0 if is_moving else 2.6)

	if is_moving:
		var swing: float = sin(walk_phase) * 0.68
		if left_leg_pivot:
			left_leg_pivot.rotation.x = swing
		if right_leg_pivot:
			right_leg_pivot.rotation.x = -swing
		if left_arm_pivot:
			left_arm_pivot.rotation.x = -swing * 0.8
		if right_arm_pivot and attack_timer <= 0.0:
			right_arm_pivot.rotation.x = 0.45 + swing * 0.45

		var bounce: float = absf(cos(walk_phase)) * 0.08
		if torso_group:
			torso_group.position.y = 1.55 + bounce
			torso_group.rotation.z = sin(walk_phase) * 0.05
		if head_group:
			head_group.position.y = 2.52 + bounce

		if left_tail_group and right_tail_group:
			left_tail_group.rotation.x = -0.25 + sin(walk_phase * 2.0) * 0.14
			right_tail_group.rotation.x = -0.25 + cos(walk_phase * 2.0) * 0.14
	else:
		var idle_bob: float = sin(walk_phase) * 0.045
		if left_leg_pivot:
			left_leg_pivot.rotation.x *= 0.84
		if right_leg_pivot:
			right_leg_pivot.rotation.x *= 0.84
		if left_arm_pivot:
			left_arm_pivot.rotation.x = idle_bob * 1.4
		if right_arm_pivot and attack_timer <= 0.0:
			right_arm_pivot.rotation.x = 0.35 + idle_bob
		if torso_group:
			torso_group.position.y = 1.55 + idle_bob
			torso_group.rotation.z *= 0.85
		if head_group:
			head_group.position.y = 2.52 + idle_bob

		if left_tail_group and right_tail_group:
			left_tail_group.rotation.z = 0.18 + sin(walk_phase) * 0.05
			right_tail_group.rotation.z = -0.18 - sin(walk_phase) * 0.05
			left_tail_group.rotation.x *= 0.85
			right_tail_group.rotation.x *= 0.85

	if trigger_attack:
		attack_timer = 0.26

	if attack_timer > 0.0:
		attack_timer -= dt
		var slash_progress: float = (0.26 - attack_timer) / 0.26
		if right_arm_pivot:
			right_arm_pivot.rotation.x = 1.35 - sin(slash_progress * TAU) * 0.75
		if torso_group:
			torso_group.rotation.y = sin(slash_progress * PI) * 0.28
	else:
		if torso_group:
			torso_group.rotation.y *= 0.85

