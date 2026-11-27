class_name MOBNMainController
extends Node

var world: ArenaBattleWorld
var ui_layer: CanvasLayer

var screen_lobby: Control
var screen_queue: Control
var screen_draft: Control
var screen_battle: Control

var modal_heroes: Control
var modal_setup: Control
var modal_match_end: Control

var lobby_hero_label: Label
var lobby_coins_label: Label
var lobby_gems_label: Label
var skin_selector_box: HBoxContainer
var toast_label: Label
var toast_timer: float = 0.0

var queue_mode_label: Label
var queue_status_label: Label
var queue_btn: Button
var queue_active: bool = false
var queue_time: float = 0.0

var draft_timer_label: Label
var draft_hero_preview_label: Label
var draft_blue_box: VBoxContainer
var draft_red_box: VBoxContainer
var draft_active: bool = false
var draft_time: float = 18.0

var hud_score_label: Label
var hud_time_label: Label
var hud_kda_label: Label
var hud_gold_label: Label
var hud_level_label: Label
var hud_callout_banner: Label
var hud_callout_timer: float = 0.0

var skill_btns: Dictionary = {}
var overhead_container: Control
var floating_texts: Array[Dictionary] = []

var dragging_lobby: bool = false
var joy_dragging: bool = false
var joy_center: Vector2 = Vector2.ZERO
var joy_knob: Control = null

func _ready() -> void:
	world = ArenaBattleWorld.new()
	world.name = "ArenaBattleWorld"
	add_child(world)

	world.floating_text_spawned.connect(_on_floating_text)
	world.gold_popup_spawned.connect(_on_gold_popup)
	world.player_level_up.connect(_on_player_level_up)
	world.hero_killed.connect(_on_hero_killed)
	world.match_ended.connect(_on_match_ended)
	AudioSynthesizer.announcer_callout.connect(_on_announcer_callout)

	_build_ui()
	_refresh_lobby()
	AudioSynthesizer.start_bgm("LOBBY")

