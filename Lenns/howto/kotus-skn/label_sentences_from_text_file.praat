# Kotus SKN-korpus
# xml-litteraatin kohdistus (virkkeet)
# Suorita ensin taukoanalyysi skriptill� mark_pauses.praat!
# Ohje: http://www.helsinki.fi/~lennes/praat-scripts/howto/kotus-skn/skn-korpuksen_kohdistus.html

form Kohdista SKN-korpuksen virkkeet
	comment Minne tallennetaan v�liversiot?
	sentence Hakemisto 
endform

soundname$ = selected$ ("LongSound", 1)
gridname$ = selected$ ("TextGrid", 1)

gridfile$ = hakemisto$ + gridname$ + ".TextGrid"
if fileReadable (gridfile$)
	pause Tiedosto on jo olemassa! Korvataanko se?
endif

# echo 

select TextGrid 'gridname$'
total_duration = Get total duration
stringlength = 0
filelength = 0
firstnewline = 0
oldlabel$ = ""
newlabel$ = ""

filename$ = "labels.xml"
tier = 1
starting_interval = 1 
overwrite = 1
editorIsOpen = 0

# Kopioi utterances-kerros kullekin puhujalle 3 kertaa: 1. puhuja_sentence, 2. tier puhuja_sentence_norm, 3. tier puhuja_sentenceID
select TextGrid 'gridname$'
numberOfTiers = Get number of tiers
#if numberOfTiers > 1
#	exit TextGridiss� saa olla vain 1 kerros, johon on rajattu alustavasti puhetta sis�lt�v�t p�tk�t!
#endif
# J�tet��n alustavasti 2 tieri�, joista alimmainen toimii pohjana uusille tiereille, ts. siihen ei lis�t� nimikkeit�, 
# ja ylempi (tyhj�) toimii tarkistustierin� (mihin asti nimikkeiden paikat on tarkistettu ja mist� aloitetaan seuraava):
sid_tier$ = "sentence-id"
if numberOfTiers = 1
	Insert interval tier... 1 sentence-id
	numberOfTiers = Get number of tiers
	speakerTiers = 0
	utterance_tier = 2
else
	# Tarkistetaan vanhat kerrokset:
	call GetTier "utterance" utterance_tier
	call GetTier 'sid_tier$' sid_tier
	speakerTiers = 0
	for t to numberOfTiers
		tier$ = Get tier name... t
		if index (tier$,"-utterance") > 0
			speakerTiers = speakerTiers + 1
		endif
	endfor
endif


# Read the text file and put it to the string file$
if fileReadable(filename$)
	Read Strings from raw text file... 'filename$'
