extends GutTest

var DemoScene = load("res://test/resources/input_recording_demo.tscn")

func test_demo_one():
	var inst = DemoScene.instantiate()
	add_child_autofree(inst)
	inst.input_recorder.play_recording("Do A Thing")
	await wait_for_signal(inst.input_recorder.playback_done, 10)
	pause_before_teardown()
