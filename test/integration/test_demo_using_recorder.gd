extends GutTest

var DemoScene = load("res://test/resources/input_recording_demo.tscn")

func test_demo_one():
	var inst = DemoScene.instantiate()
	add_child_autofree(inst)
	var orig_pos = inst.gut_player.global_position
	inst.input_recorder.play_recording("Do A Thing")
	await wait_for_signal(inst.input_recorder.playback_done, 10)
	assert_ne(inst.gut_player.global_position, orig_pos, "playing input moved the player")
	
