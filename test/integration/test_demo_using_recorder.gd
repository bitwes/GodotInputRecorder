extends GutTest

# This scene has:
#   - a player object named gut_player
#   - an InputRecorder instance named input_recorder that has
#     a recording named "Do A Thing".
var DemoScene = load("res://test/resources/input_recording_demo.tscn")

func test_demo_one():
	# autoqfree b/c loaded recordings have to be queued free
	# if we don't "q" here it lists orphans for the test but
	# not for the script (since they are eventually freed).
	var inst = add_child_autoqfree(DemoScene.instantiate())

	var orig_pos = inst.gut_player.global_position

	# This assumes that the scene has exposed its InputRecorder as
	# "input_recorder"
	inst.input_recorder.play_recording("Do A Thing")

	# Wait for the playback of input to finish, with an added assert to make
	# sure that the playback finished.  wait_for_signal returns true if the
	# signal was emitted before the timeout.
	assert_true(await wait_for_signal(
		inst.input_recorder.playback_done,
		# Add a second to the time to wait or the signal will not be
		# emitted in time.
		inst.input_recorder.get_playback_time() + 1.0),
		'playback finished')

	assert_ne(inst.gut_player.global_position, orig_pos, "playing input moved the player")

func test_nothing():
	pass_test('passing')
