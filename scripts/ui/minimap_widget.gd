class_name MinimapWidget
extends Control

var world: ArenaBattleWorld = null

func _process(_delta: float) -> void:
	if is_visible_in_tree():
		queue_redraw()

func _draw() -> void:
	var sz: Vector2 = size
	draw_rect(Rect2(Vector2.ZERO, sz), Color("#0b172ae6"), true)
	draw_rect(Rect2(Vector2.ZERO, sz), Color("#38bdf8"), false, 2.0)

	draw_line(Vector2(10.0, sz.y - 10.0), Vector2(sz.x - 10.0, 10.0), Color("#94a3b855"), 8.0)
	draw_line(Vector2(10.0, 10.0), Vector2(sz.x - 10.0, sz.y - 10.0), Color("#0ea5e955"), 5.0)

	if world == null:
		return

	for t: CombatUnit in world.turret_units:
		if t == null or t.is_dead():
			continue
		var p: Vector2 = _world_to_map(t.position, sz)
		var col: Color = Color("#3b82f6") if t.team == "blue" else Color("#ef4444")
		var r: float = 5.5 if t.is_nexus else 3.8
		draw_rect(Rect2(p - Vector2(r, r), Vector2(r * 2.0, r * 2.0)), col, true)

	for c: CombatUnit in world.creep_units:
		if c == null or c.is_dead():
			continue
		var p: Vector2 = _world_to_map(c.position, sz)
		draw_circle(p, 2.8, Color("#f59e0b"))

	for m: CombatUnit in world.minion_units:
		if m == null or m.is_dead():
			continue
		var p: Vector2 = _world_to_map(m.position, sz)
		var col: Color = Color("#60a5fa") if m.team == "blue" else Color("#f87171")
		draw_circle(p, 2.0, col)

	for h: CombatUnit in world.hero_units:
		if h == null or h.is_dead():
			continue
		var p: Vector2 = _world_to_map(h.position, sz)
		var col: Color = Color("#facc15") if h.is_player else (Color("#38bdf8") if h.team == "blue" else Color("#ef4444"))
		draw_circle(p, 5.2 if h.is_player else 4.2, col)
		draw_arc(p, 5.5 if h.is_player else 4.5, 0.0, TAU, 16, Color.WHITE, 1.2)

func _world_to_map(pos: Vector3, sz: Vector2) -> Vector2:
	var nx: float = clampf((pos.x + 44.0) / 88.0, 0.05, 0.95)
	var nz: float = clampf((pos.z + 44.0) / 88.0, 0.05, 0.95)
	return Vector2(nx * sz.x, nz * sz.y)

