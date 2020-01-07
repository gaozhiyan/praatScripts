

form Build your pretty picture
   comment Choose your elements
      boolean plot_pitch 1
      boolean plot_intensity 1
      boolean paint_spectrogram 1
   comment Intensity
      real mindb 50 
      real maxdb 100
   comment F0
      real minpitch 100
      real maxpitch 500
      real medianpitch 0
      choice style 2
        button Draw
        button Speckle
   comment Spectrogram
      real dynamic_range 40
      real pre-emphasis 5
endform
 
# gets the name
   name$ = selected$("Sound")

#########################################
# Text, waveform and one picture window #
#########################################

# a 'if' statement to plot one window 
if plot_pitch = 1 and plot_intensity = 0 and paint_spectrogram = 0 or plot_pitch = 0 and plot_intensity = 1 and paint_spectrogram = 0 or plot_pitch = 0 and plot_intensity = 0 and paint_spectrogram = 1 or plot_pitch = 1 and plot_intensity = 1 and paint_spectrogram = 0
# makes some picture window settings
   14
   Times
   Line width... 1
   ###Erase all
   Viewport... 4.5 9 0 4
# gets the textgrid and draws it
   select TextGrid 'name$'
   Line width... 1
   Draw... 0 0 yes yes yes
   Viewport... 4.5 9 2.8 3.3
# gets the sound and draws it
   select Sound 'name$'
   Draw... 0 0 0 0 no
   Viewport... 4.5 9 0 2.8
# gets the intensity and draws it, if selected in the form
if plot_intensity = 1 
   select Intensity 'name$'
   Line width... 1
   Draw inner box
   Draw... 0 0 'mindb' 'maxdb' no
if plot_intensity = 1 and plot_pitch = 1
   Marks right every... 1 10 yes yes no
   Text right... yes Intensity (dB)
elsif plot_intensity = 1 and plot_pitch = 0
   Marks left every... 1 10 yes yes no
   Text left... yes Intensity (dB)
endif

endif
# gets the pitch and draws it, if selected in the form
if plot_pitch = 1
   select Pitch 'name$'
   if style = 1
      Draw logarithmic... 0 0 'minpitch' 'maxpitch' no
   elsif style = 2
      Speckle logarithmic... 0 0 'minpitch' 'maxpitch' no
   endif 
   Logarithmic marks left... 5 yes yes no
   if medianpitch > 0
      One logarithmic mark left... 'medianpitch' no no yes
   endif
   Draw inner box
   #Text left... yes F_0 (Hz)
endif
# gets the spectrogram and paints it, if selected in the form
if paint_spectrogram = 1
   select Spectrogram 'name$'
   Paint... 0 0 0 0 100 yes 'dynamic_range' 'pre-emphasis' 0 no
  # Marks left every... 1 5000 yes yes no
   Draw inner box
   Text left... yes Frequency (Hz)
endif
   Viewport... 4.5 9 0 4
   select Sound 'name$'
##########################################
# Text, waveform and two picture windows #
##########################################
# this kicks in if you want a spectrogram as well as pitch and/or F0 drawing

elsif plot_pitch = 1 and plot_intensity = 0 and paint_spectrogram = 1 or plot_pitch = 0 and plot_intensity = 1 and paint_spectrogram = 1 or plot_pitch = 1 and plot_intensity = 1 and paint_spectrogram = 1 
# makes some picture window settings
   14
   Times
   Line width... 1
   #Erase all
   Viewport... 4.5 9 0 3.0
#does spectrogram
   select Spectrogram 'name$'
   Paint... 0 0 0 0 100 yes 'dynamic_range' 'pre-emphasis' 0 no
   One mark right... 5000 yes yes no
   Draw inner box
   Text right... yes Spectrogram (Hz)
   Text top... yes L2 production
# gets the textgrid and draws it
   Viewport... 4.5 9 1.9 5.00
   select TextGrid 'name$'
   Line width... 1
   Draw... 0 0 yes yes yes
# gets the sound and draws it
   Viewport... 4.5 9 1.52 4.5
   select Sound 'name$'
  # Draw... 0 0 0 0 no
# gets the intensity and draws it, if selected in the form
   Viewport... 4.5 9 1.9 4.2
   Line width... 1
if plot_intensity = 1 
   select Intensity 'name$'
   Line width... 1
  # Draw inner box
   Draw... 0 0 'mindb' 'maxdb' no
if plot_intensity = 1 and plot_pitch = 1
   Marks left every... 1 10 yes yes no
  # Text right... yes Intensity (dB)
elsif plot_intensity = 1 and plot_pitch = 0
   Marks right every... 1 10 yes yes no
   Text left... no Intensity (dB)
endif
   

endif
# gets the pitch and draws it, if selected in the form
if plot_pitch = 1
   select Pitch 'name$'
   Line width... 2
   if style = 1
      Draw logarithmic... 0 0 'minpitch' 'maxpitch' no
   elsif style = 2
      Speckle logarithmic... 0 0 'minpitch' 'maxpitch' no
   endif 
   Logarithmic marks right... 3 yes yes no
   if medianpitch > 0
      One logarithmic mark right... 'medianpitch' no no yes
   endif
   #Draw inner box
   Text right... yes Pitch (Hz)
endif
# gets the spectrogram and paints it, if selected in the form
   Viewport... 0 9 0 5
   select Sound 'name$'
endif