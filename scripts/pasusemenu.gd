extends Control

@onready var audio_manager: Node = _find_audio_manager()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _find_audio_manager() -> Node:
	var nodes = get_tree().get_nodes_in_group("audio_manager")
	if nodes.size() > 0:
		return nodes[0]
	# fallback search
	return get_tree().root.find_child("AudioManager", true, false)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if visible:
			_resume()
		else:
			_pause()

func _pause():
	visible = true
	get_tree().paused = true
	add_to_group("pause_menu_open")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _resume():
	visible = false
	get_tree().paused = false
	remove_from_group("pause_menu_open")
	# Only recapture if backpack is also closed
	if get_tree().get_nodes_in_group("backpack_open").is_empty():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_btn_pressed():
	if audio_manager:
		audio_manager.resume_music()
	_resume()

func _on_quit_btn_pressed():
	if audio_manager:
		audio_manager.stop_music()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
