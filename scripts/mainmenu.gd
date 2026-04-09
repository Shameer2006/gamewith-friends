extends Control


@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect


const FADE_TIME := 0.8
var next_scene := ""


func _ready():

	# Set ColorRect properties in code
	fade_rect.color = Color.BLACK
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	fade_rect.anchor_left = 0
	fade_rect.anchor_top = 0
	fade_rect.anchor_right = 1
	fade_rect.anchor_bottom = 1

	fade_rect.offset_left = 0
	fade_rect.offset_top = 0
	fade_rect.offset_right = 0
	fade_rect.offset_bottom = 0


	# Start with black screen
	fade_rect.modulate.a = 1.0

	# Fade IN when menu opens
	_fade_in()


# ================= FADE =================

func _fade_in():

	var tween = create_tween()
	tween.tween_property(
		fade_rect,
		"modulate:a",
		0.0,
		FADE_TIME
	)


func _fade_out():

	var tween = create_tween()
	tween.tween_property(
		fade_rect,
		"modulate:a",
		1.0,
		FADE_TIME
	)

	tween.finished.connect(_on_fade_finished)


# ================= BUTTONS =================

func _on_start_pressed():

	next_scene = "res://scenes/world.tscn"
	_fade_out()


func _on_quit_pressed():

	next_scene = "quit"
	_fade_out()


# ================= CHANGE =================

func _on_fade_finished():

	if next_scene == "quit":
		get_tree().quit()
	else:
		get_tree().change_scene_to_file(next_scene)
