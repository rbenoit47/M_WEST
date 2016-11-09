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

"""
import shutil
import time
import os
import argparse

#-----------------------------------------------------------------------
import sys
import string
#
args = argparse.ArgumentParser(description='Script pour generer la grille meso')
args.add_argument('-dotwest',dest='dotwest',required=True)
args.add_argument('-settings',dest='settings',required=True)
args.add_argument('-gridfile',dest='gridfile',required=True)
args.add_argument('-dx',dest='dx',type=float,required=True)
args.add_argument('-gridstring',dest='gridstring',required=True)
args.add_argument('-verbose',dest='verbose',type=int,default=0)
#
args.parse_args(namespace=args)
#
DOT_WEST = os.path.abspath(args.dotwest) 
MODEL_SETTINGS = args.settings           
OUTPUT_FILENAME = args.gridfile          
DX = args.dx                             
rawSTRING_2 = args.gridstring            
verbose=bool(args.verbose)
if verbose:
    print("rawstring=\n%s" % rawSTRING_2)
    print("dx=%f" % DX)
# traiter string_2
import re
#
a=re.sub('\s+',r'\\n ',rawSTRING_2)
b=re.sub('\'','\"',a)
c=re.sub('&grid','^&grid',b)
#
STRING_2=r"'"+c+r"'"
#
if verbose:
    print ("DotWest is %s" % DOT_WEST)
    print ("string_2: %s" % STRING_2)
    raw_input('enter to continue')
#
MODEL_GRID_EXEC= os.path.join(DOT_WEST ,  r"model_grid\model_grid.exe")
FSTADDINFO_EXEC= os.path.join(DOT_WEST ,  r"fstAddInfo\fstAddInfo.exe")
FSTADDGRID_EXEC= os.path.join(DOT_WEST ,  r"fstAddGrid\fstAddGrid.exe")
if not os.path.exists(FSTADDINFO_EXEC):
    print("manquant")
#
if verbose:
    print ("grid exec %s" % str(MODEL_GRID_EXEC) )
    print ("FSTADDINFO_EXEC %s" % str(FSTADDINFO_EXEC) )
    print ("FSTADDGRID_EXEC %s" % str(FSTADDGRID_EXEC) )
#
TAPE1=os.path.join(os.path.dirname(MODEL_GRID_EXEC), "tape1")
if os.path.exists(TAPE1):
    os.remove(TAPE1)
	
if verbose:
    print ("settings %s" % str(MODEL_SETTINGS) )
    print ("TAPE1 %s"  % str(TAPE1)  )
#
WORKING_MODEL_SETTINGS=os.path.join(os.path.dirname(MODEL_GRID_EXEC), "model_settings.cfg")
if os.path.exists(WORKING_MODEL_SETTINGS):
    os.remove(WORKING_MODEL_SETTINGS)
if verbose:
    print("wms=%s" % WORKING_MODEL_SETTINGS)
#
shutil.copy(MODEL_SETTINGS, WORKING_MODEL_SETTINGS)

RPN_STANDARD_FILE = TAPE1
#
FSTADDINFO_1_CMD = FSTADDINFO_EXEC+" '"+str(RPN_STANDARD_FILE)+"' "+"DX"+r" '"+str(DX)+r"'"  #STRING_1
if verbose:
    print("FSTADDINFO_1_CMD: %s" % FSTADDINFO_1_CMD)
#
FSTADDINFO_2_CMD = FSTADDINFO_EXEC+" '"+str(RPN_STANDARD_FILE)+"' "+"GRID_DEF"+" "+STRING_2
if verbose:
    print("FSTADDINFO_2_CMD %s" % FSTADDINFO_2_CMD)

#
FSTADDGRID_CMD = FSTADDGRID_EXEC+" '"+str(RPN_STANDARD_FILE)+"'"
if verbose:
    print("FSTADDGRID_CMD  : %s" %  FSTADDGRID_CMD )
#
(dirname, tmp) = os.path.split(OUTPUT_FILENAME)
(base, ext) = os.path.splitext(tmp)
LOG_FILENAME = os.path.join(dirname, base+".log")

os.chdir(os.path.dirname(MODEL_GRID_EXEC))
now = time.localtime()
print 'Directing screen output to log file:', LOG_FILENAME

stdin, stdout = os.popen4(MODEL_GRID_EXEC)
stdin.close()
file = open(LOG_FILENAME, 'w')
tmp = '  Job Start: ' + time.strftime("%Y/%m/%d %H:%M:%S", now) + '\n'
file.write(tmp)
if verbose:
    print "debug 1"
    file.write('debug 1\n')
file.writelines(stdout.readlines())
file.close()
stdout.close()

os.chdir(os.path.dirname(FSTADDGRID_EXEC))
# debug
stdin, stdout = os.popen4(FSTADDGRID_CMD)
stdin.close()
file = open(LOG_FILENAME, 'a')
if verbose:
    print "debug 2"
    file.write('debug 2\n')
file.writelines(stdout.readlines())
file.close()
stdout.close()

os.chdir(os.path.dirname(FSTADDINFO_EXEC))

stdin, stdout = os.popen4(FSTADDINFO_1_CMD)
stdin.close()
file = open(LOG_FILENAME, 'a')
if verbose:
    print "debug 3"
    file.write('debug 3\n')
file.writelines(stdout.readlines())
file.close()
stdout.close()

os.chdir(os.path.dirname(FSTADDINFO_EXEC))
stdin, stdout = os.popen4(FSTADDINFO_2_CMD)
stdin.close()
file = open(LOG_FILENAME, 'a')
if verbose:
    print "debug 4"
    file.write('debug 4\n')
file.writelines(stdout.readlines())
tmp = '  Job Finish: ' + time.strftime("%Y/%m/%d %H:%M:%S", time.localtime()) + '\n'
file.write(tmp)
file.close()
stdout.close()

# Move the file tape1 to it's final destination
if os.path.exists(OUTPUT_FILENAME):
    os.remove(OUTPUT_FILENAME)
shutil.move(RPN_STANDARD_FILE, OUTPUT_FILENAME)

print 'Done...'
raw_input('Press ENTER to exit')