func _make_panel_style(bg_hex: String, border_hex: String, radius: int = 10, border_w: int = 2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(bg_hex)
	sb.border_color = Color(border_hex)
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func _style_button(btn: Button, bg_hex: String, border_hex: String, font_sz: int = 16) -> void:
	btn.add_theme_stylebox_override("normal", _make_panel_style(bg_hex, border_hex, 8, 2))
	btn.add_theme_stylebox_override("hover", _make_panel_style(border_hex, "#ffffff", 8, 2))
	btn.add_theme_stylebox_override("pressed", _make_panel_style("#0f172a", border_hex, 8, 2))
	btn.add_theme_font_size_override("font_size", font_sz)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	_build_lobby_screen()
	_build_queue_screen()
	_build_draft_screen()
	_build_battle_screen()
	_build_heroes_modal()
	_build_setup_modal()
	_build_match_end_modal()

	toast_label = Label.new()
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_stylebox_override("normal", _make_panel_style("#0f172aee", "#facc15", 8, 2))
	toast_label.add_theme_font_size_override("font_size", 16)
	toast_label.add_theme_color_override("font_color", Color("#fef08a"))
	toast_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	toast_label.offset_left = 360
	toast_label.offset_right = -360
	toast_label.offset_top = 18
	toast_label.offset_bottom = 56
	toast_label.visible = false
	ui_layer.add_child(toast_label)

	show_screen("lobby")

func _build_lobby_screen() -> void:
	screen_lobby = Control.new()
	screen_lobby.name = "ScreenLobby"
	screen_lobby.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(screen_lobby)

	var top_bar := PanelContainer.new()
	top_bar.add_theme_stylebox_override("panel", _make_panel_style("#0f172acc", "#38bdf8", 10, 2))
	top_bar.position = Vector2(20, 16)
	top_bar.size = Vector2(1240, 64)
	screen_lobby.add_child(top_bar)

	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 18)
	top_bar.add_child(top_hbox)

	if ResourceLoader.exists("res://assets/icons/game_icon.png"):
		var icon_rect := TextureRect.new()
		icon_rect.texture = load("res://assets/icons/game_icon.png") as Texture2D
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		icon_rect.custom_minimum_size = Vector2(46, 46)
		top_hbox.add_child(icon_rect)

	var profile_lbl := Label.new()
	profile_lbl.text = "MOBN: BLOX LEGENDS 5v5  |  Warrior III ★3  [Godot 4.7 Engine]"
	profile_lbl.add_theme_font_size_override("font_size", 18)
	profile_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
	profile_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(profile_lbl)

	lobby_coins_label = Label.new()
	lobby_coins_label.text = "BP: 1600"
	lobby_coins_label.add_theme_font_size_override("font_size", 17)
	lobby_coins_label.add_theme_color_override("font_color", Color("#facc15"))
	top_hbox.add_child(lobby_coins_label)

	lobby_gems_label = Label.new()
	lobby_gems_label.text = "Diamonds: 250"
	lobby_gems_label.add_theme_font_size_override("font_size", 17)
	lobby_gems_label.add_theme_color_override("font_color", Color("#38bdf8"))
	top_hbox.add_child(lobby_gems_label)

	var mute_btn := Button.new()
	mute_btn.text = "Audio: ON"
	_style_button(mute_btn, "#1e293b", "#38bdf8", 14)
	mute_btn.pressed.connect(func() -> void:
		AudioSynthesizer.muted = not AudioSynthesizer.muted
		mute_btn.text = "Audio: OFF" if AudioSynthesizer.muted else "Audio: ON"
	)
	top_hbox.add_child(mute_btn)

	var banner_panel := PanelContainer.new()
	banner_panel.add_theme_stylebox_override("panel", _make_panel_style("#0f172add", "#f59e0b", 12, 2))
	banner_panel.position = Vector2(20, 96)
	banner_panel.size = Vector2(330, 390)
	screen_lobby.add_child(banner_panel)

	var banner_vbox := VBoxContainer.new()
	banner_vbox.add_theme_constant_override("separation", 10)
	banner_panel.add_child(banner_vbox)

	var event_title := Label.new()
	event_title.text = "SEASON 1: BLOX AWAKENING"
	event_title.add_theme_font_size_override("font_size", 16)
	event_title.add_theme_color_override("font_color", Color("#facc15"))
	banner_vbox.add_child(event_title)

	if ResourceLoader.exists("res://assets/ui/lobby_splash_banner.png"):
		var splash := TextureRect.new()
		splash.texture = load("res://assets/ui/lobby_splash_banner.png") as Texture2D
		splash.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		splash.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		splash.custom_minimum_size = Vector2(300, 165)
		banner_vbox.add_child(splash)

	lobby_hero_label = Label.new()
	lobby_hero_label.text = "Laylul · Void Marksman"
	lobby_hero_label.add_theme_font_size_override("font_size", 20)
	lobby_hero_label.add_theme_color_override("font_color", Color("#38bdf8"))
	banner_vbox.add_child(lobby_hero_label)

	var skin_hdr := Label.new()
	skin_hdr.text = "Select Hero Skin:"
	skin_hdr.add_theme_font_size_override("font_size", 14)
	skin_hdr.add_theme_color_override("font_color", Color("#cbd5e1"))
	banner_vbox.add_child(skin_hdr)

	skin_selector_box = HBoxContainer.new()
	skin_selector_box.add_theme_constant_override("separation", 6)
	banner_vbox.add_child(skin_selector_box)

	var tip_lbl := Label.new()
	tip_lbl.text = "Drag center screen to rotate 3D R6 Hero"
	tip_lbl.add_theme_font_size_override("font_size", 13)
	tip_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	banner_vbox.add_child(tip_lbl)

	var nav_bar := HBoxContainer.new()
	nav_bar.position = Vector2(20, 628)
	nav_bar.size = Vector2(740, 68)
	nav_bar.add_theme_constant_override("separation", 14)
	screen_lobby.add_child(nav_bar)

	var btn_heroes := Button.new()
	btn_heroes.text = "HEROES (12)"
	btn_heroes.custom_minimum_size = Vector2(170, 60)
	_style_button(btn_heroes, "#1e3a8a", "#38bdf8", 16)
	btn_heroes.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		modal_heroes.visible = true
	)
	nav_bar.add_child(btn_heroes)

	var btn_prep := Button.new()
	btn_prep.text = "BATTLE SETUP"
	btn_prep.custom_minimum_size = Vector2(170, 60)
	_style_button(btn_prep, "#1e3a8a", "#a855f7", 16)
	btn_prep.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		modal_setup.visible = true
	)
	nav_bar.add_child(btn_prep)

	var btn_emblem := Button.new()
	btn_emblem.text = "EMBLEM LV.60"
	btn_emblem.custom_minimum_size = Vector2(170, 60)
	_style_button(btn_emblem, "#1e293b", "#eab308", 16)
	btn_emblem.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		show_toast("Custom Marksman / Assassin Lv.60 Emblem Set Active!")
	)
	nav_bar.add_child(btn_emblem)

	var btn_quick := Button.new()
	btn_quick.text = "INSTANT 5v5"
	btn_quick.custom_minimum_size = Vector2(170, 60)
	_style_button(btn_quick, "#065f46", "#34d399", 16)
	btn_quick.pressed.connect(func() -> void:
		AudioSynthesizer.confirm()
		GameDatabase.prepare_default_rosters()
		show_screen("battle")
		world.start_match()
	)
	nav_bar.add_child(btn_quick)

	var mode_btn := Button.new()
	mode_btn.text = "CLASSIC / RANKED 5v5\n[ENTER LOBBY ROOM]"
	mode_btn.position = Vector2(930, 588)
	mode_btn.size = Vector2(330, 108)
	_style_button(mode_btn, "#b45309", "#facc15", 20)
	mode_btn.pressed.connect(func() -> void:
		AudioSynthesizer.confirm()
		show_screen("queue")
	)
	screen_lobby.add_child(mode_btn)

