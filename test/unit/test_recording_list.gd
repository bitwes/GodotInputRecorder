extends GutTest

var RecordingsTree = load("res://addons/input_recorder/recording_list.tscn")

func test_can_make_one():
	var rt = RecordingsTree.instantiate()
	assert_not_null(rt)
	rt.free()

func test_adding_recorder_creates_one_with_expected_name():
	var rt = add_child_autofree(RecordingsTree.instantiate())
	rt.new_recorder()
	assert_has(rt.input_recorders, "Recording 1")

func test_changing_recording_name_changes_generated_names():
	var rt = add_child_autofree(RecordingsTree.instantiate())
	rt.recording_name = "Foo"
	rt.new_recorder()
	assert_has(rt.input_recorders, "Foo1")

