# Parts of this script were adapted from the script "vowelonset.v4b.praat" by Hugo Quené, http://www.hugoquene.nl/tools/index.html

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")
	dur = Get total duration
	sf = Get sampling frequency

	result = Copy: s$ + "-markvowels"
	runScript: "fixdc.praat"
include minmaxf0.praat

	pitch = noprogress To Pitch: 0.01, minF0, maxF0

	selectObject: result
	if sf > 11025
		rs = Resample: 11025, 1
	else
		rs = Copy: "tmp"
	endif
	Filter with one formant (in-place): 1000, 500

	framelength = 0.01
	int_tmp = noprogress To Intensity: 60, framelength, "no"
	maxint = Get maximum: 0, 0, "Cubic"
	t1 = Get time from frame number: 1

	matrix_tmp = Down to Matrix
	endtime = Get highest x
	ncol = Get number of columns
	coldist = Get column distance
	h = 1
	newt1 = t1 + (h * framelength)
	ncol = ncol - (2 * h)

	matrix_intdot = Create Matrix: "intdot", 0, endtime, ncol, coldist, newt1, 1, 1, 1, 1, 1, "(object[matrix_tmp][1, col + h + h] - object[matrix_tmp][1, col]) / (2 * h * dx)"
	temp_intdot = noprogress To Sound (slice): 1
	temp_rises = noprogress To PointProcess (extrema): 1, "yes", "no", "Sinc70"

	selectObject: temp_intdot
	temp_peaks = noprogress To PointProcess (zeroes): 1, "no", "yes"
	npeaks = Get number of points

	selectObject: temp_peaks
	for i to npeaks
		ptime[i] = Get time from index: i
	endfor

	selectObject: int_tmp
	for i to npeaks
		pint[i] = Get value at time: ptime[i], "Nearest"
	endfor

	selectObject: pitch
	for i to npeaks
		voiced[i] = Get value at time: ptime[i], "Hertz", "Nearest"
	endfor

	selectObject: temp_rises
	vwn = 0
	for i to npeaks
		if pint[i] > (maxint - 12) and voiced[i] <> undefined
			rindex = Get low index: ptime[i]
			if rindex > 0
				rtime = Get time from index: rindex
				vwn += 1
				otime[vwn] = (rtime + ptime[i]) / 2
				ltime[vwn] = max(ptime[i] - rtime, 0.05)
			endif
		endif
	endfor

	removeObject: pitch, rs, int_tmp, matrix_tmp, matrix_intdot, temp_intdot, temp_rises, temp_peaks

	Create TextGrid: 0, dur, "vowels", ""
	Rename: s$ + "-markvowels"
	int_n = 1
	last_time = 0
	for i to vwn
		dif_time = otime[i]-last_time
		if dif_time > 0
			Insert boundary: 1, otime[i]
			int_n += 1
			Set interval text: 1, int_n, "vw"
			last_time = otime[i]
			e_time = otime[i] + ltime[i]
			dif_time = e_time - last_time
			Insert boundary: 1, e_time
			int_n += 1
			last_time = e_time
		endif
	endfor

	plusObject: result
	View & Edit
endproc