func _build_queue_screen() -> void:
	screen_queue = Control.new()
	screen_queue.name = "ScreenQueue"
	screen_queue.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(screen_queue)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style("#09142bee", "#facc15", 14, 3))
	panel.position = Vector2(110, 70)
	panel.size = Vector2(1060, 580)
	screen_queue.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	panel.add_child(vbox)

	var hdr := HBoxContainer.new()
	vbox.add_child(hdr)

	queue_mode_label = Label.new()
	queue_mode_label.text = "CLASSIC 5v5 MATCHMAKING ROOM"
	queue_mode_label.add_theme_font_size_override("font_size", 24)
	queue_mode_label.add_theme_color_override("font_color", Color("#facc15"))
	queue_mode_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(queue_mode_label)

	var switch_btn := Button.new()
	switch_btn.text = "Switch Mode"
	_style_button(switch_btn, "#1e3a8a", "#38bdf8", 15)
	switch_btn.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		var modes: Array[String] = ["CLASSIC", "RANKED", "PRACTICE"]
		var nxt: int = (modes.find(GameDatabase.game_mode) + 1) % modes.size()
		GameDatabase.game_mode = modes[nxt]
		queue_mode_label.text = "%s 5v5 MATCHMAKING ROOM" % GameDatabase.game_mode
	)
	hdr.add_child(switch_btn)

	var back_btn := Button.new()
	back_btn.text = "Back to Lobby"
	_style_button(back_btn, "#7f1d1d", "#ef4444", 15)
	back_btn.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		queue_active = false
		show_screen("lobby")
	)
	hdr.add_child(back_btn)

	var slots_box := HBoxContainer.new()
	slots_box.alignment = BoxContainer.ALIGNMENT_CENTER
	slots_box.add_theme_constant_override("separation", 18)
	slots_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(slots_box)

	var slot_names: Array[String] = ["You (Warrior III)", "Frenchzko", "KENZO", "Kezzy", "merely_cat"]
	var slot_roles: Array[String] = ["Gold Lane", "Jungling", "Mid Lane", "Exp Lane", "Roaming"]
	for i: int in range(5):
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(180, 280)
		card.add_theme_stylebox_override("panel", _make_panel_style("#1e293b", "#facc15" if i == 0 else "#38bdf8", 10, 2))
		var cv := VBoxContainer.new()
		cv.alignment = BoxContainer.ALIGNMENT_CENTER
		cv.add_theme_constant_override("separation", 10)
		card.add_child(cv)

		var h_data: HeroData = GameDatabase.heroes[i % GameDatabase.heroes.size()]
		if ResourceLoader.exists(h_data.portrait_path):
			var tr := TextureRect.new()
			tr.texture = load(h_data.portrait_path) as Texture2D
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.custom_minimum_size = Vector2(120, 130)
			cv.add_child(tr)

		var nl := Label.new()
		nl.text = slot_names[i]
		nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nl.add_theme_font_size_override("font_size", 16)
		nl.add_theme_color_override("font_color", Color("#fef08a" if i == 0 else "#f8fafc"))
		cv.add_child(nl)

		var rl := Label.new()
		rl.text = slot_roles[i]
		rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rl.add_theme_font_size_override("font_size", 14)
		rl.add_theme_color_override("font_color", Color("#38bdf8"))
		cv.add_child(rl)

		slots_box.add_child(card)

	queue_status_label = Label.new()
	queue_status_label.text = " lobby Ready — Press START MATCHMAKING to enter Draft Pick"
	queue_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	queue_status_label.add_theme_font_size_override("font_size", 18)
	queue_status_label.add_theme_color_override("font_color", Color("#38bdf8"))
	vbox.add_child(queue_status_label)

	queue_btn = Button.new()
	queue_btn.text = "START MATCHMAKING (5v5)"
	queue_btn.custom_minimum_size = Vector2(360, 68)
	_style_button(queue_btn, "#b45309", "#facc15", 22)
	queue_btn.pressed.connect(func() -> void:
		if queue_active:
			AudioSynthesizer.click()
			queue_active = false
			queue_btn.text = "START MATCHMAKING (5v5)"
			queue_status_label.text = "Matchmaking Cancelled."
		else:
			AudioSynthesizer.confirm()
			queue_active = true
			queue_time = 0.0
			queue_btn.text = "FINDING MATCH... (CANCEL)"
	)
	vbox.add_child(queue_btn)

func _build_draft_screen() -> void:
	screen_draft = Control.new()
	screen_draft.name = "ScreenDraft"
	screen_draft.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(screen_draft)

	var main_panel := PanelContainer.new()
	main_panel.add_theme_stylebox_override("panel", _make_panel_style("#09142bee", "#38bdf8", 12, 2))
	main_panel.position = Vector2(24, 20)
	main_panel.size = Vector2(1232, 680)
	screen_draft.add_child(main_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	main_panel.add_child(vbox)

	var top_h := HBoxContainer.new()
	vbox.add_child(top_h)

	var blue_hdr := Label.new()
	blue_hdr.text = "BLUE TEAM (ALLY 5v5)"
	blue_hdr.add_theme_font_size_override("font_size", 18)
	blue_hdr.add_theme_color_override("font_color", Color("#38bdf8"))
	blue_hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_h.add_child(blue_hdr)

	draft_timer_label = Label.new()
	draft_timer_label.text = "DRAFT PICK: 18s"
	draft_timer_label.add_theme_font_size_override("font_size", 24)
	draft_timer_label.add_theme_color_override("font_color", Color("#facc15"))
	top_h.add_child(draft_timer_label)

	var red_hdr := Label.new()
	red_hdr.text = "RED TEAM (ENEMY 5v5)"
	red_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	red_hdr.add_theme_font_size_override("font_size", 18)
	red_hdr.add_theme_color_override("font_color", Color("#ef4444"))
	red_hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_h.add_child(red_hdr)

	var mid_h := HBoxContainer.new()
	mid_h.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid_h.add_theme_constant_override("separation", 16)
	vbox.add_child(mid_h)

	draft_blue_box = VBoxContainer.new()
	draft_blue_box.custom_minimum_size = Vector2(230, 0)
	draft_blue_box.add_theme_constant_override("separation", 8)
	mid_h.add_child(draft_blue_box)

	var center_v := VBoxContainer.new()
	center_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_v.add_theme_constant_override("separation", 10)
	mid_h.add_child(center_v)

	draft_hero_preview_label = Label.new()
	draft_hero_preview_label.text = "Selected: Laylul (Marksman · Gold Lane)"
	draft_hero_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draft_hero_preview_label.add_theme_font_size_override("font_size", 20)
	draft_hero_preview_label.add_theme_color_override("font_color", Color("#fef08a"))
	center_v.add_child(draft_hero_preview_label)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_v.add_child(grid)

	for h: HeroData in GameDatabase.heroes:
		var h_btn := Button.new()
		h_btn.custom_minimum_size = Vector2(165, 110)
		_style_button(h_btn, "#1e293b", h.trim_color, 14)
		var hb := HBoxContainer.new()
		hb.set_anchors_preset(Control.PRESET_FULL_RECT)
		hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hb.add_theme_constant_override("separation", 8)
		h_btn.add_child(hb)

		if ResourceLoader.exists(h.portrait_path):
			var tr := TextureRect.new()
			tr.texture = load(h.portrait_path) as Texture2D
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tr.custom_minimum_size = Vector2(68, 86)
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hb.add_child(tr)

		var lbl := Label.new()
		lbl.text = "%s\n[%s]\n%s" % [h.name, h.lane_key, h.role]
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hb.add_child(lbl)

		var hero_ref: HeroData = h
		h_btn.pressed.connect(func() -> void:
			AudioSynthesizer.click()
			_select_hero(hero_ref)
			_populate_draft_rosters()
		)
		grid.add_child(h_btn)

	var bot_actions := HBoxContainer.new()
	bot_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	bot_actions.add_theme_constant_override("separation", 16)
	center_v.add_child(bot_actions)

	var setup_btn := Button.new()
	setup_btn.text = "Builds & Spells"
	setup_btn.custom_minimum_size = Vector2(180, 54)
	_style_button(setup_btn, "#1e3a8a", "#a855f7", 16)
	setup_btn.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		modal_setup.visible = true
	)
	bot_actions.add_child(setup_btn)

	var lock_btn := Button.new()
	lock_btn.text = "LOCK IN & ENTER ARENA"
	lock_btn.custom_minimum_size = Vector2(280, 54)
	_style_button(lock_btn, "#b45309", "#facc15", 18)
	lock_btn.pressed.connect(func() -> void:
		AudioSynthesizer.confirm()
		_lock_in_and_start_battle()
	)
	bot_actions.add_child(lock_btn)

	draft_red_box = VBoxContainer.new()
	draft_red_box.custom_minimum_size = Vector2(230, 0)
	draft_red_box.add_theme_constant_override("separation", 8)
	mid_h.add_child(draft_red_box)

