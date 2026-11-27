class_name RobloxHeroRig
extends Node3D

var hero_id: String = "laylul"
var left_leg_pivot: Node3D
var right_leg_pivot: Node3D
var left_knee_pivot: Node3D
var right_knee_pivot: Node3D
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var left_elbow_pivot: Node3D
var right_elbow_pivot: Node3D
var head_group: Node3D
var torso_group: Node3D
var cape_pivot: Node3D = null
var left_wing_pivot: Node3D = null
var right_wing_pivot: Node3D = null
var halo_node: Node3D = null
var weapon_group: Node3D
var left_weapon_group: Node3D = null
var left_tail_group: Node3D = null
var right_tail_group: Node3D = null
var aura_ring: MeshInstance3D = null
var foot_ring: MeshInstance3D = null

var walk_phase: float = 0.0
var blend_move: float = 0.0
var attack_timer: float = 0.0
var attack_duration: float = 0.34
var combo_step: int = 0

var action_state: String = ""
var action_timer: float = 0.0
var action_duration: float = 0.55

var orbit_blades_group: Node3D = null
var dragon_morph_node: Node3D = null

func _ready() -> void:
	walk_phase = randf() * TAU

func trigger_skill_pose(skill_slot: int, duration: float = 0.55) -> void:
	action_state = "skill_%d" % skill_slot
	action_duration = maxf(0.25, duration)
	action_timer = action_duration

func set_dragon_form_active(active: bool) -> void:
	if dragon_morph_node != null:
		dragon_morph_node.visible = active
	if torso_group != null:
		torso_group.scale = Vector3(1.25, 1.25, 1.25) if active else Vector3.ONE

func set_orbit_swords_active(active: bool, dt: float = 0.016) -> void:
	if orbit_blades_group != null:
		orbit_blades_group.visible = active
		if active:
			orbit_blades_group.rotation.y += dt * 7.5

