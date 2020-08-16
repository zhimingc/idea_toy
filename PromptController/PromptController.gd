extends Node2D

signal prompt_received(prompt)

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "on_request_completed")
	send_request()
	
func _process(_delta):
	#if Input.is_action_just_pressed("ui_accept"):
	#	send_request()
	pass

func send_request():
	$HTTPRequest.request("https://ineedaprompt.com/dictionary/default/prompt?q=verb")

func on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	# print(json.result["english"])
	if json.result != null:
		emit_signal("prompt_received", json.result["english"])
