extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera3D

var fade_rect: ColorRect
var skipped := false

func _ready():
	# Make this camera the active one
	camera.make_current()

	# Build a full-screen fade overlay via a CanvasLayer
	var canvas = CanvasLayer.new()
	add_child(canvas)

	fade_rect = ColorRect.new()
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fade_rect)

	# Fade in from black
	var t = create_tween()
	t.tween_property(fade_rect, "color:a", 0.0, 0.8)
	t.finished.connect(_start_animation)

func _start_animation():
	if MultiplayerManager.has_meta("reverse_cutscene") and MultiplayerManager.get_meta("reverse_cutscene"):
		anim_player.play_backwards("entre cut scene")
	else:
		anim_player.play("entre cut scene")
	anim_player.animation_finished.connect(_on_animation_finished)

func _unhandled_input(event):
	# Any key or mouse click skips the cutscene
	if skipped:
		return
	var is_key   = event is InputEventKey and event.pressed and not event.echo
	var is_click = event is InputEventMouseButton and event.pressed
	if is_key or is_click:
		skipped = true
		anim_player.stop()
		_go_to_menu()

func _on_animation_finished(_anim_name: String):
	if not skipped:
		_go_to_menu()

func _go_to_menu():
	skipped = true
	var t = create_tween()
	t.tween_property(fade_rect, "color:a", 1.0, 0.7)
	if MultiplayerManager.has_meta("reverse_cutscene") and MultiplayerManager.get_meta("reverse_cutscene"):
		MultiplayerManager.set_meta("reverse_cutscene", false)
		t.finished.connect(func(): get_tree().quit())
	else:
		t.finished.connect(func(): get_tree().change_scene_to_file("res://scenes/mainmenu.tscn"))