func animate_character(dt: float, is_moving: bool, trigger_attack: bool) -> void:
	var spd_mult: float = 11.5
	if hero_id in ["sabro", "masteryee", "gusionox"]:
		spd_mult = 14.8
	elif hero_id in ["minotor", "yuzong"]:
		spd_mult = 9.6
	elif hero_id in ["kimee", "esteez"]:
		spd_mult = 7.8

	blend_move = lerpf(blend_move, 1.0 if is_moving else 0.0, minf(1.0, dt * 14.0))
	walk_phase += dt * lerpf(2.6, spd_mult, blend_move)

	if halo_node != null:
		halo_node.rotation.z += dt * 1.8
	if left_wing_pivot != null and right_wing_pivot != null:
		var flap: float = sin(walk_phase * 1.4) * (0.35 if is_moving else 0.16)
		left_wing_pivot.rotation.y = 0.25 + flap
		right_wing_pivot.rotation.y = -0.25 - flap
	if cape_pivot != null:
		cape_pivot.rotation.x = lerpf(0.14, 0.52, blend_move) + sin(walk_phase * 1.8) * 0.12

	var s: float = sin(walk_phase)
	var c: float = cos(walk_phase)
	var s2: float = sin(walk_phase * 2.0)

	# 1. Smooth Articulated Lower Body (Hips + Knees + Pelvis Twist)
	var target_l_hip: Vector3 = Vector3.ZERO
	var target_r_hip: Vector3 = Vector3.ZERO
	var target_l_knee: float = 0.0
	var target_r_knee: float = 0.0
	var target_torso_pos: Vector3 = Vector3(0.0, 1.56, 0.0)
	var target_torso_rot: Vector3 = Vector3.ZERO
	var target_head_pos: Vector3 = Vector3(0.0, 2.55, 0.0)
	var target_head_rot: Vector3 = Vector3.ZERO

	if hero_id in ["kimee", "esteez"]:
		var hover_y: float = s * 0.14
		target_torso_pos = Vector3(0.0, 1.74 + hover_y, 0.0)
		target_head_pos = Vector3(0.0, 2.72 + hover_y, 0.0)
		target_torso_rot = Vector3(0.24 * blend_move, s * 0.08, -s * 0.06 * blend_move)
		target_l_hip = Vector3(-0.28 - 0.2 * blend_move + s * 0.12, 0.0, -0.05)
		target_r_hip = Vector3(-0.38 - 0.2 * blend_move - s * 0.12, 0.0, 0.05)
		target_l_knee = 0.55 + s * 0.15
		target_r_knee = 0.68 - s * 0.15
	elif hero_id in ["sabro", "masteryee", "gusionox"]:
		var stride: float = s * 0.95 * blend_move
		var bounce: float = absf(c) * 0.11 * blend_move + s * 0.04 * (1.0 - blend_move)
		target_l_hip = Vector3(stride, 0.0, -0.04)
		target_r_hip = Vector3(-stride, 0.0, 0.04)
		target_l_knee = maxf(0.08, -c * 0.95 * blend_move)
		target_r_knee = maxf(0.08, c * 0.95 * blend_move)
		target_torso_pos = Vector3(0.0, 1.50 + bounce, 0.0)
		target_torso_rot = Vector3(0.34 * blend_move, -s * 0.18 * blend_move, s * 0.07 * blend_move)
		target_head_pos = Vector3(0.0, 2.48 + bounce, 0.12 * blend_move)
		target_head_rot = Vector3(-0.18 * blend_move, s * 0.12 * blend_move, 0.0)
	else:
		var stride: float = s * 0.78 * blend_move
		var bounce: float = absf(c) * 0.09 * blend_move + s * 0.045 * (1.0 - blend_move)
		target_l_hip = Vector3(stride, 0.0, -0.03)
		target_r_hip = Vector3(-stride, 0.0, 0.03)
		target_l_knee = maxf(0.05, -c * 0.82 * blend_move)
		target_r_knee = maxf(0.05, c * 0.82 * blend_move)
		target_torso_pos = Vector3(0.0, 1.56 + bounce, 0.0)
		target_torso_rot = Vector3(0.12 * blend_move, -s * 0.14 * blend_move, s * 0.06 * blend_move)
		target_head_pos = Vector3(0.0, 2.55 + bounce, 0.0)
		target_head_rot = Vector3(s2 * 0.03, s * 0.09 * blend_move, 0.0)

	var smooth: float = minf(1.0, dt * 18.0)
	if left_leg_pivot:
		left_leg_pivot.rotation = left_leg_pivot.rotation.lerp(target_l_hip, smooth)
	if right_leg_pivot:
		right_leg_pivot.rotation = right_leg_pivot.rotation.lerp(target_r_hip, smooth)
	if left_knee_pivot:
		left_knee_pivot.rotation.x = lerpf(left_knee_pivot.rotation.x, target_l_knee, smooth)
	if right_knee_pivot:
		right_knee_pivot.rotation.x = lerpf(right_knee_pivot.rotation.x, target_r_knee, smooth)

	# 2. Upper Body & Articulated Arms (Shoulder + Elbow)
	var arm_poses: Dictionary = _compute_hero_arm_targets(s, c)
	var target_r_arm: Vector3 = arm_poses["r_arm"]
	var target_l_arm: Vector3 = arm_poses["l_arm"]
	var target_r_elbow: float = arm_poses["r_elbow"]
	var target_l_elbow: float = arm_poses["l_elbow"]

	if trigger_attack:
		attack_timer = attack_duration
		combo_step = (combo_step + 1) % 3

	if action_timer > 0.0:
		action_timer = maxf(0.0, action_timer - dt)
		var ap: float = clampf(1.0 - (action_timer / action_duration), 0.0, 1.0)
		var skill_pose: Dictionary = _compute_skill_pose(ap)
		target_r_arm = skill_pose.get("r_arm", target_r_arm)
		target_l_arm = skill_pose.get("l_arm", target_l_arm)
		target_r_elbow = skill_pose.get("r_elbow", target_r_elbow)
		target_l_elbow = skill_pose.get("l_elbow", target_l_elbow)
		target_torso_rot = skill_pose.get("torso_rot", target_torso_rot)
		target_torso_pos += skill_pose.get("torso_offset", Vector3.ZERO)
		target_head_pos += skill_pose.get("torso_offset", Vector3.ZERO)
	elif attack_timer > 0.0:
		attack_timer = maxf(0.0, attack_timer - dt)
		var p: float = clampf(1.0 - (attack_timer / attack_duration), 0.0, 1.0)
		var atk_pose: Dictionary = _compute_attack_pose(p)
		target_r_arm = atk_pose.get("r_arm", target_r_arm)
		target_l_arm = atk_pose.get("l_arm", target_l_arm)
		target_r_elbow = atk_pose.get("r_elbow", target_r_elbow)
		target_l_elbow = atk_pose.get("l_elbow", target_l_elbow)
		target_torso_rot = atk_pose.get("torso_rot", target_torso_rot)
		target_torso_pos += atk_pose.get("torso_offset", Vector3.ZERO)

	var arm_smooth: float = minf(1.0, dt * 24.0)
	if torso_group:
		torso_group.position = torso_group.position.lerp(target_torso_pos, arm_smooth)
		torso_group.rotation = torso_group.rotation.lerp(target_torso_rot, arm_smooth)
	if head_group:
		head_group.position = head_group.position.lerp(target_head_pos, arm_smooth)
		head_group.rotation = head_group.rotation.lerp(target_head_rot, arm_smooth)
	if right_arm_pivot:
		right_arm_pivot.rotation = right_arm_pivot.rotation.lerp(target_r_arm, arm_smooth)
	if left_arm_pivot:
		left_arm_pivot.rotation = left_arm_pivot.rotation.lerp(target_l_arm, arm_smooth)
	if right_elbow_pivot:
		right_elbow_pivot.rotation.x = lerpf(right_elbow_pivot.rotation.x, target_r_elbow, arm_smooth)
	if left_elbow_pivot:
		left_elbow_pivot.rotation.x = lerpf(left_elbow_pivot.rotation.x, target_l_elbow, arm_smooth)

	if left_tail_group and right_tail_group:
		var tail_x: float = lerpf(-0.12, -0.45, blend_move) + s2 * 0.14
		left_tail_group.rotation.x = lerpf(left_tail_group.rotation.x, tail_x, smooth)
		right_tail_group.rotation.x = lerpf(right_tail_group.rotation.x, tail_x, smooth)
		left_tail_group.rotation.z = 0.22 + s * 0.08
		right_tail_group.rotation.z = -0.22 - s * 0.08

