extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthContainer/HBox/HealthBar
@onready var health_label: Label = $HealthContainer/HBox/HealthLabel
@onready var blood_overlay: ColorRect = $BloodOverlay

const COLOR_GREEN  := Color(0.15, 0.80, 0.22, 1.0)
const COLOR_YELLOW := Color(0.90, 0.78, 0.10, 1.0)
const COLOR_RED    := Color(0.85, 0.12, 0.12, 1.0)

var bar_fill_style: StyleBoxFlat
var player: CharacterBody3D = null
var death_overlay: ColorRect = null
var death_label: Label = null
var restart_btn: Button = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

	bar_fill_style = health_bar.get_theme_stylebox("fill").duplicate()
	health_bar.add_theme_stylebox_override("fill", bar_fill_style)
	blood_overlay.color = Color(0.6, 0.0, 0.0, 0.0)

	_build_death_screen()
	_build_info_screen()

	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.player_died.connect(_on_player_died)
		player.player_won.connect(_on_player_won)
		health_bar.max_value = player.max_health
		health_bar.value = player.health
		_update_health_label(player.health, player.max_health)
		_update_bar_color(player.health, player.max_health)

func _build_death_screen():
	var font = load("res://fount/Font1/Ghastly Panic.ttf")

	# Full black overlay
	death_overlay = ColorRect.new()
	death_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	death_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	death_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(death_overlay)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 28)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	death_overlay.add_child(vbox)

	death_label = Label.new()
	death_label.text = "YOU DIED"
	death_label.add_theme_font_override("font", font)
	death_label.add_theme_font_size_override("font_size", 82)
	death_label.add_theme_color_override("font_color", Color(0.75, 0.08, 0.08, 1.0))
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.modulate.a = 0.0
	death_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(death_label)

	var sub_label = Label.new()
	sub_label.text = "the darkness claimed you"
	sub_label.add_theme_font_override("font", font)
	sub_label.add_theme_font_size_override("font_size", 22)
	sub_label.add_theme_color_override("font_color", Color(0.55, 0.42, 0.38, 0.85))
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.modulate.a = 0.0
	sub_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sub_label)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.10, 0.04, 0.04, 0.88)
	btn_style.border_width_left = 2
	btn_style.border_width_top = 2
	btn_style.border_width_right = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(0.45, 0.08, 0.08, 0.90)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_right = 4
	btn_style.corner_radius_bottom_left = 4

	restart_btn = Button.new()
	restart_btn.text = "Try Again"
	restart_btn.add_theme_font_override("font", font)
	restart_btn.add_theme_font_size_override("font_size", 26)
	restart_btn.add_theme_color_override("font_color", Color(0.85, 0.72, 0.68, 1.0))
	restart_btn.add_theme_stylebox_override("normal", btn_style)
	restart_btn.add_theme_stylebox_override("focus", btn_style)
	restart_btn.custom_minimum_size = Vector2(220, 58)
	restart_btn.modulate.a = 0.0
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)

	# Store sub_label ref for animation
	death_overlay.set_meta("sub_label", sub_label)
	death_overlay.visible = false

func _on_player_health_changed(new_health: float, max_health: float):
	var old_value = health_bar.value
	var tween = create_tween()
	tween.tween_property(health_bar, "value", new_health, 0.25)
	_update_health_label(new_health, max_health)
	_update_bar_color(new_health, max_health)
	if new_health < old_value:
		_show_blood_effect()

func _update_bar_color(current: float, maximum: float):
	var pct = current / maximum * 100.0
	var target_color: Color
	if pct > 60.0:
		target_color = COLOR_GREEN
	elif pct > 40.0:
		var t = (pct - 40.0) / 20.0
		target_color = COLOR_YELLOW.lerp(COLOR_GREEN, t)
	else:
		var t = pct / 40.0
		target_color = COLOR_RED.lerp(COLOR_YELLOW, t)
	var tween = create_tween()
	tween.tween_method(func(c: Color): bar_fill_style.bg_color = c,
		bar_fill_style.bg_color, target_color, 0.3)

func _update_health_label(current: float, maximum: float):
	health_label.text = "%d / %d" % [int(current), int(maximum)]

func _show_blood_effect():
	var tween = create_tween()
	tween.tween_property(blood_overlay, "color", Color(0.6, 0.0, 0.0, 0.55), 0.08)
	tween.tween_property(blood_overlay, "color", Color(0.6, 0.0, 0.0, 0.0), 0.6)

