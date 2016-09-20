#!/usr/bin/python
"""
    M_WEST   MATLAB Wind simulation application
    
"""
#
#  controle un seul run du modele MC2
#
import shutil
import os
import sys
verbose=True
THIS_SCRIPT = sys.argv[0]
#  requis pour M_WEST
CLASSE = sys.argv[1]
uselogfiles_ = sys.argv[2]   #pour ecrire des logfiles (0/1)
uselogfiles=bool(int(uselogfiles_))  # de string a entier
if verbose:
    print THIS_SCRIPT,' uselogfiles=',uselogfiles_,uselogfiles
#
WORKING_DIR = os.path.dirname(THIS_SCRIPT)
os.chdir(WORKING_DIR)
#
PARENT_DIR = os.path.dirname(WORKING_DIR)
COMMON_DIR = os.path.join(PARENT_DIR, r"CommonDirectory")
#
# Copy required files from common directory
GEOPHY_SRC = r"../CommonDirectory/geophy.fst"
GEOPHY_DEST = r"./process/geophy.fst"
shutil.copy(GEOPHY_SRC, GEOPHY_DEST)
#
CLIMATO_SRC = r"../CommonDirectory/climato.fst"
CLIMATO_DEST = r"./process/climato.fst"
shutil.copy(CLIMATO_SRC, CLIMATO_DEST)
#
INIT_SRC = r"../CommonDirectory/20010523.180000"
INIT_DEST = r"./process/pilot/20010523.180000"
shutil.copy(INIT_SRC, INIT_DEST)
#
LISTE_SRC = r"../CommonDirectory/liste_inputfiles_for_LAM"
LISTE_DEST = r"./process/liste_inputfiles_for_LAM"
shutil.copy(LISTE_SRC, LISTE_DEST)
#
MC2NTR = os.path.join(COMMON_DIR, r"RunMC2ntr.py")
MC2DM = os.path.join(COMMON_DIR, r"RunMC2dm.py")

#-----------------------------------------------------
# Set up environment variables
# mc2 constants data files
os.putenv(r'AFSISIO', os.path.join(WORKING_DIR , r'dfiles'))

#
# Run the preprocessor
##
if uselogfiles:
    print 'M_WEST.  Avec log file'
    LOG_FILENAME = CLASSE + '_mc2ntr.log'    #r"CAN1D000C10M_mc2ntr.log"
else:
    print 'M_WEST.  Sans log file'
    LOG_FILENAME = ''
#
os.system("\"" + MC2NTR + "\" " + LOG_FILENAME)
#
#
#
# Run MC2
##
LOG_FILENAME = CLASSE + '_mc2dm.log'    #r"CAN1D000C10M_mc2dm.log"
if uselogfiles:
    os.system("\"" + MC2DM + "\" " + LOG_FILENAME)
else:
    os.system("\"" + MC2DM )
#
#
##
#
# Clean up intermediate files
os.remove(r"./process/geophy.fst")
os.remove(r"./process/climato.fst")
os.remove(r"./process/pilot/20010523.180000")
os.remove(r"./process/liste_inputfiles_for_LAM")
os.remove(r"./process/geophy.bin")
os.remove(r"./process/helsol")
os.remove(r"./process/bm20010523.180000_000_000")
os.remove(r"./process/bm20010524.000000_e")
os.remove(r"./process/bm20010524.000000_s")
os.remove(r"./process/bm20010524.000000_n")
os.remove(r"./process/bm20010524.000000_w")
#
#