func _compute_hero_arm_targets(s: float, c: float) -> Dictionary:
	var sw: float = s * blend_move
	match hero_id:
		"laylul", "kimee":
			return {
				"r_arm": Vector3(0.55 + sw * 0.12, -0.18, 0.08),
				"l_arm": Vector3(0.50 + sw * 0.12, 0.35, -0.12),
				"r_elbow": -0.45,
				"l_elbow": -0.58
			}
		"ketootoo":
			return {
				"r_arm": Vector3(0.68 + sw * 0.35, -0.08, 0.12),
				"l_arm": Vector3(0.68 - sw * 0.35, 0.08, -0.12),
				"r_elbow": -0.42,
				"l_elbow": -0.42
			}
		"sabro", "gusionox":
			return {
				"r_arm": Vector3(-0.48 + sw * 0.45, 0.15, 0.32),
				"l_arm": Vector3(-0.48 - sw * 0.45, -0.15, -0.32),
				"r_elbow": -0.65,
				"l_elbow": -0.65
			}
		"yuzong":
			return {
				"r_arm": Vector3(0.42 + sw * 0.35, -0.22, 0.42),
				"l_arm": Vector3(0.42 - sw * 0.35, 0.22, -0.42),
				"r_elbow": -0.75,
				"l_elbow": -0.75
			}
		"yeen":
			return {
				"r_arm": Vector3(0.78 + sw * 0.25, -0.28, 0.18),
				"l_arm": Vector3(0.62 - sw * 0.25, 0.28, -0.18),
				"r_elbow": -1.05,
				"l_elbow": -0.95
			}
		"minotor":
			return {
				"r_arm": Vector3(0.48 + sw * 0.28, 0.18, 0.25),
				"l_arm": Vector3(-sw * 0.55, 0.0, -0.22),
				"r_elbow": -0.52,
				"l_elbow": -0.35
			}
		"esteez":
			return {
				"r_arm": Vector3(0.52 + s * 0.15, 0.0, 0.15),
				"l_arm": Vector3(0.65 - s * 0.1, 0.32, -0.18),
				"r_elbow": -0.48,
				"l_elbow": -0.72
			}
		"masteryee":
			return {
				"r_arm": Vector3(0.32 + sw * 0.35, -0.25, 0.28),
				"l_arm": Vector3(-sw * 0.6, 0.1, -0.22),
				"r_elbow": -0.58,
				"l_elbow": -0.42
			}
		"alucardox":
			return {
				"r_arm": Vector3(-0.32 + sw * 0.35, 0.12, 0.26),
				"l_arm": Vector3(0.28 - sw * 0.45, 0.22, -0.2),
				"r_elbow": -0.62,
				"l_elbow": -0.48
			}
		"kajee":
			return {
				"r_arm": Vector3(0.38 + sw * 0.4, -0.15, 0.32),
				"l_arm": Vector3(0.45 - sw * 0.3, 0.35, -0.25),
				"r_elbow": -0.55,
				"l_elbow": -0.65
			}
		_:
			return {
				"r_arm": Vector3(0.45 + sw * 0.4, 0.0, 0.1),
				"l_arm": Vector3(-sw * 0.5, 0.0, -0.1),
				"r_elbow": -0.4,
				"l_elbow": -0.4
			}

