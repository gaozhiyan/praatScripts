# Move all boundaries from a TextGrid to their nearest
# zero-crossings, keeping labels and number of intervals.
#
# The script can also move points in point tiers to
# zero-crossings, if so desired, by changing the value of the
# move_points variable.
#
# The script will process Sound and TextGrid pairs in sequential
# order, pairing the first Sound object with the first TextGrid
# object and so on. This should be fine for most cases.
#
# Written by Jose J. Atria (April 20, 2012)
# Latest revision: 27 October 2014
# Requires Praat v 5.3.44
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

form Move boundaries to zero-crossings...
  integer Tier 0 (= all)
  integer Maximum_shift_(s) 0 (= no maximum)
  boolean Ignore_points 1
  comment Changes will be made inline
endform

# If points in point tiers are to be moved as well, set this to 1.
# Otherwise, set to 0.
move_points = !ignore_points

# Set to true if all tiers are to be processed, false if only one
all_tiers = !tier
form.tier = tier
form.verbose = 0

include ../procedures/selection.proc

# Perform initial checks on original selection
total_sounds    = numberOfSelected("Sound")
total_textgrids = numberOfSelected("TextGrid")

if !total_sounds or total_sounds and (total_sounds != total_textgrids)
  exitScript: "Please select an equal number of Sound and TextGrid objects."
endif

# Save selection
@saveTypeSelection("Sound")
sounds = saveTypeSelection.table
@saveTypeSelection("TextGrid")
textgrids = saveTypeSelection.table

include ../procedures/move_to_zero_crossings.proc

# Object loop
for current to total_sounds

  sound    = Object_'sounds'[current, "id"]
  textgrid = Object_'textgrids'[current, "id"]

  selectObject: sound
  sound_length = Get total duration
  sound_name$ = selected$("Sound")

  selectObject: textgrid
  textgrid_length = Get total duration
  textgrid_name$ = selected$("TextGrid")

  if form.verbose
    @clearOnce()
    appendInfoLine: "Sound: " + sound_name$ + "; TextGrid: " + textgrid_name$
  endif

  # Check if objects are related
  if sound_length = textgrid_length

    selectObject: textgrid
    if all_tiers
      first_tier = 1
      last_tier  = Get number of tiers
    else
      first_tier = form.tier
      last_tier  = form.tier
    endif

    for tier from first_tier to last_tier
      selectObject: textgrid
      interval_tier = Is interval tier: tier

      if interval_tier or (!interval_tier and move_points)

        selectObject: sound, textgrid
        @moveToZeroCrossings(tier, maximum_shift)

        if form.verbose
          moved = moveToZeroCrossings.moved_items
          if moved
            appendInfo: "Moved ", moved
            if interval_tier
              appendInfo: "boundar" +
                ... if !moved or moved > 1 then "ies " else "y " fi
            else
              appendInfo: "point" +
                ... if !moved or moved > 1 then "s " else " " fi
            endif
            appendInfoLine: "to zero-crossings"
            appendInfoLine: "Greatest time shift: ",
              ...moveToZeroCrossings.max_shit, "s"
          endif
        endif

        # End process tier block
      endif

      # End tier loop
    endfor

    # End related block
  endif

  # End object loop
endfor

# Restore original selection
@restoreSavedSelection(sounds)
@plusSavedSelection(textgrids)
removeObject: sounds, textgrids

procedure clearOnce ()
  if form.verbose and !variableExists("clearOnce.cleared")
    clearinfo
    .cleared = 1
  endif
endproc
