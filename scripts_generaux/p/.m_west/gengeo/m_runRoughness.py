"""
    M_WEST   MATLAB Wind simulation application

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
    
"""
"""
    Python script to run Roughness.exe program

    Command line:
        m_RunRoughness.py geophy.fst geophyWithLU.fst True|False

        parameter 1: file containing GenGeo output (geophy file)
        parameter 2: file to write Roughness.exe output
        parameter 3: flag to direct Roughness.exe console output to a log file
        
    WEST System
    NRC/CHC 2005
"""
import shutil
import string
import os
import sys

#-------------------------------------------------------------------------------
# Set up variable defaults
THIS_SCRIPT = ' '               # The full path of this python script
GEOPHY_FILE = ' '               # geophy fst file containing gengeo output
GEOPHY_WITHLU_FILE = ' '        # new fst file containing Roughness output
WRITE_TO_LOGFILE = bool(False)  # Redirect Roughness output to a log file?
LOG_FILENAME = 'Roughness.log'
EXECUTABLE = 'Roughness.exe'

# Now parse the command line, of the form "thisScript.py geophy.fst geophyWithLU.fst True|False"
cmdLine = sys.argv
i = 0
for item in cmdLine:
    if i == 0:
        THIS_SCRIPT = item
    elif i == 1:
        GEOPHY_FILE = item
    elif i == 2:
        GEOPHY_WITHLU_FILE = item
    elif i == 3:
        if item.startswith('t') or item.startswith('T'):
            WRITE_TO_LOGFILE = bool(True)
    i = i+1

# BIN_DIR, should be where this script and all other executables
# associated with WEST are located. The leading and trailing " are
# to allow pathnames with spaces.
BIN_DIR = os.path.dirname(THIS_SCRIPT)
BIN_ROUGHNESS = '"' + os.path.join(BIN_DIR, EXECUTABLE) + '"'

LOG_FILENAME = os.path.join(os.path.dirname(GEOPHY_FILE), LOG_FILENAME)
INPUT_FILENAME = os.path.join(os.path.dirname(GEOPHY_WITHLU_FILE), 'Roughness_input.tmp')

#-------------------------------------------------------------------------------
# Function to run Roughness writing stdout to a log file
def RunWithLogFile(command):
    print '   Directing screen output to log file:', LOG_FILENAME
    
    stdin, stdout = os.popen4(command)
    stdin.close()

    file = open(LOG_FILENAME, 'w')
    file.writelines(stdout.readlines())
    file.close()
    stdout.close()

#-------------------------------------------------------------------------------
# Function to run Roughness with stdout to console
def RunWithoutLogFile(command):
    os.system(command)

################################################################################
# Main body of RunRoughness script
#
#-------------------------------------------------------------------------------
print 'Running - ', EXECUTABLE

# Create param file for Roughness program
# It contains 2 lines containing the input and output files
file = open(INPUT_FILENAME, 'w')
file.write(GEOPHY_FILE)
file.write('\n')
file.write(GEOPHY_WITHLU_FILE)
file.write('\n')
file.close()


# the command
COMMAND = BIN_ROUGHNESS + ' < ' + INPUT_FILENAME
print '  ', COMMAND

# Run with or without a log file
if WRITE_TO_LOGFILE:
    RunWithLogFile(COMMAND)
else:
    RunWithoutLogFile(COMMAND)

# Delete the temporary file
os.remove(INPUT_FILENAME)

print EXECUTABLE, ' Done...'
# raw_input('Press ENTER to exit')

