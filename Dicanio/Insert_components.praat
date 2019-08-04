#This script reads a textgrid file and creates a tier with component labels for stop consonants. Four components may be 
#included, e.g. voiced closure duration, voiceless closure duration, release burst, and aspiration. However, the user can 
#specify whatever names they prefer.

#The user must specify the inventory of stops in the language, which tier the stop labels appear on, and number of the tier
#where the components will appear. The inventory must be specified using the labels from manual segmentation or 
#forced alignment. That is to say, this script requires that there already be a segmentation of the speech signal into 
#phone-sized units. The stop inventory should be specified with no spaces, e.g. PTK or PBTDCJKG.
#Note that (until I modify this script further) all stops here are assumed to be monographs, e.g. K not KK, Q not KW. Sorry.

#Copyright Christian DiCanio, Haskins Laboratories, July 2014.

form Insert components into Textgrids
   sentence Directory_name: /Linguistics/Arapaho/testing_coding/
   positive Segment_tier_number 1
   positive Component_tier_number 2
   sentence Stop_labels BTK
   sentence Label_1 vdclo
   sentence Label_2 vlclo
   sentence Label_3 rel
   sentence Label_4 asp
endform

Create Strings as file list... list 'directory_name$'/*.TextGrid
num = Get number of strings
for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	tgID = selected("TextGrid")
	Insert interval tier: component_tier_number, "components"
	num_labels = Get number of intervals... segment_tier_number
	lenstop = length(stop_labels$)	

	for i to num_labels
		select 'tgID'
		label$ = Get label of interval... segment_tier_number i
			for j from 1 to lenstop
				text$ [j] = mid$ (stop_labels$, j)
					if label$ = text$ [j]
					intvl_start = Get starting point... segment_tier_number i
					intvl_end = Get end point... segment_tier_number i
					Insert boundary: component_tier_number, intvl_start
					Insert boundary: component_tier_number, intvl_end
					int_dur = (intvl_end - intvl_start)
					dur_cut = int_dur/4

					Insert boundary: component_tier_number, (intvl_start + (1*dur_cut))
					intvl_num1 = Get interval at time: component_tier_number, intvl_start
					Set interval text: component_tier_number, intvl_num1, label_1$
					
					Insert boundary: component_tier_number, (intvl_start + (2*dur_cut))
					intvl_num2 = Get interval at time: component_tier_number, (intvl_start + (1*dur_cut))
					Set interval text: component_tier_number, intvl_num2, label_2$

					Insert boundary: component_tier_number, (intvl_start + (3*dur_cut))
					intvl_num3 = Get interval at time: component_tier_number, (intvl_start + (2*dur_cut))
					Set interval text: component_tier_number, intvl_num3, label_3$

					intvl_num4 = Get interval at time: component_tier_number, (intvl_start + (3*dur_cut))
					Set interval text: component_tier_number, intvl_num4, label_4$

					else
						#Do nothing
					endif
			endfor	
	endfor		
	select tgID
	Save as text file: "'directory_name$'/'fileName$'_with_components.TextGrid"
endfor
