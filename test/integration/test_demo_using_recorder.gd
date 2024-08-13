extends GutTest

var DemoScene = load("res://test/resources/input_recording_demo.tscn")

func test_demo_one():
	# autoqfree b/c loaded recordings have to be queued free
	# if we don't "q" here it lists orphans for the test but
	# not for the script (since they are eventually freed).
	var inst = add_child_autoqfree(DemoScene.instantiate())
	
	var orig_pos = inst.gut_player.global_position
	inst.input_recorder.play_recording("Do A Thing")
	assert_true(await wait_for_signal(
		inst.input_recorder.playback_done, 
		inst.input_recorder.get_playback_time() + 1.0),
		'playback finished')

	assert_ne(inst.gut_player.global_position, orig_pos, "playing input moved the player")


func test_nothing():
	pass_test('passing')
