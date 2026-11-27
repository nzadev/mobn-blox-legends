class_name CombatUnit
extends CharacterBody3D

@export var unit_id: String = ""
@export var unit_name: String = "Unit"
@export var team: String = "blue"
@export var is_hero: bool = false
@export var is_player: bool = false
@export var is_turret: bool = false
@export var is_nexus: bool = false
@export var is_creep: bool = false
@export var is_minion: bool = false

var hero_data: HeroData = null
var rig: RobloxHeroRig = null
var health: HealthComponent = null
var skills_comp: SkillComponent = null

var unit_radius: float = 0.9
var level: int = 1
var xp: int = 0
var gold: int = 850
var kills: int = 0
var deaths: int = 0
var assists: int = 0
var multi_kill_count: int = 0
var multi_kill_timer: float = 0.0
var kill_streak: int = 0

var atk: float = 120.0
var move_speed: float = 5.8
var attack_range: float = 4.0
var attack_speed: float = 1.2
var crit_chance: float = 0.15
var atk_cd: float = 0.0

var stun_timer: float = 0.0
var regen_timer: float = 0.0
var recall_timer: float = 0.0
var speed_buff_timer: float = 0.0
var orbit_timer: float = 0.0
var respawn_timer: float = 0.0
var in_bush: bool = false

var home_pos: Vector3 = Vector3.ZERO
var crystal_mesh: MeshInstance3D = null
var aura_ring_mesh: MeshInstance3D = null

func _init() -> void:
	health = HealthComponent.new()
	health.name = "HealthComponent"
	add_child(health)

	skills_comp = SkillComponent.new()
	skills_comp.name = "SkillComponent"
	add_child(skills_comp)

func is_dead() -> bool:
	return health.is_dead

