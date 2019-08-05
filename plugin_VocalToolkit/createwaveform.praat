# Parts of this script were adapted from scripts by Ingmar Steiner included in "Automatic Speech Data Processing with Praat", http://www.coli.uni-saarland.de/~steiner/teaching/2006/winter/praat/lecturenotes.pdf
# and from scripts by David Weenink included in "Speech Signal Processing with Praat", http://www.fon.hum.uva.nl/david/sspbook/sspbook.pdf

form Create waveform
	positive Duration_(s) 1.0
	positive Sampling_frequency_(Hz) 44100
	positive Frequency_(Hz) 130.81
	positive Amplitude_(Pa) 0.2
	real Fade_in_and_out_(s) 0.01
	boolean Stereo_ 0
	optionmenu Type 1
		option Pulse train
		option Sawtooth
		option Silence
		option Sine
		option Square
		option Triangle
		option Hum
		option Phonation
		option White noise
		option Pink noise
		option Brown noise
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

s# = selected# ("Sound")
duration = min(max(duration, 0.1), 10)
amplitude = min(max(amplitude, 0.01), 1)
fade = min(max(fade_in_and_out, 0), duration / 2)
nch = stereo_ + 1

if type < 7
	p = 1 / frequency
endif

if type = 1
	Create Sound from formula: "Pulse_train", nch, 0, duration, sampling_frequency, "if x mod p < 1 / sampling_frequency then amplitude else 0 fi"
endif

if type = 2
	Create Sound from formula: "Sawtooth", nch, 0, duration, sampling_frequency, "2 * amplitude / p * ((x + p / 2) mod p - p / 2)"
endif

if type = 3
	Create Sound from formula: "Silence", nch, 0, duration, sampling_frequency, "0"
endif

if type = 4
	Create Sound from formula: "Sine", nch, 0, duration, sampling_frequency, "amplitude * sin(2 * pi * frequency * x)"
endif

if type = 5
	Create Sound from formula: "Square", nch, 0, duration, sampling_frequency, "if x mod p <= p / 2 then amplitude else -amplitude fi"
endif

if type = 6
	Create Sound from formula: "Triangle", nch, 0, duration, sampling_frequency, "amplitude * (4 / p * abs((x + 3 * p / 4) mod p - p / 2) - 1)"
endif

if type = 7
	pitchtier = Create PitchTier: "tmp", 0, duration
	Add point: duration / 2, frequency
	To Sound (pulse train): sampling_frequency, 1, 0.05, 2000, "yes"
	if stereo_
		tmp = selected("Sound")
		Convert to stereo
		removeObject: tmp
	endif
	Scale peak: amplitude
	Rename: "Hum"
	removeObject: pitchtier
endif

if type = 8
	pitchtier = Create PitchTier: "tmp", 0, duration
	Add point: duration / 2, frequency
	To Sound (phonation): sampling_frequency, 1, 0.05, 0.7, 0.03, 3, 4, "no"
	if stereo_
		tmp = selected("Sound")
		Convert to stereo
		removeObject: tmp
	endif
	Scale peak: amplitude
	Rename: "Phonation"
	removeObject: pitchtier
endif

if type = 9
	Create Sound from formula: "White_noise", nch, 0, duration, sampling_frequency, "randomUniform(-amplitude, amplitude)"
endif

if type = 10
	tmp1 = Create Sound from formula: "tmp", nch, 0, duration, sampling_frequency, "randomUniform(-amplitude, amplitude)"
	if nch = 1
		sp = To Spectrum: "yes"
		Formula: "if x > 100 then self * sqrt(100 / x) else 0 fi"
		tmp2 = To Sound
		Extract part: 0, duration, "rectangular", 1, "no"
		removeObject: tmp1, sp, tmp2
	elsif nch = 2
		Extract all channels
		ch[1] = selected("Sound")
		ch[2] = selected("Sound", 2)
		for i to 2
			selectObject: ch[i]
			sp[i] = To Spectrum: "yes"
			Formula: "if x > 100 then self * sqrt(100 / x) else 0 fi"
			ch_tmp[i] = To Sound
		endfor
		selectObject: ch_tmp[1], ch_tmp[2]
		tmp2 = Combine to stereo
		Extract part: 0, duration, "rectangular", 1, "no"
		removeObject: tmp1, ch[1], ch[2], sp[1], ch_tmp[1], sp[2], ch_tmp[2], tmp2
	endif
	Scale peak: amplitude
	Rename: "Pink_noise"
endif

if type = 11
	Create Sound from formula: "Brown_noise", nch, 0, duration, sampling_frequency, "randomUniform(-amplitude, amplitude)"
	De-emphasize (in-place): 5
	Scale peak: amplitude
endif

if fade > 0
	Fade in: 0, 0, fade, "yes"
	Fade out: 0, duration, -fade, "yes"
endif

runScript: "declip.praat"

if play
	if type <> 3
		Play
	endif
	Remove
	selectObject: s#
endif
