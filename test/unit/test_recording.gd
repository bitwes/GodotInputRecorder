extends GutTest


func test_can_make_one():
	var rec := IR_Recording.new()
	assert_not_null(rec)


func test_can_load_old_file():
	var rec := IR_Recording.new()
	var cf := ConfigFile.new()
	cf.set_value("section", "recordings", {
		10:[InputEventMouseMotion.new(), InputEventKey.new()],
		20:[InputEventAction.new()]
	})
	rec.load_config_file_section(cf, "section")
	assert_has(rec.queue, 10, 'has entry for frame 10')
	assert_has(rec.queue, 20, 'has entry for frame 20')
	assert_typeof(rec.queue[10], TYPE_DICTIONARY)
	assert_has(rec.queue[10], 'events')
	assert_has(rec.queue[10], 'disabled')


func test_add_adds_an_entry():
	var rec := IR_Recording.new()
	rec.add_event(5, InputEventKey.new())
	assert_eq(rec.queue[5].events.size(), 1)
	assert_eq(rec.queue[5].disabled, false)


func test_add_appends_event_to_array():
	var rec := IR_Recording.new()
	rec.add_event(5, InputEventKey.new())
	rec.add_event(5, InputEventAction.new())
	assert_eq(rec.queue[5].events.size(), 2)
	assert_is(rec.queue[5].events[1], InputEventAction)


func test_save_saves_queue():
	var rec := IR_Recording.new()
	rec.add_event(5, InputEventKey.new())
	rec.add_event(5, InputEventAction.new())
	rec.add_event(10, InputEventMouseMotion.new())
	rec.add_event(15, InputEventMouseButton.new())

	var cf = ConfigFile.new()
	rec.save_config_file_section(cf, "section")

	assert_not_null(cf.get_value("section", "input_recording"))
	var saved = cf.get_value("section", "input_recording")
	assert_eq(saved.size(), 3, 'size of recordings')


func test_load_loads_queue():
	var rec := IR_Recording.new()
	rec.add_event(5, InputEventKey.new())
	rec.add_event(5, InputEventAction.new())
	rec.add_event(10, InputEventMouseMotion.new())
	rec.add_event(15, InputEventMouseButton.new())

	var cf = ConfigFile.new()
	rec.save_config_file_section(cf, "section")

	var loaded = IR_Recording.new()
	loaded.load_config_file_section(cf, "section")

	assert_eq(loaded.queue.size(), 3, 'size of recordings')


func test_get_frame_events_returns_data_for_frame():
	var rec := IR_Recording.new()
	rec.add_event(5, InputEventKey.new())
	rec.add_event(5, InputEventAction.new())

	assert_eq(rec.get_frame_events(5).size(), 2)


func test_get_frame_events_returns_empty_for_missing_frames():
	var rec := IR_Recording.new()
	assert_eq(rec.get_frame_events(37), [])


func test_get_enabled_frame_events_returns_data_when_enabled():
	var rec := IR_Recording.new()
	rec.add_event(5, InputEventKey.new())
	rec.add_event(5, InputEventAction.new())

	assert_eq(rec.get_enabled_frame_events(5).size(), 2)

func test_get_enabled_frame_events_returns_empty_list_when_disabled():
	var rec := IR_Recording.new()
	rec.add_event(5, InputEventKey.new())
	rec.add_event(5, InputEventAction.new())
	rec.queue[5].disabled = true

	assert_eq(rec.get_enabled_frame_events(5), [])


func test_disable_frame_disables_a_frame():
	var rec := IR_Recording.new()
	rec.add_event(93, InputEventKey.new())
	rec.add_event(93, InputEventAction.new())
	rec.disable_frame(93, true)

	assert_true(rec.queue[93].disabled)

func test_disable_frame_does_nothing_if_frame_does_not_exist():
	var rec := IR_Recording.new()
	rec.disable_frame(93, true)
	pass_test('we got here')
