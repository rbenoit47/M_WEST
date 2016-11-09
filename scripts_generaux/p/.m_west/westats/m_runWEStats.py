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

"""
import os
import sys
import signal
import argparse

ALIVE_FILENAME = os.path.splitext(sys.argv[0])[0]+".alive"
#
args = argparse.ArgumentParser(description='Script pour generer la grille meso')
args.add_argument('-dotwest',dest='dotwest',required=True)
args.add_argument('-settings',dest='settings',required=True)
args.add_argument('-mesogeoin',dest='mesogeoin',required=True)
args.add_argument('-westatsout',dest='westatsout',required=True)
args.add_argument('-verbose',dest='verbose',type=int,default=0)
#
args.parse_args(namespace=args)
#
DOT_WEST = os.path.abspath(args.dotwest) 
MODEL_SETTINGS = args.settings
GEOFILE = args.mesogeoin
OUTPUT_FILENAME = args.westatsout
print "WEStats en demarrage ... attendre..."
raw_input('Press ENTER to continue')

def write_alive(msg):
    global ALIVE_FILENAME

    file = open(ALIVE_FILENAME, "w")
    file.write(msg+"\n")
    file.close()

def handler_int(signum, frame):
    write_alive("canceled")
    sys.exit(1)

signal.signal(signal.SIGINT, handler_int)

write_alive("running westats")
#
WESTATS_EXEC = os.path.join(DOT_WEST ,  r"westats\WEStats.exe")
NML_FILENAME = MODEL_SETTINGS

WESTATS_CMD=WESTATS_EXEC+" "+NML_FILENAME
os.chdir(os.path.dirname(WESTATS_EXEC))
os.system(WESTATS_CMD)


write_alive("running fstMoveInfo")
FSTMOVEINFO_EXEC = os.path.join(DOT_WEST , r'fstMoveInfo\fstMoveInfo.exe')
#
FST_INPUT = GEOFILE
FST_OUTPUT = OUTPUT_FILENAME

ETIKET = 'DX'
FSTMOVEINFO_CMD = FSTMOVEINFO_EXEC+" "+FST_INPUT+" "+FST_OUTPUT+" "+ETIKET
os.system(FSTMOVEINFO_CMD)


write_alive("completed")
print 'Done...'
raw_input('Press ENTER to exit')
