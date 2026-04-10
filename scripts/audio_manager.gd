extends Node

@onready var background_music: AudioStreamPlayer = $BackgroundMusic

func _ready():
	# Wait a frame to ensure everything is loaded
	await get_tree().process_frame
	
	# Load and play background music
	var music_path = "res://music/background_music.mp3"
	
	print("Attempting to load music from: ", music_path)
	
	# Try to load the music
	if ResourceLoader.exists(music_path):
		var music_stream = ResourceLoader.load(music_path, "AudioStreamMP3")
		if music_stream:
			background_music.stream = music_stream
			background_music.volume_db = -5.0
			background_music.play()
			print("✓ Background music is now playing!")
		else:
			push_error("✗ Failed to load music stream")
	else:
		push_error("✗ Music file not found at: " + music_path)
		print("Please make sure the file exists in the music folder")

func set_music_volume(volume_db: float):
	if background_music:
		background_music.volume_db = volume_db

func stop_music():
	if background_music:
		background_music.stop()

func pause_music():
	if background_music:
		background_music.stream_paused = true

func resume_music():
	if background_music:
		background_music.stream_paused = false