func _build_battle_screen() -> void:
	screen_battle = Control.new()
	screen_battle.name = "ScreenBattle"
	screen_battle.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_battle.mouse_filter = Control.MOUSE_FILTER_PASS
	ui_layer.add_child(screen_battle)

	overhead_container = Control.new()
	overhead_container.name = "OverheadContainer"
	overhead_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	overhead_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_battle.add_child(overhead_container)

	var minimap := MinimapWidget.new()
	minimap.world = world
	minimap.position = Vector2(16, 16)
	minimap.size = Vector2(175, 175)
	screen_battle.add_child(minimap)

	var score_panel := PanelContainer.new()
	score_panel.add_theme_stylebox_override("panel", _make_panel_style("#0f172add", "#38bdf8", 10, 2))
	score_panel.position = Vector2(440, 14)
	score_panel.size = Vector2(400, 54)
	screen_battle.add_child(score_panel)

	var score_h := HBoxContainer.new()
	score_h.alignment = BoxContainer.ALIGNMENT_CENTER
	score_h.add_theme_constant_override("separation", 22)
	score_panel.add_child(score_h)

	hud_score_label = Label.new()
	hud_score_label.text = "BLUE 0  vs  1 RED"
	hud_score_label.add_theme_font_size_override("font_size", 20)
	hud_score_label.add_theme_color_override("font_color", Color("#facc15"))
	score_h.add_child(hud_score_label)

	hud_time_label = Label.new()
	hud_time_label.text = "00:38"
	hud_time_label.add_theme_font_size_override("font_size", 18)
	hud_time_label.add_theme_color_override("font_color", Color.WHITE)
	score_h.add_child(hud_time_label)

	hud_kda_label = Label.new()
	hud_kda_label.text = "0/1/0"
	hud_kda_label.add_theme_font_size_override("font_size", 16)
	hud_kda_label.add_theme_color_override("font_color", Color("#38bdf8"))
	score_h.add_child(hud_kda_label)

	var shop_btn := Button.new()
	shop_btn.position = Vector2(205, 16)
	shop_btn.size = Vector2(195, 58)
	_style_button(shop_btn, "#1e293bdd", "#facc15", 14)
	hud_gold_label = Label.new()
	hud_gold_label.text = "Gold: 850\n[Buy +28 ATK (500g)]"
	hud_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_gold_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_gold_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_btn.add_child(hud_gold_label)
	shop_btn.pressed.connect(func() -> void:
		if world.player_unit == null:
			return
		if world.player_unit.gold >= 500:
			world.player_unit.gold -= 500
			world.player_unit.atk += 28.0
			world.player_unit.attack_speed += 0.15
			AudioSynthesizer.confirm()
			_on_floating_text(world.player_unit.position + Vector3(0.0, 2.8, 0.0), "+28 ATK / +15% SPD!", "#38bdf8")
		else:
			AudioSynthesizer.click()
			show_toast("Need 500 Gold to buy next equipment piece!")
	)
	screen_battle.add_child(shop_btn)

	hud_level_label = Label.new()
	hud_level_label.text = "Lv.3 Laylul"
	hud_level_label.position = Vector2(205, 80)
	hud_level_label.add_theme_font_size_override("font_size", 16)
	hud_level_label.add_theme_color_override("font_color", Color("#fef08a"))
	screen_battle.add_child(hud_level_label)

	var leave_btn := Button.new()
	leave_btn.text = "Lobby"
	leave_btn.position = Vector2(1170, 16)
	leave_btn.size = Vector2(94, 44)
	_style_button(leave_btn, "#7f1d1d", "#ef4444", 14)
	leave_btn.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		world.switch_to_lobby()
		show_screen("lobby")
	)
	screen_battle.add_child(leave_btn)

	hud_callout_banner = Label.new()
	hud_callout_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_callout_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_callout_banner.add_theme_stylebox_override("normal", _make_panel_style("#09142bee", "#facc15", 12, 3))
	hud_callout_banner.add_theme_font_size_override("font_size", 26)
	hud_callout_banner.add_theme_color_override("font_color", Color("#fef08a"))
	hud_callout_banner.position = Vector2(360, 88)
	hud_callout_banner.size = Vector2(560, 64)
	hud_callout_banner.visible = false
	screen_battle.add_child(hud_callout_banner)

	var joy_zone := Panel.new()
	joy_zone.add_theme_stylebox_override("panel", _make_panel_style("#0f172a88", "#38bdf8", 75, 2))
	joy_zone.position = Vector2(46, 510)
	joy_zone.size = Vector2(150, 150)
	screen_battle.add_child(joy_zone)

	joy_knob = Panel.new()
	joy_knob.add_theme_stylebox_override("panel", _make_panel_style("#38bdf8cc", "#ffffff", 28, 2))
	joy_knob.size = Vector2(56, 56)
	joy_knob.position = Vector2(47, 47)
	joy_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joy_zone.add_child(joy_knob)

	joy_zone.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton:
			var mb := ev as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_LEFT:
				joy_dragging = mb.pressed
				joy_center = joy_zone.size * 0.5
				if joy_dragging:
					_update_joystick(mb.position)
				else:
					joy_knob.position = joy_center - joy_knob.size * 0.5
					world.joy_vec = Vector2.ZERO
		elif ev is InputEventMouseMotion and joy_dragging:
			var mm := ev as InputEventMouseMotion
			_update_joystick(mm.position)
	)

	_create_skill_button("atk", "ATK\n[Space]", Vector2(1115, 555), Vector2(124, 124), "#b45309", "#facc15", func() -> void:
		if world.player_unit:
			world.trigger_basic_attack(world.player_unit)
	)
	_create_skill_button("1", "S1 [Q]", Vector2(975, 595), Vector2(86, 86), "#1e3a8a", "#38bdf8", func() -> void:
		if world.player_unit:
			world.trigger_skill(world.player_unit, 1)
	)
	_create_skill_button("2", "S2 [E]", Vector2(1010, 490), Vector2(86, 86), "#1e3a8a", "#a855f7", func() -> void:
		if world.player_unit:
			world.trigger_skill(world.player_unit, 2)
	)
	_create_skill_button("3", "ULT [R]", Vector2(1110, 435), Vector2(94, 94), "#7f1d1d", "#f43f5e", func() -> void:
		if world.player_unit:
			world.trigger_skill(world.player_unit, 3)
	)

	_create_skill_button("recall", "Recall [B]", Vector2(695, 625), Vector2(78, 64), "#0f172a", "#38bdf8", func() -> void:
		if world.player_unit:
			world.trigger_battle_action(world.player_unit, "recall")
	)
	_create_skill_button("regen", "Regen [F]", Vector2(785, 625), Vector2(78, 64), "#064e3b", "#4ade80", func() -> void:
		if world.player_unit:
			world.trigger_battle_action(world.player_unit, "regen")
	)
	_create_skill_button("spell", "Flicker [G]", Vector2(875, 625), Vector2(86, 64), "#1e3a8a", "#38bdf8", func() -> void:
		if world.player_unit:
			world.trigger_battle_action(world.player_unit, "spell")
	)

