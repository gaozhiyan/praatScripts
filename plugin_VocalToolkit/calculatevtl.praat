# This script is adapted from the procedure described at: http://www.languagebits.com/phonetics-english/resonant-frequencies-and-vocal-tract-length/
# Code in R by Romeo Mlinar: http://www.languagebits.com/files/formants-tract-length-in-r.html
# Original formula from Johnson, Keith. Acoustic and Auditory Phonetics. 2nd ed. Malden, Mass: Blackwell Pub, 2003. p. 96

form Calculate vocal tract length
	comment Displays in the Info window the estimated vocal tract length in the
	comment neutral configuration, calculated from a formant frequency value.
	positive Formant_frequency_(Hz) 3500
	natural Formant_number 4
	comment
	boolean Calculate_from_the_selected_Sounds 1
	comment Formant determination
	positive Maximum_formant_(Hz) 5500 (= adult female)
	comment Set 5000 Hz for men, 5500 Hz for women or up to 8000 Hz for children.
endform

appendInfoLine: newline$, "Calculate vocal tract length..."

if calculate_from_the_selected_Sounds
include batch.praat
else
	@action
endif

appendInfoLine: tab$, "(Adapted from the procedure described at: http://www.languagebits.com/?p=1057)", newline$

procedure action
	if calculate_from_the_selected_Sounds
		s = selected("Sound")
		s$ = selected$("Sound")
		int = Get intensity (dB)

		if int <> undefined
			runScript: "workpre.praat"
			tmp1 = selected("Sound")

			runScript: "extractvowels.praat", "no"
			tmp2 = selected("Sound")

			runScript: "workpre.praat"
			tmp3 = selected("Sound")

			formant = noprogress nowarn To Formant (robust): 0.005, 5, maximum_formant, 0.025, 50, 1.5, 5, 0.000001
			formant_frequency = Get mean: formant_number, 0, 0, "hertz"

			selectObject: s
			removeObject: tmp1, tmp2, tmp3, formant
		else
			formant_frequency = undefined
		endif

		appendInfoLine: tab$, s, ". Sound ", s$
		t$ = tab$
	else
		t$ = ""
	endif

	prep = 35000 * ((formant_number / 2) - 0.25)
	vtl = prep / formant_frequency

	appendInfoLine: t$, tab$, "Estimated vocal tract length: ", number(fixed$(vtl, 2)), " cm   (mean F", formant_number, " = ", number(fixed$(formant_frequency, 3)), " Hz)", newline$
endproc
