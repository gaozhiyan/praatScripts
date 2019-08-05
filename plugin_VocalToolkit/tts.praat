form Text to Speech (eSpeak)
	optionmenu Language 25
include tts_languages.inc
	optionmenu Voice 8
include tts_voices.inc
	positive Sampling_frequency_(Hz) 44100
	real Gap_between_words_(s) 0.01
	real Pitch_multiplier_(0.5-2.0) 1.0
	real Pitch_range_multiplier_(0-2.0) 1.0
	real Words_per_minute_(80-450) 175
	boolean Create_TextGrid_with_annotations 0
	comment Text:
	text str 1 2 3 4 5
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

s# = selected# ("Sound")
gap_between_words = min(max(gap_between_words, 0), 2)
pitch_multiplier = min(max(pitch_multiplier, 0.5), 2)
pitch_range_multiplier = min(max(pitch_range_multiplier, 0), 2)
words_per_minute = min(max(words_per_minute, 80), 450)

ss = Create SpeechSynthesizer: language$, voice$
Speech output settings: sampling_frequency, gap_between_words, pitch_multiplier, pitch_range_multiplier, words_per_minute, "IPA"

if play
	Play text: str$
	Remove
	selectObject: s#
else
	ss$ = selected$("SpeechSynthesizer")
	Rename: "tts_" + ss$
	noprogress To Sound: str$, create_TextGrid_with_annotations

	removeObject: ss

	if create_TextGrid_with_annotations
		tg = selected("TextGrid")
		result = selected("Sound")
		selectObject: result
		runScript: "declip.praat"
		plusObject: tg
		View & Edit
		selectObject: result
	else
		runScript: "declip.praat"
	endif
endif