func _on_player_died():
	health_label.text = "0 / %d" % int(player.max_health if player else 100)
	health_bar.value = 0
	bar_fill_style.bg_color = COLOR_RED

	var sub_label: Label = death_overlay.get_meta("sub_label")
	death_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# 1. Blood fills screen
	var t1 = create_tween()
	t1.tween_property(blood_overlay, "color", Color(0.45, 0.0, 0.0, 0.88), 1.2)

	# 2. Black overlay fades in
	var t2 = create_tween()
	t2.tween_interval(0.8)
	t2.tween_property(death_overlay, "color", Color(0.0, 0.0, 0.0, 0.92), 1.0)

	# 3. YOU DIED fades in
	var t3 = create_tween()
	t3.tween_interval(1.6)
	t3.tween_property(death_label, "modulate:a", 1.0, 1.0)

	# 4. Subtitle fades in
	var t4 = create_tween()
	t4.tween_interval(2.4)
	t4.tween_property(sub_label, "modulate:a", 1.0, 0.8)

	# 5. Button fades in
	var t5 = create_tween()
	t5.tween_interval(3.2)
	t5.tween_property(restart_btn, "modulate:a", 1.0, 0.6)

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_player_won():
	health_bar.visible = false
	health_label.visible = false
	
	death_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	death_label.text = "YOU SURVIVED"
	death_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2, 1.0))
	var sub_label: Label = death_overlay.get_meta("sub_label")
	sub_label.text = "You have escaped the darkness..."
	restart_btn.visible = false
	
	var t2 = create_tween()
	t2.tween_property(death_overlay, "color", Color(0.0, 0.0, 0.0, 0.92), 1.0)
	
	var t3 = create_tween()
	t3.tween_interval(1.0)
	t3.tween_property(death_label, "modulate:a", 1.0, 1.0)
	
	var t4 = create_tween()
	t4.tween_interval(2.0)
	t4.tween_property(sub_label, "modulate:a", 1.0, 0.8)
	
	var t5 = create_tween()
	t5.tween_interval(4.5)
	t5.tween_callback(func():
		MultiplayerManager.set_meta("reverse_cutscene", true)
		get_tree().change_scene_to_file("res://cutscene/cutscene.tscn")
	)

var info_overlay: ColorRect = null

func _build_info_screen():
	var font = load("res://fount/Font1/Ghastly Panic.ttf")

	info_overlay = ColorRect.new()
	info_overlay.color = Color(0.0, 0.0, 0.0, 0.85)
	info_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	info_overlay.add_to_group("info_open")
	add_child(info_overlay)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	info_overlay.add_child(vbox)

	var title_label = Label.new()
	title_label.text = "HOW TO SURVIVE"
	if font:
		title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.add_theme_color_override("font_color", Color(0.82, 0.12, 0.12, 1.0))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	var controls_text = """
Objective: Survive as long as possible!

CONTROLS:
- WASD / Arrow Keys: Move
- Mouse: Look around
- Space: Jump
- L or F: Toggle Flashlight
- ESC: Pause Menu

TIPS:
- Stay out of enemy vision cones (they can only see what's in front of them).
- The faster you run, the harder it is to be caught, but watch your health.
- Use your flashlight wisely - darkness is terrifying, but light attracts attention!
"""
	var info_label = Label.new()
	info_label.text = controls_text
	info_label.add_theme_font_size_override("font_size", 24)
	info_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.8, 1.0))
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(info_label)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.10, 0.04, 0.04, 0.88)
	btn_style.border_width_left = 2
	btn_style.border_width_top = 2
	btn_style.border_width_right = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(0.45, 0.08, 0.08, 0.90)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_right = 4
	btn_style.corner_radius_bottom_left = 4

	var ok_btn = Button.new()
	ok_btn.text = "I Understand"
	ok_btn.add_theme_font_size_override("font_size", 28)
	ok_btn.add_theme_color_override("font_color", Color(0.85, 0.72, 0.68, 1.0))
	ok_btn.add_theme_stylebox_override("normal", btn_style)
	ok_btn.add_theme_stylebox_override("focus", btn_style)
	ok_btn.custom_minimum_size = Vector2(250, 60)
	ok_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ok_btn.pressed.connect(_on_info_ok_pressed)
	vbox.add_child(ok_btn)

	call_deferred("_show_info_screen")

func _show_info_screen():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_info_ok_pressed():
	if info_overlay:
		info_overlay.queue_free()
		info_overlay = null
	
	# Return to captured mouse if no other menus are open
	var pause_open = get_tree().get_first_node_in_group("pause_menu_open")
	var bag_open = get_tree().get_first_node_in_group("backpack_open")
	if not pause_open and not bag_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