func _create_skill_button(key: String, title: String, pos: Vector2, sz: Vector2, bg_hex: String, border_hex: String, cb: Callable) -> void:
	var btn := Button.new()
	btn.position = pos
	btn.size = sz
	_style_button(btn, bg_hex, border_hex, 13)
	btn.pressed.connect(cb)

	var icon_rect := TextureRect.new()
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_rect.offset_left = 8
	icon_rect.offset_top = 8
	icon_rect.offset_right = -8
	icon_rect.offset_bottom = -8
	icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.45)
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(icon_rect)

	var lbl := Label.new()
	lbl.text = title
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(lbl)

	screen_battle.add_child(btn)
	skill_btns[key] = {"btn": btn, "label": lbl, "icon": icon_rect, "base_title": title}

func _update_joystick(local_pos: Vector2) -> void:
	var delta_v: Vector2 = local_pos - joy_center
	var max_r: float = 48.0
	var clamped: Vector2 = delta_v.limit_length(max_r)
	joy_knob.position = joy_center + clamped - joy_knob.size * 0.5
	world.joy_vec = clamped / max_r

func _build_heroes_modal() -> void:
	modal_heroes = PanelContainer.new()
	modal_heroes.add_theme_stylebox_override("panel", _make_panel_style("#09142bf6", "#facc15", 14, 3))
	modal_heroes.position = Vector2(80, 50)
	modal_heroes.size = Vector2(1120, 620)
	modal_heroes.visible = false
	ui_layer.add_child(modal_heroes)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	modal_heroes.add_child(vbox)

	var hdr := HBoxContainer.new()
	vbox.add_child(hdr)

	var title := Label.new()
	title.text = "BLOX LEGENDS HERO ROSTER (12 PLAYABLE R6 HEROES)"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#facc15"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "CLOSE [X]"
	_style_button(close_btn, "#7f1d1d", "#ef4444", 15)
	close_btn.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		modal_heroes.visible = false
	)
	hdr.add_child(close_btn)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(grid)

	for h: HeroData in GameDatabase.heroes:
		var card := Button.new()
		card.custom_minimum_size = Vector2(255, 160)
		_style_button(card, "#1e293b", h.trim_color, 14)

		var hb := HBoxContainer.new()
		hb.set_anchors_preset(Control.PRESET_FULL_RECT)
		hb.offset_left = 10
		hb.offset_top = 10
		hb.offset_right = -10
		hb.offset_bottom = -10
		hb.add_theme_constant_override("separation", 12)
		hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(hb)

		if ResourceLoader.exists(h.portrait_path):
			var tr := TextureRect.new()
			tr.texture = load(h.portrait_path) as Texture2D
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tr.custom_minimum_size = Vector2(96, 128)
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hb.add_child(tr)

		var info := Label.new()
		info.text = "%s\n%s\nRole: %s\nLane: %s\nHP: %d | ATK: %d" % [
			h.name, h.title, h.role, h.lane, int(h.max_hp), int(h.base_atk)
		]
		info.add_theme_font_size_override("font_size", 13)
		info.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hb.add_child(info)

		var hero_ref: HeroData = h
		card.pressed.connect(func() -> void:
			AudioSynthesizer.confirm()
			_select_hero(hero_ref)
			modal_heroes.visible = false
		)
		grid.add_child(card)

