Erase all

length = 3
height = 0.5
transcript_size = 10
left_padding = 0.5

# Get length ratio

selectObject: "Sound L1_cut"
donor_length = Get total duration
selectObject: "Sound L2_cut"
receiver_length = Get total duration
rec_don_ratio = receiver_length / donor_length
padding = (rec_don_ratio * length - length) / 2

# Draw box

x1 = 0.5 + padding + left_padding
x2 = x1 + length
y1 = 0.5
y2 = y1 + height
margin = 0.5
Select outer viewport: x1 - margin, x2 + margin, y1 - margin, y2 + margin
Select inner viewport: x1, x2, y1, y2
Black
Line width: 1
Draw inner box

# Draw Pitch

Solid line
Line width: 2
selectObject: "PitchTier L1_cut"
Draw: 0, 0, 0, 400, "no", "lines"

# Draw syllable marks

Dashed line
Line width: 1
selectObject: "TextGrid L1_cut"
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor

# Draw waveform

xb1 = 0.5 + left_padding
yb1 = 1.5
yb2 = yb1 + height

inner_x2 = xb1 + length * rec_don_ratio
Select outer viewport: xb1 - margin, inner_x2 + margin, yb1 - margin, yb2 + margin
Select inner viewport: xb1, inner_x2, yb1, yb2

Solid line
Line width: 0.5
Colour: "{0.800000,0.800000,0.800000}"
selectObject: "Sound L2_cut"
Draw: 0, 0, 0, 0, "no", "Poles"

# Draw second box

Line width: 1
Draw inner box

# Draw receiver pitch

Black
Solid line
Line width: 2
selectObject: "PitchTier L2_cut"
Draw: 0, 0, 0, 400, "no", "lines"

# Draw syllable marks

Dashed line
Line width: 1
selectObject: "TextGrid L2_cut"
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor

# Draw connecting lines

Font size: transcript_size
Helvetica
Dotted line
Select outer viewport: xb1 - margin, inner_x2 + margin, y2 - margin, yb1 + margin
Select inner viewport: xb1, inner_x2, y2, yb1
Axes: 0, receiver_length, 0, 1
shift = donor_length * (padding / length)
for j to 13
	if j = 1
		Grey
		Draw line: shift, 1, 0, 0
		prev_mid = shift / 2
	endif
	selectObject: "TextGrid L1_cut"
	x_don = Get end point: 1, j
	selectObject: "TextGrid L2_cut"
	x_rec = Get end point: 1, j
	Grey
	Draw line: x_don + shift, 1, x_rec, 0
	# Write text
	Black
	max_x = max (x_don + shift, x_rec)
	min_x = min (x_don + shift, x_rec)
	x_dif = max_x - min_x
	x_mid = min_x + (x_dif / 2)
	x_cent = prev_mid + ((x_mid - prev_mid) / 2)
	syl_text$ = Get label of interval: 1, j
	Text: x_cent + 0.005, "Centre", 0.5, "Half", syl_text$
	prev_mid = x_mid
endfor

# Write names
Black
width = 0.5
Select outer viewport: x1 - width - margin, x1 + margin, y1 - margin, y2 + margin
Select inner viewport: x1 - width, x1, y1, y2
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 12, "0", "D"

Select outer viewport: 0, xb1 + margin, yb1 - margin, yb2 + margin
Select inner viewport: xb1 - margin, xb1, yb1, yb2
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 12, "0", "R"

# Selection for export
Select outer viewport: 0, inner_x2 + margin * 2, 0, yb2 + margin * 2
Select inner viewport: 0, inner_x2 + margin, 0, yb2 + margin

# Draw Manipulations
man_margin = 0.25
x_lim = (inner_x2 + margin - left_padding) - (man_margin * 4)
man_length = x_lim / 3
man_padding = (man_length - (man_length / rec_don_ratio)) / 2

# Man 1:
dx1 = man_margin + man_padding + left_padding
dx2 = dx1 + man_length / rec_don_ratio
dy1 = yb2 + margin
dy2 = dy1 + man_margin
rx1 = man_margin + left_padding
rx2 = rx1 + man_length
ry1 = dy2 + man_margin
ry2 = ry1 + man_margin
mx1 = dx1
mx2 = dx2
my1 = ry2 + man_margin
my2 = my1 + man_margin

Select outer viewport: 0, rx2 + margin, dy1 - man_margin - margin, dy1 + margin
Select inner viewport: rx1, rx2, dy1 - man_margin, dy1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "Speech rate"

Select outer viewport: dx1 - margin, dx2 + margin, dy1 - margin, dy2 + margin
Select inner viewport: dx1, dx2, dy1, dy2
Line width: 1
Draw inner box
Select outer viewport: rx1 - man_margin - margin, rx1 + margin, dy1 - margin, dy2 + margin
Select inner viewport: rx1 - man_margin, rx1, dy1, dy2
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "D"