func _compute_attack_pose(p: float) -> Dictionary:
	var swing: float = sin(p * PI)
	var snap: float = sin(minf(1.0, p * 1.45) * PI)
	match hero_id:
		"laylul", "kimee":
			return {
				"r_arm": Vector3(0.85 + snap * 0.45, -0.12, 0.08),
				"l_arm": Vector3(0.75 + snap * 0.45, 0.32, -0.12),
				"r_elbow": -0.65 - snap * 0.35,
				"l_elbow": -0.70 - snap * 0.35,
				"torso_rot": Vector3(-snap * 0.22, 0.0, 0.0),
				"torso_offset": Vector3(0.0, 0.0, -snap * 0.22)
			}
		"ketootoo":
			var is_right: bool = (combo_step % 2 == 0)
			return {
				"r_arm": Vector3(1.15 + snap * 0.45 if is_right else 0.55, -0.05, 0.15),
				"l_arm": Vector3(0.55 if is_right else 1.15 + snap * 0.45, 0.05, -0.15),
				"r_elbow": -0.25 if is_right else -0.65,
				"l_elbow": -0.65 if is_right else -0.25,
				"torso_rot": Vector3(-snap * 0.12, (0.32 if is_right else -0.32) * snap, 0.0)
			}
		"sabro", "gusionox":
			return {
				"r_arm": Vector3(1.65 - p * 2.4, -0.55 + p * 1.2, 0.35),
				"l_arm": Vector3(1.65 - p * 2.4, 0.55 - p * 1.2, -0.35),
				"r_elbow": -0.25,
				"l_elbow": -0.25,
				"torso_rot": Vector3(0.32, sin(p * TAU) * 0.65, 0.0)
			}
		"yuzong", "yeen":
			var is_r: bool = (combo_step % 2 == 0)
			return {
				"r_arm": Vector3(1.55 * snap if is_r else 0.35, -0.35 * snap, 0.25),
				"l_arm": Vector3(0.35 if is_r else 1.55 * snap, 0.35 * snap, -0.25),
				"r_elbow": -0.15 if is_r else -1.1,
				"l_elbow": -1.1 if is_r else -0.15,
				"torso_rot": Vector3(0.22 * snap, (0.58 if is_r else -0.58) * snap, 0.0)
			}
		"minotor", "alucardox":
			return {
				"r_arm": Vector3(2.25 - p * 3.1, 0.15, 0.18),
				"l_arm": Vector3(1.85 - p * 2.6, 0.25, -0.18),
				"r_elbow": -0.2,
				"l_elbow": -0.3,
				"torso_rot": Vector3(0.42 * sin(p * PI), 0.25 * swing, 0.0)
			}
		"kajee":
			return {
				"r_arm": Vector3(1.05, -0.95 + p * 2.1, 0.45),
				"l_arm": Vector3(0.65, 0.45, -0.25),
				"r_elbow": -0.15 * swing,
				"l_elbow": -0.75,
				"torso_rot": Vector3(0.18, swing * 0.62, 0.0)
			}
		_:
			return {
				"r_arm": Vector3(1.75 - p * 2.5, -0.35 + p * 0.8, 0.22),
				"l_arm": Vector3(-0.35, 0.15, -0.25),
				"r_elbow": -0.2,
				"l_elbow": -0.55,
				"torso_rot": Vector3(0.22, (0.62 if combo_step % 2 == 0 else -0.62) * swing, 0.0)
			}

