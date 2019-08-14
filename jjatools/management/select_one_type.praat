# Selects one single type of object
#
# Written by Jose J. Atria
# Last revision: 17 February 2015
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../procedures/selection.proc

form Select one type...
  word Type Sound
  boolean Refine_current_selection yes
endform

@_IsValidType(type$)
if '_IsValidType.return'
  if refine_current_selection
    @refineToType(type$)
  else
    @selectType(type$)
  endif
else
  exit 'type$' is not a readable object type
endif
