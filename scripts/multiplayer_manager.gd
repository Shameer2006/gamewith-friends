extends Node

enum Mode { NONE, COOP, ASYMMETRIC }

var mode: Mode = Mode.NONE
var is_host: bool = false
var peer: ENetMultiplayerPeer = null
const PORT := 7777
const MAX_COOP_PLAYERS := 4
const MAX_ASYM_PLAYERS := 2

signal player_connected(id: int)
signal player_disconnected(id: int)
signal connection_failed
signal server_disconnected

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host(selected_mode: Mode):
	mode = selected_mode
	is_host = true
	peer = ENetMultiplayerPeer.new()
	var max_clients = MAX_COOP_PLAYERS if mode == Mode.COOP else MAX_ASYM_PLAYERS
	var err = peer.create_server(PORT, max_clients)
	if err != OK:
		push_error("Failed to create server: " + str(err))
		return false
	multiplayer.multiplayer_peer = peer
	return true

func join(ip: String, selected_mode: Mode):
	mode = selected_mode
	is_host = false
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, PORT)
	if err != OK:
		push_error("Failed to connect: " + str(err))
		return false
	multiplayer.multiplayer_peer = peer
	return true

func disconnect_peer():
	if peer:
		peer.close()
	multiplayer.multiplayer_peer = null
	peer = null
	mode = Mode.NONE
	is_host = false

func _on_peer_connected(id: int):
	player_connected.emit(id)

func _on_peer_disconnected(id: int):
	player_disconnected.emit(id)

func _on_connected_to_server():
	player_connected.emit(multiplayer.get_unique_id())

func _on_connection_failed():
	connection_failed.emit()

func _on_server_disconnected():
	server_disconnected.emit()
