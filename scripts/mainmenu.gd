extends Control

@onready var fade_rect: ColorRect    = $CanvasLayer/FadeRect
@onready var title_label: Label      = $CenterContainer/Panel/VBox/TitleLabel
@onready var multi_panel: PanelContainer = $CenterContainer/Panel/VBox/MultiPanel

const FADE_TIME := 0.7
var next_scene := ""

func _ready():
	fade_rect.modulate.a = 1.0
	multi_panel.visible = false
	_fade_in()
	_flicker_title()

func _flicker_title():
	var tween = create_tween().set_loops()
	tween.tween_property(title_label, "theme_override_colors/font_color",
		Color(0.50, 0.06, 0.06, 1.0), 1.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(title_label, "theme_override_colors/font_color",
		Color(0.82, 0.12, 0.12, 1.0), 1.4).set_trans(Tween.TRANS_SINE)

func _fade_in():
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, FADE_TIME)

func _fade_out():
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, FADE_TIME)
	tween.finished.connect(_on_fade_finished)

# Solo play
func _on_start_pressed():
	next_scene = "res://scenes/world.tscn"
	_fade_out()

# Toggle multiplayer sub-panel
func _on_multi_pressed():
	multi_panel.visible = !multi_panel.visible

# Co-op mode selected
func _on_coop_pressed():
	var MM = get_node("/root/MultiplayerManager")
	MM.mode = MM.Mode.COOP
	next_scene = "res://scenes/lobby.tscn"
	_fade_out()

# Asymmetric mode selected
func _on_asym_pressed():
	var MM = get_node("/root/MultiplayerManager")
	MM.mode = MM.Mode.ASYMMETRIC
	next_scene = "res://scenes/lobby.tscn"
	_fade_out()

func _on_quit_pressed():
	next_scene = "quit"
	_fade_out()

func _on_fade_finished():
	if next_scene == "quit":
		get_tree().quit()
	else:
		get_tree().change_scene_to_file(next_scene)