func _build_setup_modal() -> void:
	modal_setup = PanelContainer.new()
	modal_setup.add_theme_stylebox_override("panel", _make_panel_style("#09142bf6", "#a855f7", 14, 3))
	modal_setup.position = Vector2(140, 80)
	modal_setup.size = Vector2(1000, 560)
	modal_setup.visible = false
	ui_layer.add_child(modal_setup)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	modal_setup.add_child(vbox)

	var hdr := HBoxContainer.new()
	vbox.add_child(hdr)

	var title := Label.new()
	title.text = "BATTLE SETUP: PRO EQUIPMENT BUILDS & BATTLE SPELLS"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#facc15"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "CLOSE [X]"
	_style_button(close_btn, "#7f1d1d", "#ef4444", 15)
	close_btn.pressed.connect(func() -> void:
		AudioSynthesizer.click()
		modal_setup.visible = false
	)
	hdr.add_child(close_btn)

	for b: BuildData in GameDatabase.builds:
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _make_panel_style("#1e293b", b.spell_color, 10, 2))
		row.custom_minimum_size = Vector2(0, 102)
		vbox.add_child(row)

		var rh := HBoxContainer.new()
		rh.add_theme_constant_override("separation", 14)
		row.add_child(rh)

		var desc := Label.new()
		desc.text = "%s (Cost: %dg)\nSpell: %s (%s · %ds CD)" % [b.name, b.cost, b.spell_name, b.spell_sub, int(b.spell_cd)]
		desc.custom_minimum_size = Vector2(280, 0)
		desc.add_theme_font_size_override("font_size", 15)
		rh.add_child(desc)

		var items_h := HBoxContainer.new()
		items_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		items_h.add_theme_constant_override("separation", 8)
		rh.add_child(items_h)

		for it: Dictionary in b.items:
			var ic_box := VBoxContainer.new()
			ic_box.alignment = BoxContainer.ALIGNMENT_CENTER
			var icon_p: String = String(it.get("icon", ""))
			if ResourceLoader.exists(icon_p):
				var tr := TextureRect.new()
				tr.texture = load(icon_p) as Texture2D
				tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tr.custom_minimum_size = Vector2(44, 44)
				ic_box.add_child(tr)
			var il := Label.new()
			il.text = String(it["name"]).substr(0, 10)
			il.add_theme_font_size_override("font_size", 11)
			ic_box.add_child(il)
			items_h.add_child(ic_box)

		var eq_btn := Button.new()
		eq_btn.text = "EQUIP BUILD"
		eq_btn.custom_minimum_size = Vector2(150, 52)
		_style_button(eq_btn, "#b45309", "#facc15", 15)
		var build_ref: BuildData = b
		eq_btn.pressed.connect(func() -> void:
			AudioSynthesizer.confirm()
			GameDatabase.selected_build = build_ref
			show_toast("Equipped %s + %s!" % [build_ref.name, build_ref.spell_name])
			modal_setup.visible = false
		)
		rh.add_child(eq_btn)

func _build_match_end_modal() -> void:
	modal_match_end = PanelContainer.new()
	modal_match_end.add_theme_stylebox_override("panel", _make_panel_style("#09142bf6", "#facc15", 16, 3))
	modal_match_end.position = Vector2(340, 180)
	modal_match_end.size = Vector2(600, 340)
	modal_match_end.visible = false
	ui_layer.add_child(modal_match_end)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	modal_match_end.add_child(vbox)

	var res_lbl := Label.new()
	res_lbl.name = "ResultLabel"
	res_lbl.text = "VICTORY!"
	res_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	res_lbl.add_theme_font_size_override("font_size", 42)
	res_lbl.add_theme_color_override("font_color", Color("#facc15"))
	vbox.add_child(res_lbl)

	var ret_btn := Button.new()
	ret_btn.text = "RETURN TO LOBBY"
	ret_btn.custom_minimum_size = Vector2(260, 64)
	_style_button(ret_btn, "#b45309", "#facc15", 20)
	ret_btn.pressed.connect(func() -> void:
		AudioSynthesizer.confirm()
		modal_match_end.visible = false
		world.switch_to_lobby()
		show_screen("lobby")
	)
	vbox.add_child(ret_btn)

