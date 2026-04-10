extends Control

@onready var dim_overlay: ColorRect = $DimOverlay
@onready var item_grid: GridContainer = $DimOverlay/CenterContainer/Panel/VBox/ItemGrid
@onready var empty_label: Label = $DimOverlay/CenterContainer/Panel/VBox/EmptyLabel

var player: CharacterBody3D = null
var is_open := false

var slot_style := StyleBoxFlat.new()
var slot_hover_style := StyleBoxFlat.new()

func _ready():
	player = get_tree().get_first_node_in_group("player")
	process_mode = Node.PROCESS_MODE_ALWAYS
	dim_overlay.visible = false

	slot_style.bg_color = Color(0.08, 0.04, 0.04, 0.82)
	slot_style.border_width_left = 1
	slot_style.border_width_top = 1
	slot_style.border_width_right = 1
	slot_style.border_width_bottom = 1
	slot_style.border_color = Color(0.30, 0.07, 0.07, 0.65)
	slot_style.corner_radius_top_left = 3
	slot_style.corner_radius_top_right = 3
	slot_style.corner_radius_bottom_right = 3
	slot_style.corner_radius_bottom_left = 3

	slot_hover_style.bg_color = Color(0.22, 0.06, 0.06, 0.95)
	slot_hover_style.border_width_left = 2
	slot_hover_style.border_width_top = 2
	slot_hover_style.border_width_right = 2
	slot_hover_style.border_width_bottom = 2
	slot_hover_style.border_color = Color(0.65, 0.12, 0.12, 1.0)
	slot_hover_style.corner_radius_top_left = 3
	slot_hover_style.corner_radius_top_right = 3
	slot_hover_style.corner_radius_bottom_right = 3
	slot_hover_style.corner_radius_bottom_left = 3

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			if is_open:
				_close()
			else:
				_open()

func _on_bag_button_pressed():
	if is_open:
		_close()
	else:
		_open()

func _on_close_pressed():
	_close()

func _open():
	is_open = true
	dim_overlay.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_rebuild_grid()

func _close():
	is_open = false
	dim_overlay.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _rebuild_grid():
	for child in item_grid.get_children():
		child.queue_free()

	if not player or player.inventory.is_empty():
		empty_label.visible = true
		return

	empty_label.visible = false
	for item in player.inventory:
		_add_item_slot(item)

func _add_item_slot(item: Dictionary):
	var font = load("res://fount/Font1/Ghastly Panic.ttf")

	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(122, 140)
	card.add_theme_stylebox_override("panel", slot_style.duplicate())

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	vbox.set("mouse_filter", Control.MOUSE_FILTER_IGNORE)
	card.add_child(vbox)

	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(64, 64)
	icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if item.get("icon", "") != "":
		icon_rect.texture = load(item["icon"])
	vbox.add_child(icon_rect)

	var name_label = Label.new()
	name_label.text = item.get("name", "Unknown")
	name_label.add_theme_font_override("font", font)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.85, 0.72, 0.66, 1.0))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	if item.get("quantity", 1) > 1:
		var qty_label = Label.new()
		qty_label.text = "x%d" % item["quantity"]
		qty_label.add_theme_font_size_override("font_size", 13)
		qty_label.add_theme_color_override("font_color", Color(0.55, 0.45, 0.40, 0.85))
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(qty_label)

	if item.get("usable", false):
		var use_btn = Button.new()
		use_btn.text = "Use"
		use_btn.add_theme_font_override("font", font)
		use_btn.add_theme_font_size_override("font_size", 14)
		use_btn.add_theme_color_override("font_color", Color(0.72, 0.90, 0.68, 1.0))
		use_btn.add_theme_color_override("font_hover_color", Color(0.90, 1.0, 0.86, 1.0))
		use_btn.add_theme_stylebox_override("normal", slot_style.duplicate())
		use_btn.add_theme_stylebox_override("hover", slot_hover_style.duplicate())
		use_btn.add_theme_stylebox_override("focus", slot_style.duplicate())
		use_btn.pressed.connect(_on_use_item.bind(item))
		vbox.add_child(use_btn)

	item_grid.add_child(card)

func _on_use_item(item: Dictionary):
	if not player:
		return
	player.use_item(item)
	_rebuild_grid()
