extends Control

func _ready():
	$Prompt.text = ""

func _on_PromptController_prompt_received(prompt):
	$Prompt.text = prompt
