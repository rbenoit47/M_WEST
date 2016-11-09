#!/bin/python
"""
    WEST   Wind simulation application
    Copyright (C) 2010-2011  "Her Majesty the Queen in Right of Canada"
    Contact: service.rpn@ec.gc.ca

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
    Python script to run the MC2 Preprocessor.

    Command line:
        RunMC2ntr.py <logFile>

        parameter 1: the name of a log file where stdout/stderr is written
       
    WEST System
    NRC/CHC 2005
"""
import shutil
import string
import os
import sys

#-----------------------------------------------------
# Set up variables
THIS_SCRIPT = ''
LOG_FILENAME = ''
EXECUTABLE = 'mc2ntr'



# Parse the command line, looking for a log filename
cmdLine = sys.argv
i = 0
for item in cmdLine:
    if i == 0:
        THIS_SCRIPT = item
    elif i == 1:
        LOG_FILENAME = item
    i = i+1

# BIN_DIR, should be where this script and all other executables
# associated with WEST are located.
BIN_DIR = os.path.dirname(THIS_SCRIPT)

#-----------------------------------------------------
# Set up environment variables
# mc2 constants data files
#os.putenv(r'AFSISIO', os.path.join(BIN_DIR, r'dfiles'))

# Current working directory
# mc2 looks for input in "rep_from_which_model_is_launched/process" and
# writes results to "rep_from_which_model_is_launched/output"
WORKING_DIR = os.getcwd()
os.putenv(r'rep_from_which_model_is_launched', WORKING_DIR)

################################################################################
# Main body of RunMC2ntr script
print 'Running MC2 Preprocessor - ', EXECUTABLE

# Run command. The leading and trailing " are to allow pathnames with spaces.
COMMAND = '"' + os.path.join(BIN_DIR, EXECUTABLE) + '"'

# Run with or without a log file
if LOG_FILENAME == '':
    os.system(COMMAND)
else:
    print 'Directing screen output to log file:', LOG_FILENAME
    stdin, stdout = os.popen4(COMMAND)
    stdin.close()
    file = open(LOG_FILENAME, 'w')
    file.writelines(stdout.readlines())
    file.close()
    stdout.close()

print ' '
print EXECUTABLE, ' Done...'
