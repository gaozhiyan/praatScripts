sound = Create Sound as pure tone: "tone", 1, 0, 0.4, 44100, 220, 0.2, 0.01, 0.01
runScript: "../sound/to_pitch_two-pass.praat", 0.75, 1.5
assert numberOfSelected("Pitch") = 1
Remove

include ../procedures/pitch_two-pass.proc

selectObject: sound
@pitchTwoPass(0.75, 1.5)
assert numberOfSelected("Pitch") = 1
Remove

removeObject: sound
