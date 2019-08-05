# This script uses the process to add jitter suggested by Paul Boersma at https://uk.groups.yahoo.com/neo/groups/praat-users/conversations/messages/2914

form Raspiness
	real Raspiness_(%) 20
endform

raspiness = min(max(raspiness, 0), 100)

include batch.praat

procedure action
	s = selected("Sound")
	s$ = selected$("Sound")

	if raspiness <> 0
		runScript: "workpre.praat"
		wrk = selected("Sound")
		dur = Get total duration
include minmaxf0.praat

		pitch = noprogress To Pitch: 0.01, minF0, maxF0
		f0 = Get quantile: 0, 0, 0.50, "Hertz"

		if f0 <> undefined
			plusObject: wrk
			manipulation = noprogress To Manipulation

			durationtier = Create DurationTier: "tmp", 0, dur
			Add point: 0, 1
			plusObject: manipulation
			Replace duration tier

			selectObject: pitch
			pointprocess = noprogress To PointProcess

			matrix = noprogress To Matrix
			r = raspiness / 100000
			Formula: "self + randomGauss(0, r)"

			pointprocess2 = noprogress To PointProcess
			plusObject: manipulation
			Replace pulses

			selectObject: manipulation
			res = Get resynthesis (overlap-add)
			runScript: "workpost.praat"

			removeObject: wrk, pitch, manipulation, durationtier, pointprocess, matrix, pointprocess2, res
		else
			selectObject: s
			Copy: "tmp"
			removeObject: wrk, pitch
		endif
	else
		Copy: "tmp"
	endif

	Rename: s$ + "-raspiness_" + string$(raspiness)
endproc