Select outer viewport: dx1 - margin, dx2 + margin, dy2 - margin, ry1 + margin
Select inner viewport: dx1, dx2, dy2, ry1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "0", "+"

Select outer viewport: rx1 - margin, rx2 + margin, ry1 - margin, ry2 + margin
Select inner viewport: rx1, rx2, ry1, ry2

Solid line
Line width: 0.5
Colour: "{0.800000,0.800000,0.800000}"
selectObject: "Sound L2_cut"
Draw: 0, 0, 0, 0, "no", "Poles"

Black
Solid line
Line width: 2
selectObject: "PitchTier L2_cut"
Draw: 0, 0, 0, 400, "no", "lines"
Dotted line
Line width: 1
selectObject: "TextGrid L2_cut"
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor
Select outer viewport: rx1 - man_margin - margin, rx1 + margin, ry1 - margin, ry2 + margin
Select inner viewport: rx1 - man_margin, rx1, ry1, ry2
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "R"

Select outer viewport: mx1 - margin, mx2 + margin, ry2 - margin, my1 + margin
Select inner viewport: mx1, mx2, ry2, my1
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "0", "="

Select outer viewport: mx1 - margin, mx2 + margin, my1 - margin, my2 + margin
Select inner viewport: mx1, mx2, my1, my2

Solid line
Line width: 0.5
Colour: "{0.800000,0.800000,0.800000}"
selectObject: "Sound L2_cut"
Draw: 0, 0, 0, 0, "no", "Poles"

Black
Line width: 1
Draw inner box
Line width: 2
Solid line
selectObject: "PitchTier L2_cut"
Draw: 0, 0, 0, 400, "no", "lines"
Dotted line
Line width: 1
selectObject: "TextGrid L2_cut"
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor
Select outer viewport: rx1 - man_margin - margin, rx1 + margin, my1 - margin, my2 + margin
Select inner viewport: rx1 - man_margin, rx1, my1, my2
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "M"

# Man 2:
dx1 = dx2 + man_padding + man_margin + man_padding
dx2 = dx1 + man_length / rec_don_ratio
dy1 = yb2 + margin
dy2 = dy1 + man_margin
rx1 = rx2 + man_margin
rx2 = rx1 + man_length
ry1 = dy2 + man_margin
ry2 = ry1 + man_margin
mx1 = rx1
mx2 = rx2
my1 = ry2 + man_margin
my2 = my1 + man_margin

Select outer viewport: 0, rx2 + margin, dy1 - man_margin - margin, dy1 + margin
Select inner viewport: rx1, rx2, dy1 - man_margin, dy1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "Rhythm"

Select outer viewport: dx1 - margin, dx2 + margin, dy1 - margin, dy2 + margin
Select inner viewport: dx1, dx2, dy1, dy2
Dotted line
Line width: 1
selectObject: "TextGrid L1_cut"
Axes: 0, donor_length, 0, 400
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor

# Select outer viewport: dx1 - man_margin - margin, dx1 + margin, dy1 - margin, dy2 + margin
# Select inner viewport: dx1 - man_margin, dx1, dy1, dy2
# Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "D"

Select outer viewport: dx1 - margin, dx2 + margin, dy2 - margin, ry1 + margin
Select inner viewport: dx1, dx2, dy2, ry1
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "0", "+"

Select outer viewport: rx1 - margin, rx2 + margin, ry1 - margin, ry2 + margin
Select inner viewport: rx1, rx2, ry1, ry2

Solid line
Line width: 0.5
Colour: "{0.800000,0.800000,0.800000}"
selectObject: "Sound L2_cut"
Draw: 0, 0, 0, 0, "no", "Poles"

Black
Solid line
Line width: 1
Draw inner box
Line width: 2
selectObject: "PitchTier L2_cut"
Draw: 0, 0, 0, 400, "no", "lines"

#Select outer viewport: rx1 - man_margin - margin, rx1 + margin, ry1 - margin, ry2 + margin
#Select inner viewport: rx1 - man_margin, rx1, ry1, ry2
#Axes: 0, 1, 0, 1
#Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "R"

Select outer viewport: mx1 - margin, mx2 + margin, ry2 - margin, my1 + margin
Select inner viewport: mx1, mx2, ry2, my1
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "0", "="

Select outer viewport: mx1 - margin, mx2 + margin, my1 - margin, my2 + margin
Select inner viewport: mx1, mx2, my1, my2

Solid line
Line width: 0.5
Colour: "{0.800000,0.800000,0.800000}"
selectObject: "Sound dur"
Draw: 0, 0, 0, 0, "no", "Poles"

