# Normalise all sounds in a given directory using RMS normallisation
#
# Written by Jose J. Atria (29 May 2014)
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.
#
include ../procedures/selection.proc
include ../procedures/require.proc
@require("5.3.63")

form RMS normalisation...
  positive Target_intensity_(dB) 70
  boolean  Keep_conversion_table no
  boolean  Make_changes_inline no
  boolean  Verbose no
endform

stopwatch

@saveSelection()
all = numberOfSelected()
@refineToType("Sound")
sounds = numberOfSelected("Sound")

# If normalisation causes clipping, scale peaks down to this value (in Pascal)
scale_peak_to = 0.9

if sounds and sounds = all

  table = Create Table with column names: "conversions", 0,
    ..."name rms_pre max_pre rms_post max_post"

  @createEmptySelectionTable()
  normalised = createEmptySelectionTable.table
  Rename: "normalised"

  for i to sounds
    sound = saveSelection.id[i]
    selectObject: sound
    name$ = selected$("Sound")

    @rms_and_max()

    selectObject: table
    Append row
    Set string value:  i, "name",    name$
    Set numeric value: i, "rms_pre", rms
    Set numeric value: i, "max_pre", max

    selectObject: sound
    if make_changes_inline
      @addToSelectionTable(normalised, sound)
    else
      Copy: name$ + "_normalised"
      @addToSelectionTable(normalised, selected())
    endif

    Scale intensity: target_intensity

    @rms_and_max()

    selectObject(table)
    Set numeric value: i, "rms_post", rms
    Set numeric value: i, "max_post", max
  endfor

  selectObject(table)
  max = Get maximum: "max_post"
  peaks_scaled = 0
  if max >= 1
    peaks_scaled = 1
    factor = scale_peak_to / max

    for i to sounds
      selectObject: normalised
      id    = Get value: i, "id"
      name$ = Get value: i, "name"

      selectObject: id

      Formula: "self*" + string$(factor)

      @rms_and_max()

      selectObject: table
      Set numeric value: i, "rms_post",  rms
      Set numeric value: i, "max_post",  max
    endfor

    selectObject: id
    intensity = Get intensity (dB)
  else
    intensity = target_intensity
  endif

  if !keep_conversion_table
    removeObject(table)
  endif

  time = stopwatch

  if verbose
    writeInfoLine: "Processed " + string$(sounds) + " files ",
      ... "in " + fixed$(time, 2) + " seconds"
    appendInfoLine: "All processed files set to ", fixed$(intensity, 2), "dB"
  endif

  if peaks_scaled
    appendInfo: "W: Target intensity reduced to "
    if !verbose
      appendInfo: fixed$(intensity, 2), "dB to "
    endif
    appendInfoLine: "avoid clipping"
  endif

  @restoreSavedSelection(normalised)
  removeObject: normalised
endif

procedure rms_and_max ()
  rms = Get root-mean-square: 0, 0
  max = Get maximum: 0, 0, "None"
  min = Get minimum: 0, 0, "None"
  max = if abs(max) > abs(min) then abs(max) else abs(min) fi
endproc
