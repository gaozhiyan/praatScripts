# This script uses the automatic estimation of min and max f0 (included in "minmaxf0.praat") proposed by Daniel Hirst for the Momel project
# https://www.researchgate.net/publication/228640428_A_Praat_plugin_for_Momel_and_INTSINT_with_improved_algorithms_for_modelling_and_coding_intonation

include batch.praat

procedure action
include minmaxf0.praat
	noprogress To Pitch: 0.01, minF0, maxF0
endproc
