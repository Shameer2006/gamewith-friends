extends Control

@onready var mode_label: Label      = $CenterContainer/Panel/VBox/ModeLabel
@onready var ip_input: LineEdit     = $CenterContainer/Panel/VBox/IPBox/IPInput
@onready var status_label: Label    = $CenterContainer/Panel/VBox/StatusLabel
@onready var player_list: Label     = $CenterContainer/Panel/VBox/PlayerListLabel
@onready var start_btn: Button      = $CenterContainer/Panel/VBox/StartBtn
@onready var host_btn: Button       = $CenterContainer/Panel/VBox/HostBtn
@onready var join_btn: Button       = $CenterContainer/Panel/VBox/JoinBtn

var connected_players: Dictionary = {}

func _ready():
	var MM = get_node("/root/MultiplayerManager")
	mode_label.text = "Co-op Survival" if MM.mode == MM.Mode.COOP else "Asymmetric Horror"

	MM.player_connected.connect(_on_player_connected)
	MM.player_disconnected.connect(_on_player_disconnected)
	MM.connection_failed.connect(_on_connection_failed)
	MM.server_disconnected.connect(_on_server_disconnected)

func _on_host_pressed():
	var MM = get_node("/root/MultiplayerManager")
	if MM.host(MM.mode):
		status_label.text = "Hosting on port %d..." % MM.PORT
		host_btn.disabled = true
		join_btn.disabled = true
		connected_players[1] = "Host"
		_refresh_player_list()
		start_btn.visible = true

func _on_join_pressed():
	var MM = get_node("/root/MultiplayerManager")
	var ip = ip_input.text.strip_edges()
	if ip == "":
		ip = "127.0.0.1"
	if MM.join(ip, MM.mode):
		status_label.text = "Connecting to %s..." % ip
		host_btn.disabled = true
		join_btn.disabled = true

func _on_player_connected(id: int):
	connected_players[id] = "Player %d" % id
	_refresh_player_list()
	status_label.text = "Connected — %d player(s)" % connected_players.size()
	# Only host sees the start button
	if multiplayer.is_server():
		start_btn.visible = true

func _on_player_disconnected(id: int):
	connected_players.erase(id)
	_refresh_player_list()

func _on_connection_failed():
	status_label.text = "Connection failed. Check the IP and try again."
	host_btn.disabled = false
	join_btn.disabled = false

func _on_server_disconnected():
	status_label.text = "Host disconnected."
	get_node("/root/MultiplayerManager").disconnect_peer()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _refresh_player_list():
	var lines: Array = []
	for id in connected_players:
		lines.append(connected_players[id])
	player_list.text = "\n".join(lines) if lines.size() > 0 else "Waiting for players..."

func _on_start_pressed():
	if not multiplayer.is_server():
		return
	_load_game.rpc()

func _on_back_pressed():
	get_node("/root/MultiplayerManager").disconnect_peer()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

@rpc("authority", "call_local", "reliable")
func _load_game():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
