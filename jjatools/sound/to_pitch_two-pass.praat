# Generate Pitch objects using Hirst's two-pass method
#
# Written by Jose J. Atria (2 July 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/check_directory.proc
include ../procedures/pitch_two-pass.proc
include ../procedures/selection.proc

form To Pitch (Hirst two-pass)...
  positive Floor_factor 0.75
  positive Ceiling_factor 1.5 (=use 2.5 for expressive speech)
endform

extension$ = "wav"

n =  numberOfSelected("Sound")

if !n
  exitScript: No objects selected
endif

# Save selection
for i to n
  sound[i] = selected(i)
endfor

# Iterate through selection
for i to n
  sound = sound[i]
  selectObject: sound
  @pitchTwoPass(floor_factor, ceiling_factor)
  pitch[i] = pitchTwoPass.id
endfor

# Select newly created objects
@clearSelection()
for i to n
  plusObject: pitch[i]
endfor
