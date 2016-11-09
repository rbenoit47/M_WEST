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
import shutil
import os
import argparse
#
args = argparse.ArgumentParser(description='Script pour executer gengeo sur la grille meso')
args.add_argument('-dotwest',dest='dotwest',required=True)
args.add_argument('-settings',dest='settings',required=True)
args.add_argument('-gridfile',dest='gridfile',required=True)
args.add_argument('-geofile',dest='geofile',required=True)
args.add_argument('-verbose',dest='verbose',type=int,default=0,choices=[0, 1])
args.add_argument('-logfile',dest='logfile',type=int,default=0,choices=[0, 1])
#
args.parse_args(namespace=args)
#
dotwest = args.dotwest
DOT_WEST = os.path.abspath(dotwest) 
GENGEO_NML = args.settings           
GENGEO_OUT = args.geofile
verbose= bool(args.verbose)
DOLOGFILE = bool(args.logfile)
gridfile = args.gridfile
#
if verbose:
    print ("DOT_WEST is %s" % DOT_WEST)
    print ("dotwest is %s" % dotwest)
#
# Run gengeo
GENGEO_SCRIPT = os.path.join(DOT_WEST, r'gengeo\m_runGengeo.py')
dirlog=os.path.dirname(GENGEO_OUT)
#
if DOLOGFILE:
    GENGEO_CMD = GENGEO_SCRIPT + ' ' + GENGEO_NML  + ' True' + ' ' + dirlog + ' ' + DOT_WEST 
else:
    GENGEO_CMD = GENGEO_SCRIPT + ' ' + GENGEO_NML  + ' False' + ' ' + dirlog+ ' ' + DOT_WEST  
#
status=os.system(GENGEO_CMD)
if status != 0 :
    print("Erreur d execution de gengeo. quit.")
    quit(status)
else:
    print("status=%i\n" % status)
    #quit(status)
        
# Move gengeo output file to intermediate file.
#
ROUGHNESS_IN = GENGEO_OUT+'.tmp'
#
shutil.move(GENGEO_OUT, ROUGHNESS_IN)
#

# Run roughness, use gengeo output file as input
ROUGHNESS_OUT = GENGEO_OUT
ROUGHNESS_SCRIPT =  os.path.join(DOT_WEST,  r'gengeo\m_runRoughness.py' )
##
ROUGHNESS_CMD = ROUGHNESS_SCRIPT+' '+ROUGHNESS_IN+' '+ROUGHNESS_OUT+' '+ str(DOLOGFILE) #'  False'
#
#
os.system(ROUGHNESS_CMD)
if verbose:
    print("Roughness termine.\n")

FSTMOVEINFO_EXEC=  os.path.join(DOT_WEST,  r'fstMoveInfo\fstMoveInfo.exe' )
FST_INPUT=gridfile      
FST_OUTPUT=GENGEO_OUT

ETIKET='DX'
FSTMOVEINFO_CMD=FSTMOVEINFO_EXEC+" "+FST_INPUT+" "+FST_OUTPUT+" "+ETIKET
os.system(FSTMOVEINFO_CMD)
if verbose:
    print 'fstmoveinfo execute pour DX'

ETIKET='GRID_DEF'
FSTMOVEINFO_CMD=FSTMOVEINFO_EXEC+" "+FST_INPUT+" "+FST_OUTPUT+" "+ETIKET
os.system(FSTMOVEINFO_CMD)
if verbose:
    print 'fstmoveinfo execute pour GRID_DEF'

print 'Done...'
raw_input('Press ENTER to exit')
# Clean up intermediate gengeo output file and this script.
os.remove(ROUGHNESS_IN)
#
