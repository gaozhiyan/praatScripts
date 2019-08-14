# View each selected Sound (and TextGrid) object in turn
#
# The script allows for easy navigation between selected Sound
# objects, which is particularly useful when comparing specific
# features in each of them. If an equal number of TextGrid and
# Sound objects have been selected, they will be paired by name
# and viewed in unison.
#
# Written by Jose J. Atria (October 14, 2012)
# Last revision: July 10, 2014)
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

include ../../plugin_jjatools/procedures/check_directory.proc
include ../../plugin_jjatools/procedures/view_each.from_disk.proc

form View each (from disk)...
  sentence Read_from
  sentence Filename_regex (wav|TextGrid)$
endform

@checkDirectory(read_from$, "Read files from...")
read_from$ = checkDirectory.name$

@viewEachFromDisk(read_from$, filename_regex$, 1)
