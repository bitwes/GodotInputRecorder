extends GutTest

# This scene has:
#   - a Character2D object named the_character
#   - an InputRecorder instance named input_recorder that has
#     a recording named "Do A Thing".
var DemoScene = load("res://test/resources/input_recording_demo.tscn")


func test_demo_one():
	# autoqfree b/c loaded recordings have to be queued free
	# if we don't "q" here it lists orphans for the test but
	# not for the script (since they are eventually freed).
	var inst = add_child_autoqfree(DemoScene.instantiate())

	var orig_pos = inst.the_character.global_position

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

	assert_ne(inst.the_character.global_position, orig_pos, "playing input moved the player")








# ------------------------------------------------------------------------------
# This is a more complicated example, where I'm trying to check if the player
# jumps while typing in one of the input boxes.  This required monitoring the
# velocity over time, so I made a generic thing to monitor properties.  This 
# might be useful.  Maybe different types of monitors, like min/max, all_values
# (which is what this currently does), average, set the sampling time/frame rate 
# (instead of every frame), sample during physics_process instead, and much 
# much? more?
# 
# Add callables to be called every frame?
# -- or maybe --
# Should GUT get a callable you can set in-test that will be called while 
# awaiting?  
# 	during_process = func(): pass
#	during_physics_process = func(): pass
# You could just implement a _physics_process in your test, but then you have to
# have more class level vars and that is gross.  This would get cleared out 
# between each test.
# ------------------------------------------------------------------------------
class PropertyMonitor:
	extends Node
	
	var _monitors = {}
	
	func _process(_delta):
		for obj in _monitors:
			for prop in _monitors[obj]:
				_monitors[obj][prop].append(obj.get(prop))
	
	func monitor(obj, prop):
		if(!_monitors.has(obj)):
			_monitors[obj] = {}
		_monitors[obj][prop] = []
	
	func get_values(obj, prop):
		return _monitors[obj][prop]


func test_typing_in_box_does_not_cause_player_to_jump():
	var inst = add_child_autoqfree(DemoScene.instantiate())
	
	var prop_monitor = add_child_autofree(PropertyMonitor.new())
	prop_monitor.monitor(inst.the_character, 'velocity')
	
	inst.input_recorder.play_recording("Jump Typing")
	await wait_for_signal(inst.input_recorder.playback_done, inst.input_recorder.get_playback_time() + 1.0)
	
	var num_above = prop_monitor.get_values(inst.the_character, 'velocity')\
						.filter(func(v): return v.y < 0.0)\
						.size()
	assert_eq(num_above, 0, 'none should be below zero')