func show_screen(screen_key: String) -> void:
	screen_lobby.visible = (screen_key == "lobby")
	screen_queue.visible = (screen_key == "queue")
	screen_draft.visible = (screen_key == "draft")
	screen_battle.visible = (screen_key == "battle")

func show_toast(msg: String) -> void:
	toast_label.text = msg
	toast_label.visible = true
	toast_timer = 2.8

func _select_hero(hero: HeroData) -> void:
	GameDatabase.selected_hero = hero
	GameDatabase.selected_lane = hero.lane
	if hero.skins.size() > 0:
		GameDatabase.selected_skin = hero.skins[0]
	else:
		GameDatabase.selected_skin = {}
	_refresh_lobby()

func _refresh_lobby() -> void:
	var h: HeroData = GameDatabase.selected_hero
	if h == null:
		return
	lobby_hero_label.text = "%s · %s (%s)" % [h.name, h.role, h.lane]
	lobby_coins_label.text = "BP: %d" % GameDatabase.coins
	world.set_lobby_hero(h, GameDatabase.selected_skin)

	for child: Node in skin_selector_box.get_children():
		child.queue_free()

	for sk: Dictionary in h.skins:
		var s_btn := Button.new()
		s_btn.text = String(sk["tag"])
		_style_button(s_btn, String(sk.get("coat", "#1e293b")), String(sk.get("trim", "#facc15")), 12)
		var sk_ref: Dictionary = sk
		s_btn.pressed.connect(func() -> void:
			AudioSynthesizer.click()
			GameDatabase.selected_skin = sk_ref
			world.set_lobby_hero(h, sk_ref)
			show_toast("Skin Equipped: %s (%s)" % [String(sk_ref["name"]), String(sk_ref["tag"])])
		)
		skin_selector_box.add_child(s_btn)

func _start_draft_phase() -> void:
	queue_active = false
	draft_active = true
	draft_time = 20.0
	AudioSynthesizer.match_found()
	AudioSynthesizer.start_bgm("DRAFT")
	_populate_draft_rosters()
	show_screen("draft")

func _populate_draft_rosters() -> void:
	GameDatabase.prepare_default_rosters()
	var h: HeroData = GameDatabase.selected_hero
	draft_hero_preview_label.text = "Selected: %s (%s · %s)" % [h.name, h.role, h.lane]

	for child: Node in draft_blue_box.get_children():
		child.queue_free()
	for child: Node in draft_red_box.get_children():
		child.queue_free()

	for slot: Dictionary in GameDatabase.blue_roster:
		var hd: HeroData = slot["hero"]
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", _make_panel_style("#1e3a8a", "#facc15" if slot["is_player"] else "#38bdf8", 8, 2))
		var l := Label.new()
		l.text = "%s\n%s (%s)" % [String(slot["player_name"]), hd.name, hd.lane]
		l.add_theme_font_size_override("font_size", 14)
		p.add_child(l)
		draft_blue_box.add_child(p)

	for slot: Dictionary in GameDatabase.red_roster:
		var hd: HeroData = slot["hero"]
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", _make_panel_style("#450a0a", "#ef4444", 8, 2))
		var l := Label.new()
		l.text = "%s\n%s (%s)" % [String(slot["player_name"]), hd.name, hd.lane]
		l.add_theme_font_size_override("font_size", 14)
		p.add_child(l)
		draft_red_box.add_child(p)

func _lock_in_and_start_battle() -> void:
	draft_active = false
	GameDatabase.prepare_default_rosters()
	_refresh_battle_skill_icons()
	show_screen("battle")
	world.start_match()

func _refresh_battle_skill_icons() -> void:
	var h: HeroData = GameDatabase.selected_hero
	if h == null:
		return
	var map_idx: Dictionary = {"atk": 0, "1": 1, "2": 2, "3": 3}
	for k: String in map_idx.keys():
		var idx: int = int(map_idx[k])
		if idx < h.skills.size() and skill_btns.has(k):
			var sk: SkillData = h.skills[idx]
			var tr: TextureRect = skill_btns[k]["icon"]
			if ResourceLoader.exists(sk.icon_path):
				tr.texture = load(sk.icon_path) as Texture2D

func _unhandled_input(event: InputEvent) -> void:
	if screen_lobby.visible:
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_LEFT:
				dragging_lobby = mb.pressed
		elif event is InputEventMouseMotion and dragging_lobby:
			var mm := event as InputEventMouseMotion
			world.rotate_lobby_hero(mm.relative.x * 0.012)
	elif screen_battle.visible and world.running and world.player_unit != null:
		if event is InputEventKey and event.pressed and not event.echo:
			var ke := event as InputEventKey
			match ke.keycode:
				KEY_SPACE:
					world.trigger_basic_attack(world.player_unit)
				KEY_1, KEY_Q:
					world.trigger_skill(world.player_unit, 1)
				KEY_2, KEY_E:
					world.trigger_skill(world.player_unit, 2)
				KEY_3, KEY_R:
					world.trigger_skill(world.player_unit, 3)
				KEY_B:
					world.trigger_battle_action(world.player_unit, "recall")
				KEY_F:
					world.trigger_battle_action(world.player_unit, "regen")
				KEY_G:
					world.trigger_battle_action(world.player_unit, "spell")

