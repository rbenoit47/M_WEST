#!/usr/bin/python
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
    Python script to run gengeo.

    Command line:
        RunGenGeo.py parameters.nml True|False

        parameter 1: file containing GENGEO_CFGS namelist
        parameter 2: flag to direct gengeo305.exe console output to a log file
        
    WEST System
    NRC/CHC 2005
"""
import shutil
import string
import os
import sys
import tempfile

#-------------------------------------------------------------------------------
# Set up variable defaults
THIS_SCRIPT = ' '               # The full path of this python script
PARAM_FILE = ' '                # namelist file containing all gengeo parameters
WRITE_TO_LOGFILE = bool(False)  # Redirect gengeo output to a log file?
LOG_FILENAME = r'GenGeo.log'
EXECUTABLE = r'GenGeo.exe'
#
# Now parse the command line, of the form "thisScript.py param.nml True|False dirlog"
cmdLine = sys.argv
i = 0
for item in cmdLine:
    if i == 0:
        THIS_SCRIPT = item
    elif i == 1:
        PARAM_FILE = item
    elif i == 2:
        if item.startswith('t') or item.startswith('T'):
            WRITE_TO_LOGFILE = bool(True)
    elif i == 3:
        dirlog = item
    elif i == 4:
        DOT_WEST = item
    i = i+1

# BIN_DIR, should be where this script and all other executables
# associated with WEST are located. The leading and trailing " are
# to allow pathnames with spaces.
BIN_DIR = os.path.dirname(THIS_SCRIPT)
BIN_GENGEO = '"' + os.path.join(BIN_DIR, EXECUTABLE) + '"'
#
LOG_FILENAME = os.path.join(dirlog, LOG_FILENAME)

#-------------------------------------------------------------------------------
# Function to Run gengeo writing stdout to a log file
def RunWithLogFile(command):
    print '   Directing gengeo output to:', LOG_FILENAME
    
    stdin, stdout = os.popen4(command)
    stdin.close()

    file = open(LOG_FILENAME, 'w')
    file.writelines(stdout.readlines())
    file.close()
    stdout.close()

#-------------------------------------------------------------------------------
# Function to Run gengeo with stdout to console
def RunWithoutLogFile(command):
    os.system(command)

################################################################################
# Main body of RunGenGeo script
#
#-------------------------------------------------------------------------------
print 'Running...'

command = BIN_GENGEO + ' ' + PARAM_FILE
print '  ', command

if WRITE_TO_LOGFILE:
    RunWithLogFile(command)
else:
    RunWithoutLogFile(command)

print 'GenGeo Done...'
# raw_input('Press ENTER to exit')
