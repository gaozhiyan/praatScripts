sf = Get sampling frequency

sp = noprogress To Spectrum: "yes"

sp_smooth = Cepstral smoothing: 100

tmp1 = noprogress To Sound
samples = Get number of samples

tmp2 = Create Sound from formula: "pulse", 1, 0, 0.05, sf, "0"
Formula: "if col > sf / 40 and col <= sf / 20 then object[tmp1][col - (sf / 40)] else object[tmp1][col + (samples - (sf / 40))] fi"

Extract part: 0, 0.05, "Hanning", 1, "no"
Scale peak: 0.99

removeObject: sp, sp_smooth, tmp1, tmp2
