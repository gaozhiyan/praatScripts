# Parts of this script were developed by exploring the file "VowelEditor.cpp" of the Praat source code, https://github.com/praat/praat/blob/master/dwtools/VowelEditor.cpp
# The "Flatter spectrum" synthesis method is based on the script by Tom Wempe and Paul Boersma "Appendix K - Vowel generator", included in "Rauber, A. (2006). Perception and production of english vowels by brazilian efl speakers", http://repositorio.ufsc.br/xmlui/handle/123456789/88701

form Create vowel
	positive Duration_(s) 0.8
	positive left_F0_range_(Hz) 150
	positive right_F0_range_(Hz) 100
	real F1_(Hz) 500
	real F2_(Hz) 1500
	real F3_(Hz) 2500
	real F4_(Hz) 3500
	boolean Preset_vowel_(Peterson_&_Barney_1952) 1
	optionmenu Speaker 1
		option Man
		option Woman
		option Child
	optionmenu Vowel 1
		option i	iy	"heed"
		option ɪ	ih	"hid"
		option ɛ	eh	"head"
		option æ	ae	"had"
		option ɑ	aa	"hod"
		option ɔ	ao	"hawed"
		option ʊ	uh	"hood"
		option u	uw	"who’d"
		option ʌ	ah	"hud"
		option ɝ	er	"heard"
	choice Synthesis_method 1
		button VowelEditor (4 formants)
		button Flatter spectrum (extra formants added)
	boolean Play_(click_Apply._Uncheck_to_publish) 1
endform

s# = selected# ("Sound")
duration = min(max(duration, 0.01), 10)
left_F0_range = min(max(left_F0_range, 40), 2000)
right_F0_range = min(max(right_F0_range, 40), 2000)
m## = { { 267, 2294, 2937 }, { 392, 1993, 2569 }, { 526, 1854, 2481 }, { 664, 1727, 2420 }, { 718, 1091, 2442 }, { 568, 836, 2403 }, { 437, 1023, 2245 }, { 307, 876, 2239 }, { 631, 1192, 2377 }, { 489, 1360, 1709 } }
w## = { { 310, 2783, 3312 }, { 441, 2474, 3063 }, { 608, 2334, 2999 }, { 863, 2049, 2832 }, { 864, 1229, 2783 }, { 587, 915, 2736 }, { 469, 1162, 2685 }, { 378, 961, 2666 }, { 758, 1409, 2768 }, { 503, 1641, 1977 } }
c## = { { 360, 3178, 3763 }, { 534, 2744, 3604 }, { 700, 2616, 3564 }, { 1017, 2334, 3366 }, { 1030, 1383, 3188 }, { 694, 1064, 3263 }, { 560, 1402, 3332 }, { 432, 1193, 3250 }, { 855, 1592, 3328 }, { 569, 1806, 2194 } }

if preset_vowel
	vw$ = extractWord$(vowel$, tab$)
	if speaker = 1
		f[1] = m##[vowel, 1]
		f[2] = m##[vowel, 2]
		f[3] = m##[vowel, 3]
		ff = 1
	endif
	if speaker = 2
		f[1] = w##[vowel, 1]
		f[2] = w##[vowel, 2]
		f[3] = w##[vowel, 3]
		ff = 1.2
	endif
	if speaker = 3
		f[1] = c##[vowel, 1]
		f[2] = c##[vowel, 2]
		f[3] = c##[vowel, 3]
		ff = 1.35
	endif
	f[4] = ff * 3500
else
	speaker$ = "custom"
	vw$ = "input"
	f[1] = f1
	f[2] = f2
	f[3] = f3
	f[4] = f4
	ff = f4 / 3500
endif

fd = round(ff * 1000)

if synthesis_method = 1
	nformants = 4
else
	nformants = 20
endif

formantgrid = Create FormantGrid: "filter", 0, duration, nformants, 500, 1000, 100, 100

for i to nformants
	Remove formant points between: i, 0, duration
	Remove bandwidth points between: i, 0, duration
endfor

for i to 4
	fr = f[i]
	if synthesis_method = 1
		bw = fr / 10
	else
		bw = sqrt(80 ^ 2 + (fr / 20) ^ 2)
	endif
	Add formant point: i, duration / 2, fr
	Add bandwidth point: i, duration / 2, bw
endfor

if synthesis_method = 2
	fr = f[4]
	for i from 5 to 20
		fr = fr + fd
		if fr < 20000
			bw = sqrt(80 ^ 2 + (fr / 20) ^ 2)
			Add formant point: i, duration / 2, fr
			Add bandwidth point: i, duration / 2, bw
		endif
	endfor
endif

pitchtier = Create PitchTier: "f0", 0, duration
Add point: 0, left_F0_range
Add point: duration, right_F0_range

pointprocess = noprogress To PointProcess

if synthesis_method = 1
	src = noprogress To Sound (pulse train): 44100, 0.7, 0.05, 30
else
	src = noprogress To Sound (phonation): 44100, 0.7, 0.05, 0.7, 0.03, 3.0, 4.0
endif

plusObject: formantgrid
Filter

zmin = 0.00000762939453125
sn = 1
sv = Get value at sample number: 0, sn
while sv < zmin
	sn += 1
	sv = Get value at sample number: 0, sn
endwhile

if sv <> undefined
	st = Get time from sample number: sn
	Fade in: 0, st, 0.005, "yes"
	Fade out: 0, duration, -0.005, "yes"
endif

removeObject: formantgrid, pitchtier, pointprocess, src

if play
	Play
	Remove
	selectObject: s#
else
	Rename: "Vowel_" + speaker$ + "_" + vw$
endif
