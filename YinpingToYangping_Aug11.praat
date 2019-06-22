####################
## manipulate F0 contour according to formula in Xu(2006)
## 1. select template speech sample, open the speech with Praat, rename it to "template"
## 2. manipulate start and end point (ERB scale)
## 3. manipulate the rest (ERB scale)
##
## Zhiyan Gao Aug.8, 2017
####################
form continuum number 
	comment Set step 
	natural which_step 1
	comment Set step size (ERB) 
	real step_size 0.12
	comment Set offset freqency (Hz)
	natural offset_frequency 130.00
	comment Set onset freqency (Hz)
	natural onset_frequency 130.00
endform

step = which_step
step_size = step_size
foff = offset_frequency
fon1 = onset_frequency
##select template
selectObject:"Sound template"
sound = Concatenate
Rename: "original"
selectObject(sound)

##begin manipulate, get pitch at every 0.01s, from 75Hz to 600Hz
manipulation = To Manipulation: 0.01, 75, 600
pitchtier = Extract pitch tier

##make a copy of the original, name it as "old"
##get index of every pitch point
original = Copy: "old"
points = Get number of points

##get F0 value at every point, and manipulate it with function 1 in Xu (2006)
## 


for p to points
  selectObject(original)
  t = Get time from index: p

#set onset frequency
	selectObject(pitchtier)
   	f = Get value at index: p
	if step = 1
		fon = fon1
	else
   		erb1 = 16.7*log10((fon1/165.4)+1)
		erb = erb1-0.12*(step-1)
		fon = 165.4*(10^(erb/16.7)-1)
		
	endif
	
	if p = 1 
   		Remove point: p
   		Add point: t, fon

#set offset frequency
	elsif p = points
		Remove point: p
   		Add point: t, foff

#set the rest according to the function in Xu
	else 
		selectObject(pitchtier)
		start = Get time from index: 1
		end = Get time from index: points
		duration = end - start
		frest = (foff-fon)*(t-start)/duration+fon
		Remove point: p
   		Add point: t, frest
  	endif
	
endfor

# replace the pitch tier
selectObject(pitchtier, manipulation)
Replace pitch tier

# Resynthesize
selectObject(manipulation)
new_sound = Get resynthesis (overlap-add)

# And clean up
removeObject(original, pitchtier, manipulation)
selectObject(new_sound)
name$ = "1-2_step"+"'step'"
Rename: name$
selectObject: "Sound original"
Remove

