###scripts for Yuting Guo's projects
###Zhiyan Gao, June 2019

form get duration
comment Enter sound and textgrid directory
text directory /Users/zhiyangao/Desktop/guo/
comment always set to the vowel tier
positive tier 1
comment name of the resulting file txt
text resultfile duration-log.txt
endform

##  Now we will do some prep work to get your log file ready.  The first thing I usually do is
##  make sure that I delete any pre-existing variant of the log:

filedelete 'directory$'/'resultfile$'


##  Now I'm going to make a variable called "header_row$", then write that variable to the log file:

header_row$ = "Filename" + tab$ + "vot label" +  tab$ + "vot (ms.)"+ tab$ +"vowel label"+tab$+ "vowel (ms.)" + tab$+"word label" + tab$  + "word (ms.)"  +   newline$
header_row$ > 'directory$'/'resultfile$'

##  Now we make a list of all the text grids in the directory we're using, and put the number of
##  filenames into the variable "number_of_files":

Create Strings as file list...  list 'directory$'*.TextGrid
number_files = Get number of strings

# Then we set up a "for" loop that will iterate once for every file in the list:

for j from 1 to number_files

     #    Query the file-list to get the first filename from it, then read that file in:

     select Strings list
     current_token$ = Get string... 'j'
     Read from file... 'directory$''current_token$'


     object_name$ = selected$ ("TextGrid")


	
     number_of_intervals = Get number of intervals... tier
     for b from 1 to number_of_intervals
          interval_label$ = Get label of interval... tier 'b'
          if interval_label$ !="" and interval_label$ !="sp"
				vowel_b = Get starting point... tier b
				vowel_e = Get end point... tier b
				vowel_dur = (vowel_e - vowel_b)*1000 
				vowel_label$ = interval_label$
				
				word = Get interval at time... 3 vowel_b
				word_label$ = Get label of interval... 3 word
				word_e = Get end time of interval... 3 word
				word_b = Get start time of interval... 3 word
				word_dur = (word_e - word_b)*1000

				vot = Get interval at time... 2 word_b
                vot_label$ = Get label of interval... 2 vot
				if vot_label$ = ""
					vot_dur = 10000
				else
				vot_b = Get start time of interval... 2 vot
				vot_e = Get end time of interval... 2 vot
				vot_dur = (vot_e - vot_b)*1000
				endif
				
			
              fileappend "'directory$'/'resultfile$'" 'object_name$''tab$''interval_label$''tab$''vot_dur''tab$''vowel_label$''tab$''vowel_dur''tab$''word_label$''tab$''word_dur''newline$'
          endif
     endfor


     select all
     minus Strings list
     Remove
endfor

