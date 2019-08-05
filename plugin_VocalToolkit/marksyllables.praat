# This script is adapted from "Praat Script Syllable Nuclei v2" by Nivja de Jong and Ton Wempe: https://sites.google.com/site/speechrate/
# de Jong, N.H. & Wempe, T. Behavior Research Methods (2009) 41: 385. https://doi.org/10.3758/BRM.41.2.385

form Mark regions by syllables
	real Silence_threshold_(dB) -25
	positive Minimum_pause_duration_(s) 0.3
	positive Minimum_dip_between_peaks_(dB) 2
	boolean Show_speech_rate_info 1
	boolean Trim_initial_and_final_silences 1
endform

if silence_threshold >= 0
	exitScript: "“Silence threshold” should be a negative number."
endif

if show_speech_rate_info
	appendInfoLine: newline$, "Mark regions by syllables..."
endif

include batch.praat

if show_speech_rate_info
	appendInfoLine: tab$, "Adapted from ""Praat Script Syllable Nuclei v2"", by Nivja de Jong and Ton Wempe: https://sites.google.com/site/speechrate/"
	appendInfoLine: tab$, "de Jong, N.H. & Wempe, T. Behavior Research Methods (2009) 41: 385. https://doi.org/10.3758/BRM.41.2.385"
endif

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	dur = Get total duration

	if show_speech_rate_info
		appendInfoLine: tab$, s, ". Sound ", s$
	endif

	int = Get intensity (dB)

	if int <> undefined
		if trim_initial_and_final_silences
			trimmed_tmp = nowarn nocheck Trim silences: 0.08, "yes", 100, 0, -35, 0.1, 0.05, "no", "trimmed"
			if trimmed_tmp = s
				result = Copy: s$ + "-marksyllables"
			else
				result = Rename: s$ + "-marksyllables"
			endif
			dur = Get total duration
			stt = Get start time
			if stt <> 0
				Scale times to: 0, dur
			endif
		else
			result = Copy: s$ + "-marksyllables"
		endif

		runScript: "fixdc.praat"
		intensity = noprogress To Intensity: 50, 0, "no"

		minint = Get minimum: 0, 0, "Parabolic"
		maxint = Get maximum: 0, 0, "Parabolic"
		max99int = Get quantile: 0, 0, 0.99

		threshold = max(max99int + silence_threshold, minint)
		threshold2 = maxint - max99int
		threshold3 = silence_threshold - threshold2

		tg = noprogress To TextGrid (silences): threshold3, minimum_pause_duration, 0.1, "pause", ""
		Rename: s$ + "-marksyllables"
		Set tier name: 1, "syllables"

		selectObject: intensity
		intensitytier = noprogress To IntensityTier (peaks)
		npoints = Get number of points
		peakcount = 0
		int[1] = 0
		for i to npoints
			db = Get value at index: i
			if db > threshold
				peakcount += 1
				int[peakcount] = db
				timepeaks[peakcount] = Get time from index: i
			endif
		endfor
		timepeaks[peakcount + 1] = dur

		selectObject: intensity
		validpeakcount = 0
		currenttime = timepeaks[1]
		currentint = int[1]
		for p to peakcount
			dip = Get minimum: currenttime, timepeaks[p + 1], "None"
			diffint = abs(currentint - dip)
			if diffint > minimum_dip_between_peaks
				validpeakcount += 1
				validtime[validpeakcount] = timepeaks[p]
			endif
			currenttime = timepeaks[p + 1]
			currentint = Get value at time: timepeaks[p + 1], "Cubic"
		endfor

		selectObject: result
		pitch = noprogress To Pitch (ac): 0.02, 30, 4, "no", 0.03, 0.25, 0.01, 0.35, 0.25, 450
		for i to validpeakcount
			pvalue[i] = Get value at time: validtime[i], "Hertz", "Linear"
		endfor

		selectObject: tg
		voicedcount = 0
		for i to validpeakcount
			whichinterval = Get interval at time: 1, validtime[i]
			whichlabel$ = Get label of interval: 1, whichinterval
			if pvalue[i] <> undefined
				if whichlabel$ <> "pause"
					voicedcount += 1
					voicedpeak[voicedcount] = validtime[i]
				endif
			endif
		endfor

		Insert point tier: 1, "peaks"
		for i to voicedcount
			Insert point: 1, voicedpeak[i], string$(i)
		endfor

		selectObject: intensity
		for i from 2 to voicedcount
			mintime[i] =  Get time of minimum: voicedpeak[i - 1], voicedpeak[i], "None"
		endfor

		selectObject: tg
		for i from 2 to voicedcount
			whichinterval = Get interval at time: 2, mintime[i]
			whichlabel$ = Get label of interval: 2, whichinterval
			if whichlabel$ <> "pause"
				Insert boundary: 2, mintime[i]
			endif
		endfor

		if show_speech_rate_info
			npauses = Count intervals where: 2, "is equal to", "pause"
			phonation_time = Get total duration of intervals where: 2, "is not equal to", "pause"
			speech_rate = voicedcount / dur
			articulation_rate = voicedcount / phonation_time
			asd = phonation_time / voicedcount
			appendInfoLine: tab$, tab$, "Number of syllables: ", voicedcount
			appendInfoLine: tab$, tab$, "Number of pauses: ", npauses
			appendInfoLine: tab$, tab$, "Total duration: ", number(fixed$(dur, 6)), " seconds"
			appendInfoLine: tab$, tab$, "Phonation time: ", number(fixed$(phonation_time, 3)), " seconds"
			appendInfoLine: tab$, tab$, "Speech rate (number of syllables / total duration): ", number(fixed$(speech_rate, 2))
			appendInfoLine: tab$, tab$, "Articulation rate (number of syllables / phonation time): ", number(fixed$(articulation_rate, 2))
			appendInfoLine: tab$, tab$, "Average syllable duration (phonation time / number of syllables): ", number(fixed$(asd, 3)), " seconds", newline$
		endif

		selectObject: result, tg
		removeObject: intensity, intensitytier, pitch
	else
		result = Copy: s$ + "-marksyllables"

		noprogress Create TextGrid: 0, dur, "peaks syllables", "peaks"
		Set interval text: 2, 1, "pause"
		Rename: s$ + "-marksyllables"
		plusObject: result

		if show_speech_rate_info
			appendInfoLine: tab$, tab$, "Number of syllables: 0"
			appendInfoLine: tab$, tab$, "Number of pauses: 1"
			appendInfoLine: tab$, tab$, "Total duration: ", number(fixed$(dur, 6)), " seconds"
			appendInfoLine: tab$, tab$, "Phonation time: 0 seconds"
			appendInfoLine: tab$, tab$, "Speech rate (number of syllables / total duration): 0"
			appendInfoLine: tab$, tab$, "Articulation rate (number of syllables / phonation time): --undefined--"
			appendInfoLine: tab$, tab$, "Average syllable duration (phonation time / number of syllables): --undefined-- seconds", newline$
		endif
	endif

	View & Edit
endproc
