class_name SkillData
extends Resource

@export var key: String = "1"
@export var name: String = "Speed Shot"
@export var sub_text: String = "Cooldown 5s · Mana 50"
@export var tags: String = "[Skillshot] [Damage]"
@export var description: String = ""
@export var cooldown: float = 5.0
@export var mana_cost: float = 45.0
@export var base_damage: float = 250.0
@export var atk_ratio: float = 1.0
@export var skill_type: String = "line_bolt"
@export var color_hex: String = "#38bdf8"
@export var cast_range: float = 9.0
@export var icon_path: String = ""

static func create(
	p_key: String,
	p_name: String,
	p_sub: String,
	p_tags: String,
	p_desc: String,
	p_cd: float,
	p_mana: float,
	p_dmg: float,
	p_ratio: float,
	p_type: String,
	p_col: String,
	p_range: float,
	p_icon: String
) -> SkillData:
	var s := SkillData.new()
	s.key = p_key
	s.name = p_name
	s.sub_text = p_sub
	s.tags = p_tags
	s.description = p_desc
	s.cooldown = p_cd
	s.mana_cost = p_mana
	s.base_damage = p_dmg
	s.atk_ratio = p_ratio
	s.skill_type = p_type
	s.color_hex = p_col
	s.cast_range = p_range
	s.icon_path = p_icon
	return s

