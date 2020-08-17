extends Node

enum SESSION { READY, RUNNING, END }

var session_state = SESSION.READY
var timerText
var promptText
var entryField

var num_rounds = 5
var current_round = 0

# save feature
var save_game
var save_file_name 
var save_prefix = "res://"
var save_suffix = ".json"

func _ready():
	timerText = $SessionCanvas/Timer
	promptText = $SessionCanvas/Prompt
	entryField = $SessionCanvas/TextEdit
	update_num_rounds()
	
func _process(_delta):
	timerText.text = String(int(round($Round_Timer.time_left)))
	
	# quitting
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	match(session_state):
		SESSION.READY:
			if Input.is_action_just_pressed("ui_select"):
				start_session()
			if Input.is_action_just_pressed("ui_up"):
				num_rounds += 1
				update_num_rounds()
			if Input.is_action_just_pressed("ui_down"):
				num_rounds -= 1
				update_num_rounds()
		SESSION.RUNNING:
			if Input.is_action_just_pressed("ui_accept"):
				next_round()
		SESSION.END:
			if Input.is_action_just_pressed("ui_select"):
				back_to_ready()

func next_round():
	save_entry()		
	entryField.text = ""
	$PromptController.send_request()
	current_round -= 1
	if current_round == 0:
		end_session()

func back_to_ready():
	session_state = SESSION.READY
	$EndSession.visible = false
	$PreSessionCanvas.visible = true

func end_session():
	session_state = SESSION.END
	$SessionCanvas.visible = false
	$EndSession.visible = true
	$EndSession/SaveLoc.text = "session saved in: " + get_save_name()

func start_session():
	session_state = SESSION.RUNNING
	entryField.grab_focus()
	$PromptController.send_request()
	$SessionCanvas.visible = true
	$PreSessionCanvas.visible = false
	$Round_Timer.start(30.0)
	create_save()
	current_round = num_rounds

func save_entry():
	if save_file_name == null:
		return
	var save_data = {
		"prompt" : promptText.text,
		"entry" : entryField.text.trim_suffix("\n")
	}
	var flag = save_game.open(get_save_name(), File.READ_WRITE)
	save_game.seek_end()
	save_game.store_line(to_json(save_data))
	save_game.close()	
	
func create_save():
	save_game = File.new()
	var date_time = OS.get_datetime()
	var date = String(date_time["day"]) + String(date_time["month"]).pad_zeros(2) + String(date_time["year"]).substr(2, 2)
	save_file_name = date + "_0"
	var file_exists = save_game.file_exists(get_save_name())
	var i = 1
	while file_exists:
		save_file_name = date + "_" + String(i)
		file_exists = save_game.file_exists(get_save_name())
		i += 1
	save_game.open(get_save_name(), File.WRITE)
	save_game.close()
	
func get_save_name():
	if OS.has_feature("editor"):
		return save_prefix + save_file_name + save_suffix
	else:
		return OS.get_executable_path().get_base_dir() + "\\" + save_file_name + save_suffix

func update_num_rounds():
	num_rounds = clamp(num_rounds, 1, 25)	
	$PreSessionCanvas/Rounds.text = "rounds: " + String(num_rounds)

func _on_PromptController_prompt_received(_prompt):
	$Round_Timer.start(30.0)
