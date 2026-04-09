extends Control


signal resume_pressed
signal quit_pressed


@onready var panel: Panel = $Panel


func _ready():

	# Allow working while paused
	process_mode = Node.PROCESS_MODE_ALWAYS


	# ============================
	# PauseMenu → Full Rect
	# ============================

	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1

	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0


	# ============================
	# Panel → Center
	# ============================

	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5

	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -120
	panel.offset_bottom = 120



# ================= BUTTONS =================

func _on_resume_btn_pressed():
	emit_signal("resume_pressed")


func _on_quit_btn_pressed():
	emit_signal("quit_pressed")