Black
Line width: 1
Draw inner box
Line width: 2
Solid line
selectObject: "PitchTier dur"
Draw: 0, 0, 0, 400, "no", "lines"
Dotted line
Line width: 1
selectObject: "TextGrid dur"
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor
#Select outer viewport: mx1 - man_margin - margin, mx1 + margin, my1 - margin, my2 + margin
#Select inner viewport: mx1 - man_margin, mx1, my1, my2
#Axes: 0, 1, 0, 1
#Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "M"

# Man 3:
dx1 = dx2 + man_padding + man_margin + man_padding
dx2 = dx1 + man_length / rec_don_ratio
dy1 = yb2 + margin
dy2 = dy1 + man_margin
rx1 = rx2 + man_margin
rx2 = rx1 + man_length
ry1 = dy2 + man_margin
ry2 = ry1 + man_margin
mx1 = rx1
mx2 = rx2
my1 = ry2 + man_margin
my2 = my1 + man_margin

Select outer viewport: 0, rx2 + margin, dy1 - man_margin - margin, dy1 + margin
Select inner viewport: rx1, rx2, dy1 - man_margin, dy1
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "Intonation"

Select outer viewport: dx1 - margin, dx2 + margin, dy1 - margin, dy2 + margin
Select inner viewport: dx1, dx2, dy1, dy2
Line width: 2
Solid line
selectObject: "PitchTier L1_cut"
Draw: 0, 0, 0, 400, "no", "lines"

# Select outer viewport: dx1 - man_margin - margin, dx1 + margin, dy1 - margin, dy2 + margin
# Select inner viewport: dx1 - man_margin, dx1, dy1, dy2
# Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "D"

Select outer viewport: dx1 - margin, dx2 + margin, dy2 - margin, ry1 + margin
Select inner viewport: dx1, dx2, dy2, ry1
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "0", "+"

Select outer viewport: rx1 - margin, rx2 + margin, ry1 - margin, ry2 + margin
Select inner viewport: rx1, rx2, ry1, ry2

Solid line
Line width: 0.5
Colour: "{0.800000,0.800000,0.800000}"
selectObject: "Sound L2_cut"
Draw: 0, 0, 0, 0, "no", "Poles"

Black
Axes: 0, receiver_length, 0, 400
Solid line
Line width: 1
Draw inner box
Line width: 2
Dotted line
Line width: 1
selectObject: "TextGrid L2_cut"
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor

#Select outer viewport: rx1 - man_margin - margin, rx1 + margin, ry1 - margin, ry2 + margin
#Select inner viewport: rx1 - man_margin, rx1, ry1, ry2
#Axes: 0, 1, 0, 1
#Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "R"

Select outer viewport: mx1 - margin, mx2 + margin, ry2 - margin, my1 + margin
Select inner viewport: mx1, mx2, ry2, my1
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "0", "="

Select outer viewport: mx1 - margin, mx2 + margin, my1 - margin, my2 + margin
Select inner viewport: mx1, mx2, my1, my2

Solid line
Line width: 0.5
Colour: "{0.800000,0.800000,0.800000}"
selectObject: "Sound int"
Draw: 0, 0, 0, 0, "no", "Poles"

Black
Line width: 1
Draw inner box
Line width: 2
Solid line
selectObject: "PitchTier int"
Draw: 0, 0, 0, 400, "no", "lines"
Dotted line
Line width: 1
selectObject: "TextGrid int"
num_intervals = Get number of intervals: 1
for i to (num_intervals - 1)
	boundary = Get end point: 1, i
	Draw line: boundary, 400, boundary, 0
endfor
#Select outer viewport: mx1 - man_margin - margin, mx1 + margin, my1 - margin, my2 + margin
#Select inner viewport: mx1 - man_margin, mx1, my1, my2
#Axes: 0, 1, 0, 1
#Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 11, "0", "M"

# Input & Transplantation labels

Select outer viewport: 0 - margin, xb1, y1 - margin, yb2 + margin
Select inner viewport: 0, xb1 - margin, y1, yb2
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "90", "Input"

Select outer viewport: 0 - margin, xb1, dy1 - margin, my2 + margin
Select inner viewport: 0, xb1 - margin, dy1, my2
Axes: 0, 1, 0, 1
Text special: 0.5, "Centre", 0.5, "Half", "Helvetica", 14, "90", "Transplantation"

Select outer viewport: 0, mx2 + man_margin, 0 + man_margin, my2 + man_margin
Select inner viewport: margin, mx2 - man_margin, margin + (man_margin / 2), my2 - (man_margin / 2)
Solid line
# Draw rectangle: -0.13, 1.13, -0.125, 1.125
