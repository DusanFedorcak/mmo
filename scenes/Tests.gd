extends Node


onready var test_cases = {	
	run_local_game = [
		SwitchFullScreen.new(),
		ClickStartAndJoin.new(),
		ClickStartGame.new()
	]
}


func _unhandled_input(_event):		
	if _event.is_action_pressed("debug_run_local"):
		_run_test("run_local_game")
		
	if _event.is_action_pressed("debug_trigger_test"):					
		$"../Map/UI".player.get_node("AI")._test()
		
	if _event.is_action_pressed("debug_resurrect"):					
		$"../Map/UI".player.resurrect()
		
			

class ClickStartAndJoin:
	func valid(world):
		return world.get_node("UI/MainMenu").visible
	
	func perform(world):				
		world.get_node("UI/MainMenu/Menu/VBox/Localgame").emit_signal("pressed")
		
	
class ClickStartGame:
	func valid(world):
		return world.get_node("UI/MainMenu/ServerInfo").visible
	
	func perform(world):				
		world.get_node("UI/MainMenu/ServerInfo/VBox/HBox/StartGame").emit_signal("pressed")
		
class SwitchFullScreen:
	func valid(world):
		return true
	
	func perform(world):				
		OS.window_fullscreen = !OS.window_fullscreen
		
var current_test = null
var action_index = -1

func _run_action():	
	if current_test:
		var actions = test_cases[current_test]
		if actions[action_index].valid(get_parent()):			
			actions[action_index].perform(get_parent())
			action_index += 1
			if action_index == len(actions):				
				Log.info("Test case finished: %s" % current_test)
				current_test = null
				

func _run_test(test_name: String):
	if test_name in test_cases:
		current_test = test_name
		action_index = 0	
		Log.info("Running test case: %s" % test_name)
	
	
func _process(delta):
	_run_action()
