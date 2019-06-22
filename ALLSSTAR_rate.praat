#This script takes the points on tier 1 (point tier) and gives info for each point wrt the time it occurs, the interval it occurs in,
#the duration of that interval, and the count of that point wrt the interval it is in
# Tuuli Morrill, October 2014

form Get All PI Point and Interval Labels for each Utterance
	comment Full path of the resulting text file:
	text resultfile speechrate.txt
endform


#Check if the result file exists:
if fileReadable (resultfile$)
	pause The result file 'resultfile$' already exists! Do you want to overwrite it?
	filedelete 'resultfile$'
endif

#Write a row with column titles to the result file:
titleline$ = "Filename 'tab$'point'tab$'PointTime 'tab$'InvervalLabel'tab$'IntervalDuration'tab$'pointsPerInt'tab$'PointCount 'newline$'"
fileappend "'resultfile$'" 'titleline$'


# Here, you make a listing of all the textgrids in a directory.
Create Strings as file list... list *.TextGrid
numberOfFiles = Get number of strings

for j from 1 to numberOfFiles
	select Strings list
	currentfile$ = Get string... 'j'
	Read from file... 'currentfile$'

	#object_name$ = 'currentfile$' ("TextGrid")
	olduttstart = 0
	pointsPerInt = 1
	numberOfpoints = Get number of points... 1
		 for i from 1 to numberOfpoints
                time1 = Get time of point... 1 i
                pointlabel$= Get label of point... 1 i
                sounding = Get interval at time... 2 time1
                soundingLabel$= Get label of interval... 2 sounding
                uttstart = Get starting point... 2 sounding
                uttend = Get end point... 2 sounding
                start = Get starting point... 2 sounding
                duration = uttend-uttstart
					if uttstart = olduttstart
						pointsPerInt = pointsPerInt + 1
					else
						pointsPerInt = 1
					endif
                resultline$ = "'currentfile$' 'tab$' 'pointlabel$''tab$' 'time1' 'tab$' 'soundingLabel$''tab$''start''tab$' 'duration' 'tab$''pointsPerInt''tab$''newline$'"
                fileappend "'resultfile$'" 'resultline$'
		 olduttstart = uttstart
        		endfor
		select all
     		minus Strings list
     		Remove
endfor
select all
Remove
clearinfo
print Done!