else exit The text file 'filename$' does not exist.
endif
Rename... xml-labels
numberOfStrings = Get number of strings

	# Tarkista, montako puhujaa tekstitiedostossa esiintyy
		numberOfTurns = 0
		numberOfSpeakers = 0
		start_from = 0
		speaker1$ = ""
		utterance_interval = 0
		pages = 0
		previous_speaker$ = ""
		# Looppi: <p>-tagit (puheenvuorot), n-property:
		for string from 2 to numberOfStrings
			select Strings xml-labels
			string$ = Get string... string
			if index(string$, "<pb ") > 0
				# L�ytyi sivunumero, poimitaan se muistiin.
				pages = pages + 1
				pg_id'pages'$ = right$(string$,(length(string$)-(index(string$,"id="))-3))
				pg_id'pages'$ = left$(pg_id'pages'$,(index(pg_id'pages'$,"""")-1))
				pg_id$ = pg_id'pages'$
				pg_nr'pages'$ = right$(string$,(length(string$)-(index(string$,"n="))-2))
				pg_nr'pages'$ = left$(pg_nr'pages'$,(index(pg_nr'pages'$,"""")-1))
				pg_nr$ = pg_nr'pages'$
			elsif index(string$, "<p ") > 1
				# L�ytyi uusi puheenvuoro. Katso kuka siin� puhuu:
				numberOfTurns = numberOfTurns + 1
				p_id'numberOfTurns'$ = right$(string$,(length(string$)-(index(string$,"id="))-3))
				p_id'numberOfTurns'$ = left$(p_id'numberOfTurns'$,(index(p_id'numberOfTurns'$,"""")-1))
				p_id$ = p_id'numberOfTurns'$
				# Poimitaan puhujan koodi 
				turn'numberOfTurns'speaker$ = right$(string$,(length(string$)-(index(string$,"n="))-2))
				turn'numberOfTurns'speaker$ = left$(turn'numberOfTurns'speaker$,(index(turn'numberOfTurns'speaker$,"""")-1))
				speaker_exists = 0
				speaker$ = turn'numberOfTurns'speaker$
				speaker_tier = 0
				select TextGrid 'gridname$'
				# Tarkistetaan, onko t�m� puhuja jo listalla:
				for speaker to numberOfSpeakers
					if speaker'speaker'$ = speaker$
						speaker_exists = 1
					 	speaker_tier = speaker'speaker'_tier
					endif
				endfor
				# Jos puhuja ei ollut viel� listalla, katsotaan l�ytyyk� h�nelle kuitenkin vanhastaan oma kerros:
				if speaker_exists = 0
					if numberOfTiers > 2
						# Tarkistetaan, l�ytyyk� puhujan kerros TextGridist� jo vanhastaan:
						tiername$ = "'speaker$'-utterance"
						call GetTier 'tiername$' speaker_tier
						if speaker_tier > 0
							# Puhujan kerros l�ytyi. Merkit��n h�net listaan:
							numberOfSpeakers = numberOfSpeakers + 1
							speaker'numberOfSpeakers'$ = speaker$
							# Lis�t��n puhujan oma kerros listalle:
							speaker'numberOfSpeakers'_tier = speaker_tier
						endif
					endif
					# Jos uudelle puhujalle ei viel� ole kerrosta, luodaan h�nelle sellainen:
					if speaker_tier = 0
						numberOfSpeakers = numberOfSpeakers + 1
						speaker'numberOfSpeakers'$ = speaker$
						speakerTiers = speakerTiers + 1
						# Luodaan uudelle puhujalle kerros edellisten alle, pohjakerroksen ja tarkistuskerroksen yl�puolelle:
						speaker'numberOfSpeakers'_tier = speakerTiers
						Insert interval tier... speakerTiers 'speaker$'-utterance
						# Lis�t��n puhujan oma kerros listalle:
						speaker_tier = speaker'numberOfSpeakers'_tier
						numberOfTiers = Get number of tiers
						call GetTier 'sid_tier$' sid_tier
					endif
				endif
				
				# Kopioidaan virkkeet t�st� puheenvuorosta ko. puhujan sentence-kerrokseen:
				numberOfSentences = 0
				numberOfWords = 0
				numberOfBreaks = 0
				prev_start = 0
				
				while index(string$,"</p>") = 0 and string < numberOfStrings
					string = string + 1
					select Strings xml-labels
					string$ = Get string... string
					if index(string$, "<pb ") > 0
						# L�ytyi sivunumero, poimitaan se muistiin.
						pages = pages + 1
						pg_id'pages'$ = right$(string$,(length(string$)-(index(string$,"id="))-3))
						pg_id'pages'$ = left$(pg_id'pages'$,(index(pg_id'pages'$,"""")-1))
						pg_id$ = pg_id'pages'$
						pg_nr'pages'$ = right$(string$,(length(string$)-(index(string$,"n="))-2))
						pg_nr'pages'$ = left$(pg_nr'pages'$,(index(pg_nr'pages'$,"""")-1))
						pg_nr$ = pg_nr'pages'$
					elsif index(string$, "<s ") > 0
						# L�ytyi uusi virke. Poimitaan siit� ID:
						numberOfSentences = numberOfSentences + 1
						sentence$ = ""
						s_id'numberOfSentences'$ = right$(string$,(length(string$)-(index(string$,"id="))-3))
						s_id'numberOfSentences'$ = left$(s_id'numberOfSentences'$,(index(s_id'numberOfSentences'$,"""")-1))
						s_id$ = s_id'numberOfSentences'$
						
						while index(string$,"</s>") = 0 and index(string$,"</p>") = 0 and string < numberOfStrings
							string = string + 1
							select Strings xml-labels
							string$ = Get string... string
							if index(string$, "<pb ") > 0
								# L�ytyi sivunumero, poimitaan se muistiin.
								pages = pages + 1
								pg_id'pages'$ = right$(string$,(length(string$)-(index(string$,"id="))-3))
								pg_id'pages'$ = left$(pg_id'pages'$,(index(pg_id'pages'$,"""")-1))
								pg_id$ = pg_id'pages'$
								pg_nr'pages'$ = right$(string$,(length(string$)-(index(string$,"n="))-2))
								pg_nr'pages'$ = left$(pg_nr'pages'$,(index(pg_nr'pages'$,"""")-1))
								pg_nr$ = pg_nr'pages'$
							elsif index(string$, "<w ") > 1
								# L�ytyi uusi sane.
								numberOfWords = numberOfWords + 1
								w_id'numberOfWords'$ = right$(string$,(length(string$)-(index(string$,"id="))-3))
								w_id'numberOfWords'$ = left$(w_id'numberOfWords'$,(index(w_id'numberOfWords'$,"""")-1))
								w_id$ = w_id'numberOfWords'$
								word_norm_'numberOfWords'$ = right$(string$,(length(string$)-(index(string$,"norm="))-5))
								word_norm_'numberOfWords'$ = left$(word_norm_'numberOfWords'$,(index(word_norm_'numberOfWords'$,"""")-1))
								word_norm$ = word_norm_'numberOfWords'$
								word_spoken_'numberOfWords'$ = right$(string$,(length(string$)-(index(string$,""">"))-1))
								word_spoken_'numberOfWords'$ = left$(word_spoken_'numberOfWords'$,(index(word_spoken_'numberOfWords'$,"<")-1))		
								word_spoken$ = word_spoken_'numberOfWords'$
								# Normisanaa ei viel� k�ytet�, mutta se tulee parsittua oikein.
								if sentence$ = ""
									sentence$ = sentence$ + word_spoken$
								else
									sentence$ = sentence$ + " " + word_spoken$
								endif
							endif
							if index(string$, "<c ") > 0
								# L�ytyi v�limerkki, joka lasketaan t�ss� saneeksi.
								numberOfWords = numberOfWords + 1
								w_id'numberOfWords'$ = right$(string$,(length(string$)-(index(string$,"id="))-3))
								w_id'numberOfWords'$ = left$(w_id'numberOfWords'$,(index(w_id'numberOfWords'$,"""")-1))
								w_id$ = w_id'numberOfWords'$
								word_norm_'numberOfWords'$ = ""
								word_norm$ = ""
								word_spoken_'numberOfWords'$ = right$(string$,(length(string$)-(index(string$,""">"))-1))
								word_spoken_'numberOfWords'$ = left$(word_spoken_'numberOfWords'$,(index(word_spoken_'numberOfWords'$,"<")-1))		
								word_spoken$ = word_spoken_'numberOfWords'$
								# V�limerkill� ei ole "normisanaa", mutta itse merkki tulee parsittua oikein "puhuttuna saneena".
								if sentence$ = ""
									sentence$ = sentence$ + word_spoken$
								else
									sentence$ = sentence$ + " " + word_spoken$
								endif
							endif
						endwhile
						
						# P�ivitet��n t�m� virke TextGridiin
						tier = speaker_tier
						select TextGrid 'gridname$'
						utterance_tier = Get number of tiers
						numberOfUttIntervals = Get number of intervals... utterance_tier
						
						numberOfSidIntervals = Get number of intervals... sid_tier
						sentence_exists = 0
						sentence_end = 0
						latest_sentence_end = 0
						# Tarkistetaan, mist� alkaa viimeisin virke:
						for i to numberOfSidIntervals
							sid_label$ = Get label of interval... sid_tier i
							# Jos virkkeen id l�ytyy, se on jo tehty aikaisemmin:
							if sid_label$ = s_id$
								sentence_exists = 1
							# Jos virkkeen id-kerroksessa lukee jotakin, poimitaan sen alun kohdalta edellinen virke (n�ist� viimeisin j�� voimaan):
							elsif sid_label$ <> ""
								sid_start = Get starting point... sid_tier i
								utterance_interval = Get interval at time... utterance_tier sid_start
								# K�yd��n l�pi kaikkien puhujien tierit ja katsotaan viimeisimm�n virkkeen loppuaika:
								for t to speakerTiers
									tmp_tier = t
									tmp_sentence = Get interval at time... tmp_tier sid_start
									tmp_sentence_label$ = Get label of interval... tmp_tier tmp_sentence
									tmp_sentence_end = Get end point... tmp_tier tmp_sentence
									if tmp_sentence_label$ <> "" and tmp_sentence_end > latest_sentence_end
										latest_sentence_end = tmp_sentence_end
									endif
								endfor
							endif
						endfor
						# Tarkistetaan, onko puhuja vaihtunut:
						speaker_switch = 0
						if previous_speaker$ <> speaker$ and speakerTiers > 1
							speaker_switch = 1
						endif
						
						if sentence_exists = 0

							# Jos t�t� virkett� ei ole viel� merkattu, aloitetaan siit� mihin viimeisin virke p��ttyy:
							# Poimitaan mallikerroksesta mahdolliset rajat seuraavalle virkkeelle:
							if utterance_interval < numberOfUttIntervals
								utterance_interval = utterance_interval + 1
							endif
							utterance_start = Get starting point... utterance_tier utterance_interval
							utterance_end = Get end point... utterance_tier utterance_interval
							utterance_label$ = Get label of interval... utterance_tier utterance_interval									
							sentence_interval = Get interval at time... tier utterance_end
							sentence_start = Get starting point... tier sentence_interval
							sentence_label$ = Get label of interval... tier sentence_interval
								# Jos mallipuhunnoksen nimike ei ole "xxx" ja se p��ttyy edellisen virkkeen lopun j�lkeen ja virkeintervalli on tyhj�, mallipuhunnoksen rajat kelpaavat:
								latest_sentence_end = latest_sentence_end + 0.001
								while (sentence_label$ <> "" or utterance_label$ = "xxx" or utterance_end < latest_sentence_end) and utterance_interval < numberOfUttIntervals and (utterance_start < latest_sentence_end or speaker_switch = 1)
									utterance_interval = utterance_interval + 1
									utterance_label$ = Get label of interval... utterance_tier utterance_interval
									utterance_start = Get starting point... utterance_tier utterance_interval
									utterance_end = Get end point... utterance_tier utterance_interval
									sentence_interval = Get interval at time... tier utterance_end
									sentence_start = Get starting point... tier sentence_interval
									sentence_end = Get end point... tier sentence_interval
									sentence_label$ = Get label of interval... tier sentence_interval
								endwhile
								if sentence_start < utterance_start and (latest_sentence_end <> (utterance_start + 0.001) or speaker_switch = 1)
									new_sentence_start = utterance_start + 0.001
									if new_sentence_start < total_duration
										Insert boundary... tier new_sentence_start
										sentence_start = new_sentence_start
									endif
								endif
									
								# Jos kyseess� on tiedoston ensimm�inen virke, lis�t��n sille mielivaltainen alkuraja 0.2 sekunnin kohdalle:
								if sentence_start = 0 and utterance_start = 0 and numberOfSentences = 1
									new_sentence_start = 0.2
									Insert boundary... tier new_sentence_start
									sentence_start = new_sentence_start
									sentence_interval = 2
								endif
								utterance_end = utterance_end + 0.001
								if utterance_end < total_duration
									Insert boundary... tier utterance_end
								endif
								sentence_interval = Get interval at time... tier sentence_start
								sentence_start = Get starting point... tier sentence_interval
								sentence_end = Get end point... tier sentence_interval
							Set interval text... tier sentence_interval 'sentence$'
							
							# Lis�t��n virkkeen id ja uusi alkuraja:
							if sentence_start > 0
								Insert boundary... sid_tier sentence_start
							endif
							if sentence_start < total_duration
								sid_interval = Get interval at time... sid_tier sentence_start
								Set interval text... sid_tier sid_interval 's_id$'
							endif
							
							previous_speaker$ = speaker$
							
							# Zoomataan uuteen virkkeeseen (10 s molemmin puolin):
								sel_end = sentence_end + 10
								if sel_end > total_duration
									sel_end = total_duration
								endif
								sel_start = sentence_start - 10
								if sel_start < 0
									sel_start = 0
								endif
								select LongSound 'soundname$'
								plus TextGrid 'gridname$'
								Edit
								editor TextGrid 'gridname$'
								for f from 2 to tier
									Select next tier
								endfor
								Select... sel_start sel_end	
								Zoom to selection
								Select... sentence_start sentence_end	
		
							# Odotetaan k�ytt�j�n tekemi� korjauksia:
								beginPause ("Jatketaanko?")
								comment ("Tarkista t�m�n virkkeen rajojen paikat ja valitse:")
								clicked = endPause ("Jatka","Tallenna ja lopeta",1)
	
								Close
								editorIsOpen = 0

								# Jos k�ytt�j� halusi lopettaa ty�t, tallenna heti:
								if clicked = 2
									select TextGrid 'gridname$'
									Write to short text file... 'gridfile$'
									exit TextGrid-tiedosto tallennettu: 'gridfile$'
								endif
								
								
						endif
															
				endif				
							
				select TextGrid 'gridname$'
				Write to short text file... 'gridfile$'

				# T�m�n puheenvuoron tiedot Info-ikkunaan:
				# echo Turn ID 'p_id$', speaker 'speaker$', tier 'speaker_tier'
				
				endwhile
			endif
		endfor
	

		
	exit

	select TextGrid 'gridname$'
	numberOfIntervals = Get number of intervals... tier

#-------------
procedure GetTier name$ variable$
	numberOfTiers = Get number of tiers
	itier = 1
	repeat
		tier$ = Get tier name... itier
		itier = itier + 1
	until tier$ = name$ or itier > numberOfTiers
	if tier$ <> name$
		'variable$' = 0
	else
		'variable$' = itier - 1
	endif
	
endproc
