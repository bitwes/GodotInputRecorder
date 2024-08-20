extends GutTest


func test_can_make_one():
	var ctrl = autofree(IR_InputRecorderControl.new())
	assert_not_null(ctrl)

func test_does_not_blow_up_running_missing_recording():
	var ctrl = add_child_autofree(IR_InputRecorderControl.new())
	ctrl.play_recording("missing")
	pass_test("we got here")
	
func test_setting_warp_mouse_false_unchecks_option_when_ready():
	var ctrl = IR_InputRecorderControl.new()
	ctrl.warp_mouse = false
	add_child_autofree(ctrl)
	assert_false(ctrl._controls.chk_warp_mouse.button_pressed)
	
func test_setting_record_mouse_false_unchecks_option_when_ready():
	var ctrl = IR_InputRecorderControl.new()
	ctrl.record_mouse = false
	add_child_autofree(ctrl)
	assert_false(ctrl._controls.chk_record_mouse.button_pressed)