func _compute_skill_pose(p: float) -> Dictionary:
	var w: float = sin(p * PI)
	if action_state == "skill_1":
		if hero_id in ["yuzong", "alucardox", "sabro", "gusionox"]:
			# Full 360 Spin / Fan Release
			return {
				"r_arm": Vector3(0.25, 0.0, 1.35),
				"l_arm": Vector3(0.25, 0.0, -1.35),
				"r_elbow": -0.1,
				"l_elbow": -0.1,
				"torso_rot": Vector3(0.15, p * TAU, 0.0)
			}
		elif hero_id in ["minotor", "masteryee", "yeen"]:
			# Dash Lunge / Leap Smash
			return {
				"r_arm": Vector3(1.95 - p * 2.4, 0.0, 0.35),
				"l_arm": Vector3(1.95 - p * 2.4, 0.0, -0.35),
				"r_elbow": -0.2,
				"l_elbow": -0.2,
				"torso_rot": Vector3(0.35 * w, 0.0, 0.0),
				"torso_offset": Vector3(0.0, w * 0.95, 0.0)
			}
	elif action_state == "skill_2":
		if hero_id in ["yuzong", "yeen", "ketootoo", "kimee", "sabro", "kajee"]:
			# High-speed Dash / Acrobatic Roll / Dive
			return {
				"r_arm": Vector3(-0.85, 0.0, 0.55),
				"l_arm": Vector3(-0.85, 0.0, -0.55),
				"r_elbow": -0.45,
				"l_elbow": -0.45,
				"torso_rot": Vector3(0.55 * w, 0.0, 0.0),
				"torso_offset": Vector3(0.0, w * 0.65, 0.0)
			}
	elif action_state == "skill_3":
		# Ultimate Signature Pose (Sky Execution Jump / Mega Laser Brace / Minoan Triple Quake / Dragon Flight)
		if hero_id in ["sabro", "yuzong", "minotor", "alucardox", "gusionox"]:
			return {
				"r_arm": Vector3(2.2 - p * 2.6, 0.0, 0.75),
				"l_arm": Vector3(2.2 - p * 2.6, 0.0, -0.75),
				"r_elbow": -0.15,
				"l_elbow": -0.15,
				"torso_rot": Vector3(0.35 * w, sin(p * TAU * 2.0) * 0.45, 0.0),
				"torso_offset": Vector3(0.0, w * 1.45, 0.0)
			}
		else:
			return {
				"r_arm": Vector3(1.15, -0.15, 0.25),
				"l_arm": Vector3(1.15, 0.15, -0.25),
				"r_elbow": -0.2,
				"l_elbow": -0.2,
				"torso_rot": Vector3(-0.28 * w, 0.0, 0.0),
				"torso_offset": Vector3(0.0, w * 0.35, -w * 0.28)
			}
	return _compute_attack_pose(p)
