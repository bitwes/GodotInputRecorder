# Godot Input Recorder
I made a thing.  I have no idea if this is a good idea or not...but here it is.  Open up an issue and let me know what it needs to be useful.

This records input (via `_input(event)`).  Hit the record button and it will make a new recording.  Select a recording from the list and hit play and it will play a recording.  You can even play recordings from code, see the example at the end.

You can set the filename it will use to save/load in the editor.  If you don't set it, it will save in the same directory as the scene it is in, with a name of `<whatever the scene is called>_input_recording.cfg`.  This was done because I thought it would be helpful and lead to less configuring and remembering of paths.  It's either really smart, or "too smart".

Find `IR_InputRecorderControl` in the in-editor help for more information.

# The Vision
I was messing around with the various `GutInputSender` methods and I thought..."hey, what if you could just record the input and use that in a test?".  So I made this.  The idea is that you would create a scene with limited scope for integration tests.  You'd add an `InputRecorder`, record some input, then run the recordings in your test and make some assertions.  There's an example of using it below.

This doesn't have to be the way you use it.  Doowutchyalike.  Let me know how it's going.




# How it works
This could end up being a bad way to do it...but this is what it does.
* When you hit record, it will record all input that comes into the `_input(event)` method on the recorder.  It will record the frame count (since starting the recording) and all input that comes in on that frame.  Only frames where input is received are recorded.
* When you playback it will increase a counter in `_physics_process` and if it has input for that frame, it will send it to `Input.parse_event`.


## Why would this not be the best idea ever?
Some, or all of these things are probably true.

* There could be some issues with input being swallowed before the recorder can get to it.
* It is very dependant on the physics ticks per second remaining the same for the whole run (which it should).
* It does not account for elapsed time...at all.  It just counts frames and sends events it received.
    * If you increase the physics ticks per second you will get different results than the original recording.
    * If you lower the physics ticks per second you might get the same results but it takes more time to run.




# Install
1.  Add the addons/input_recorder folder to your project.
1.  Enable the plugin
1.  Add an `IR_InputRecorderControl` control to your scene with the + button.





# Using
1.  Create your test scene with all your testable items.
1.  Add an `IR_InputRecorderControl` to your scene.
1.  Run the scene.
1.  Hit the record button
1.  Move the mouse around, drag/drop, type, and other input things.
1.  Click the stop button.
1.  Click the play button.
1.  Rinse and repeat.




# Using in a test (GUT example):
```gdscript
extends GutTest

# This scene has:
#   - a player object named gut_player
#   - an IR_InputRecorderControl instance named input_recorder that has
#     a recording named "Do A Thing".
var DemoScene = load("res://test/resources/input_recording_demo.tscn")

func test_demo_one():
	# autoqfree b/c loaded recordings have to be queued free
	# if we don't "q" here it lists orphans for the test but
	# not for the script (since they are eventually freed).
	var inst = add_child_autoqfree(DemoScene.instantiate())

	var orig_pos = inst.gut_player.global_position

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
```