# Count points in TextGrid tier within specified range
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

form Get points in range...
  integer Tier 1
  real    left_Start 0
  real    right_End 0 (= all)
endform

include ../procedures/count_points_in_range.proc

interval_tier = Is interval tier: tier

if !interval_tier

  start = left_Start
  end = right_End

  @countPointsInRange(tier, start, end)

  writeInfoLine: countPointsInRange.return
else
  exitScript: "Tier must be a point tier"
endif
