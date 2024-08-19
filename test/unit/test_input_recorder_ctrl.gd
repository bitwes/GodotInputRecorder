extends GutTest


func test_can_make_one():
	var ctrl = autofree(IR_InputRecorderControl.new())
	assert_not_null(ctrl)

func test_does_not_blow_up_running_missing_recording():
	var ctrl = add_child_autofree(IR_InputRecorderControl.new())
	ctrl.play_recording("missing")
	pass_test("we got here")
