# API
This is how the user would interact with this thing.


## Classes

* IR_Recorder
* IR_PLayer
* IR_Recording
* IR_InputRecorderControl

### IR_InputRecorderControl
The GUI for all this stuff.  You should be able to use this without having to know anything about the other classes.

### IR_Recorder
Does all the recording.  Creates an instance of `IR_Recording`.

### IR_Player
Playback `IR_Recording` data.

### IR_Recording
Data structure for recorded input



# Scenes

## input_recorder_controls
Holds all the different controls together as one control that switches states.  The plugin class creates an instance of this.

## play_control
The UI for playing a recording.


## recording_details
List of all recording entries, allows enabling/disabling individual entries.


## recording_entry
A single recording display.


## recording_list
A list of all the recordings in a file or that have been created.  A list of `recording_entry` scenes.


## record_control
The UI for recording input.


## Basically this
- input_recorder_controls
    - play_control
    - record_control
    - Tabs
        - recording_list
            - recording_entry
        - recording_details