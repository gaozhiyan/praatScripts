n=numberOfSelected ("Sound")
echo n='n'
m=numberOfSelected ("TextGrid")
printline m='m'

if n!=m
exit ERROR!PLEASE MAKE SURE YOU SELECTED THE SAME NUMBER OF SOUND AND TEXTGRID FILES.
endif

printline
printline List of Sound Files

for i to n
    sound'i' = selected ("Sound", i)
    printline sound'i'
endfor

printline
printline List of TextGrid Files

for i to m
    textgrid'i'=selected("TextGrid",i)
    printline textgrid'i'
endfor
printline

printline word 'tab$'     fricative 'tab$'     duration'tab$'     Centre of Gravity 'tab$'      Deviation 'tab$'          Skewness 'tab$'    Kurtosis 'tab$'      F1 'tab$'      F2
# this will print the headings for each measurements targeted





#loop through all the textgrids
for i to n
  select sound'i'
  select textgrid'i'
numint=Get number of intervals... 3
    nl=(numint-1)/2
printline nl='nl'
   #loop through all the fricatives labeled, there are nl number of fricatives and spectrum objects after this operation

   for j to nl
 

  #for each fricative, get start and end point of measurement
      
       select sound'i'
       select textgrid'i'
       fricative$=Get label of interval... 3 2*j

       t1=Get start point... 3 2*j
       t2=Get end point... 3 2*j

       t12=t1+0.001
       intervalw=Get interval at time... 1 t12
      word$=Get label of interval... 1 intervalw

       #window length is actually fricative length
      windowlength=t2-t1
      mid=t1+windowlength/2
      start=mid-windowlength/4
      end=mid+windowlength/4
     # Insert boundary... 3 start
     # Insert boundary... 3 end
      #t3 is the measurement point of vowel F1,F2
      t3=t2+0.01
      


       #create the spectrum object
      select sound'i'
      newSound=Extract part... start end rectangular 1.0 no
      select newSound
      spectrum=To Spectrum... Fast
      select newSound
      Remove

    select spectrum
    gravity = Get centre of gravity... 3 
    deviation = Get standard deviation... 3
    skewness = Get skewness... 3
    kurtosis = Get kurtosis... 3
    
    select spectrum
    Remove



  #create and measure f1,f2
     select sound'i'
    formant=To Formant (burg)... 0.0 5 5500 0.025 50
    select formant
    f1=Get value at time... 1 t3 Hertz Linear
    f2=Get value at time... 2 t3 Hertz Linear
    select formant
    Remove
    printline 'word$'  'tab$'     'fricative$'  'tab$'    'windowlength''tab$'      'gravity:1' 'tab$'             'deviation:1' 'tab$'  	'skewness:1''tab$'	'kurtosis:1''tab$'      'f1'  'tab$'     'f2'
endfor
#this qureies all the selected objects and print all the numbers




endfor
    












 