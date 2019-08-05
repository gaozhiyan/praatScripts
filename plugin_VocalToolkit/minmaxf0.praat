# This script uses the automatic estimation of min and max f0 proposed by Daniel Hirst for the Momel project
# https://www.researchgate.net/publication/228640428_A_Praat_plugin_for_Momel_and_INTSINT_with_improved_algorithms_for_modelling_and_coding_intonation

selsnd_m = selected("Sound")

nocheck noprogress To Pitch: 0, 40, 600

if extractWord$(selected$(), "") = "Pitch"
	voicedframes = Count voiced frames
	if voicedframes > 0
		q25 = Get quantile: 0, 0, 0.25, "Hertz"
		q75 = Get quantile: 0, 0, 0.75, "Hertz"
		minF0 = round(q25 * 0.75)
		maxF0 = round(q75 * 1.5)
	else
		minF0 = 40
		maxF0 = 600
	endif
	Remove
else
	minF0 = 40
	maxF0 = 600
endif

if minF0 < 3 / (object[selsnd_m].nx * object[selsnd_m].dx)
	minF0 = ceiling(3 / (object[selsnd_m].nx * object[selsnd_m].dx))
endif

selectObject: selsnd_m
