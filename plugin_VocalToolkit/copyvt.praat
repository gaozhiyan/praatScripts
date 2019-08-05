# Vocal tract length estimation adapted from the procedure described at: http://www.languagebits.com/phonetics-english/resonant-frequencies-and-vocal-tract-length/
# Code in R by Romeo Mlinar: http://www.languagebits.com/files/formants-tract-length-in-r.html
# Original formula from Johnson, Keith. Acoustic and Auditory Phonetics. 2nd ed. Malden, Mass: Blackwell Pub, 2003. p. 96

form Copy vocal tract size
	comment Vocal tract length estimation
	positive Calculate_from_formant 4
	comment Formant determination
	positive Maximum_formant_first_Sound_(Hz) 5500 (= adult female)
	positive Maximum_formant_second_Sound_(Hz) 5500 (= adult female)
	comment Set 5000 Hz for men, 5500 Hz for women or up to 8000 Hz for children.
	boolean Show_info 1
endform

s1 = selected("Sound")
s1$ = selected$("Sound")
s2 = selected("Sound", 2)
s2$ = selected$("Sound", 2)

if show_info
	appendInfoLine: newline$, "Copy vocal tract size..."
endif

selectObject: s1
@getvtl: calculate_from_formant, maximum_formant_first_Sound
vtl_1 = getvtl.vtl
vtlr_1 = number(fixed$(17.5 / vtl_1, 2))
freq_1 = getvtl.formant_frequency

if show_info
	appendInfoLine: tab$, s1, ". Sound ", s1$
	appendInfoLine: tab$, tab$, "Estimated vocal tract length: ", number(fixed$(vtl_1, 2)), " cm   (mean F", calculate_from_formant, " = ", number(fixed$(freq_1, 3)), " Hz)"
	appendInfoLine: tab$, tab$, "Vocal tract length ratio: ", vtlr_1, "   (17.5 cm / ", number(fixed$(vtl_1, 2)), " cm)", newline$
endif

selectObject: s2
@getvtl: calculate_from_formant, maximum_formant_second_Sound
vtl_2 = getvtl.vtl
vtlr_2 = number(fixed$(17.5 / vtl_2, 2))
freq_2 = getvtl.formant_frequency

if show_info
	appendInfoLine: tab$, s2, ". Sound ", s2$
	appendInfoLine: tab$, tab$, "Estimated vocal tract length: ", number(fixed$(vtl_2, 2)), " cm   (mean F", calculate_from_formant, " = ", number(fixed$(freq_2, 3)), " Hz)"
	appendInfoLine: tab$, tab$, "Vocal tract length ratio: ", vtlr_2, "   (17.5 cm / ", number(fixed$(vtl_2, 2)), " cm)", newline$
endif

formant_shift_ratio = number(fixed$(vtlr_1 - vtlr_2 + 1, 2))

if formant_shift_ratio <> undefined
	runScript: "changevt.praat", formant_shift_ratio
	Rename: s2$ + "-copyvtsize-" + s1$
else
	Copy: s2$ + "-copyvtsize-" + s1$
endif

if show_info
	appendInfoLine: tab$, "(Ratio 1 = 17.5 cm = reference vocal tract length)", newline$
	appendInfoLine: tab$, "Formant shift ratio applied: ", formant_shift_ratio, "   (", vtlr_1, " - ", vtlr_2, " + 1)", newline$
	appendInfoLine: tab$, "(Adapted from the procedure described at: http://www.languagebits.com/?p=1057)"
endif

procedure getvtl: .fn, .mf
	.sel_tmp = selected("Sound")
	.int = Get intensity (dB)

	if .int <> undefined
		runScript: "workpre.praat"
		.tmp1 = selected("Sound")

		runScript: "extractvowels.praat", "no"
		.tmp2 = selected("Sound")

		runScript: "workpre.praat"
		.tmp3 = selected("Sound")

		.formant = noprogress nowarn To Formant (robust): 0.005, 5, .mf, 0.025, 50, 1.5, 5, 0.000001
		.formant_frequency = Get mean: .fn, 0, 0, "hertz"

		selectObject: .sel_tmp
		removeObject: .tmp1, .tmp2, .tmp3, .formant
	else
		.formant_frequency = undefined
	endif

	.prep = 35000 * ((.fn / 2) - 0.25)
	.vtl = .prep / .formant_frequency
endproc
