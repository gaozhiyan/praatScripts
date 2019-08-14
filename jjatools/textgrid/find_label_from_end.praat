# Find TextGrid label from end
#
# Author:  Jose Joaquin Atria
# Initial release: October 24, 2014
# Last modified:   October 24, 2014
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

form Find label from end...
  integer  Tier 1
  sentence Target
  integer  Before 0
endform

include find_item_from.proc

@findFromEnd(tier, target$, before)