func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_label.visible = false

	if hud_callout_timer > 0.0:
		hud_callout_timer -= delta
		if hud_callout_timer <= 0.0:
			hud_callout_banner.visible = false

	if queue_active:
		queue_time += delta
		queue_status_label.text = "Searching 5v5 Match... 00:0%d (Est. 2s)" % int(queue_time)
		if queue_time >= 1.6:
			_start_draft_phase()

	if draft_active:
		draft_time -= delta
		draft_timer_label.text = "DRAFT PICK: %ds" % maxi(0, int(ceil(draft_time)))
		if draft_time <= 0.0:
			_lock_in_and_start_battle()

	if screen_battle.visible and world.running:
		_update_battle_hud(delta)

func _update_battle_hud(dt: float) -> void:
	hud_score_label.text = "BLUE %d  vs  %d RED" % [world.blue_kills, world.red_kills]
	var mins: int = int(world.match_time) / 60
	var secs: int = int(world.match_time) % 60
	hud_time_label.text = "%02d:%02d" % [mins, secs]

	var p: CombatUnit = world.player_unit
	if p != null:
		hud_kda_label.text = "%d/%d/%d" % [p.kills, p.deaths, p.assists]
		hud_gold_label.text = "Gold: %d\n[Buy +28 ATK (500g)]" % p.gold
		hud_level_label.text = "Lv.%d %s  |  HP: %d/%d  |  MP: %d/%d" % [
			p.level,
			p.hero_data.name if p.hero_data else "Hero",
			int(p.health.current_hp),
			int(p.health.max_hp),
			int(p.health.current_mana),
			int(p.health.max_mana)
		]

		for k: String in ["1", "2", "3", "recall", "regen", "spell"]:
			if skill_btns.has(k):
				var entry: Dictionary = skill_btns[k]
				var lbl: Label = entry["label"]
				var rem: float = float(p.skills_comp.cooldowns.get(k, 0.0))
				if rem > 0.05:
					lbl.text = "%.1fs" % rem
				else:
					lbl.text = String(entry["base_title"])

	for child: Node in overhead_container.get_children():
		child.queue_free()

	var cam: Camera3D = world.battle_camera
	if cam == null:
		return

	for u: CombatUnit in world.hero_units:
		if u == null or u.is_dead():
			continue
		var w_pos: Vector3 = u.position + Vector3(0.0, 3.45, 0.0)
		if cam.is_position_behind(w_pos):
			continue
		var s_pos: Vector2 = cam.unproject_position(w_pos)
		var bar := Panel.new()
		bar.position = s_pos - Vector2(46, 18)
		bar.size = Vector2(92, 12)
		bar.add_theme_stylebox_override("panel", _make_panel_style("#0f172acc", "#000000", 3, 1))
		overhead_container.add_child(bar)

		var fill := ColorRect.new()
		var ratio: float = clampf(u.health.current_hp / maxf(1.0, u.health.max_hp), 0.0, 1.0)
		fill.size = Vector2(88.0 * ratio, 8.0)
		fill.position = Vector2(2, 2)
		fill.color = Color("#4ade80") if u.is_player else (Color("#38bdf8") if u.team == "blue" else Color("#ef4444"))
		bar.add_child(fill)

		var n_lbl := Label.new()
		n_lbl.text = "Lv.%d %s" % [u.level, u.hero_data.name if u.hero_data else u.unit_name]
		n_lbl.position = s_pos - Vector2(46, 36)
		n_lbl.add_theme_font_size_override("font_size", 12)
		n_lbl.add_theme_color_override("font_color", Color("#fef08a") if u.is_player else Color.WHITE)
		overhead_container.add_child(n_lbl)

	for idx: int in range(floating_texts.size() - 1, -1, -1):
		var ft: Dictionary = floating_texts[idx]
		var rem: float = float(ft["timer"]) - dt
		ft["timer"] = rem
		if rem <= 0.0:
			floating_texts.remove_at(idx)
			continue
		var wp: Vector3 = ft["pos"] + Vector3(0.0, (0.85 - rem) * 1.8, 0.0)
		if not cam.is_position_behind(wp):
			var sp: Vector2 = cam.unproject_position(wp)
			var fl := Label.new()
			fl.text = String(ft["text"])
			fl.position = sp - Vector2(30, 10)
			fl.add_theme_font_size_override("font_size", 16)
			fl.add_theme_color_override("font_color", Color(String(ft["color"])))
			overhead_container.add_child(fl)

func _on_floating_text(world_pos: Vector3, text: String, color_hex: String) -> void:
	floating_texts.append({
		"pos": world_pos,
		"text": text,
		"color": color_hex,
		"timer": 0.85
	})

func _on_gold_popup(world_pos: Vector3, amount: int) -> void:
	_on_floating_text(world_pos, "+%dg" % amount, "#facc15")

func _on_player_level_up(new_level: int) -> void:
	show_toast("LEVEL UP! You reached Lv.%d!" % new_level)

func _on_hero_killed(killer: CombatUnit, victim: CombatUnit, callout: String) -> void:
	var k_name: String = killer.hero_data.name if (killer != null and killer.hero_data != null) else "Turret"
	var v_name: String = victim.hero_data.name if (victim != null and victim.hero_data != null) else "Hero"
	hud_callout_banner.text = "%s\n[%s ⚔ %s]" % [callout.to_upper(), k_name, v_name]
	hud_callout_banner.visible = true
	hud_callout_timer = 3.2

func _on_announcer_callout(phrase: String) -> void:
	if not hud_callout_banner.visible:
		hud_callout_banner.text = phrase
		hud_callout_banner.visible = true
		hud_callout_timer = 2.8

func _on_match_ended(result: String) -> void:
	var lbl: Label = modal_match_end.get_node_or_null("ResultLabel") as Label
	if lbl != null:
		lbl.text = result + "!"
	modal_match_end.visible = true

