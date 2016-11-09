#!/bin/python
"""
    M_WEST   Wind simulation application
   
"""

""" Meso-Micro Coupler (MMC)
    WEST System

    Command line:
        RunMMC.py parameters.nml MS3R_ioInPlace sleepsecondes

        parameter 1: file containing namelists,
                        MMC_SETUP, SET_SWEEP, COUPLING

    Platform independant MMC script.
    Translated from korn script source code (NG_1_MMC.sh)
    written by R. Benoit RPN/CMC March 2003.

    NRC/CHC
    Yannick Tremblay, 2004
    Martin Serrer, 2005

    ETS 2015
    R Benoit
"""

import shutil
import string
import os
import sys
import time

#-----------------------------------------------------------------------
# Get the parameter file name, (first argument on the command line)
PARAM_FILE = sys.argv[1]
if len(sys.argv) > 2:
    MS3R_ioInPlace = bool(int(sys.argv[2]))
else:
    MS3R_ioInPlace = False
sleepsecondes = 0   # 0.2
##print 'MS3R_ioInPlace',MS3R_ioInPlace
##quit()

# Global variable for the param file contents these are required
# for creating other parameter files for mmc0, msplit, etc.
PARAM_FILE_CONTENTS = 'null'

#-----------------------------------------------------------------------
# Define Globals for executable modules
# BIN_DIR should be where this script and all other executables
# associated with WEST are located.
thisScript = sys.argv[0]
BIN_DIR = os.path.dirname(thisScript)

BIN_MMC0 = os.path.join(BIN_DIR, r'mmc0.exe')
BIN_MMC1 = os.path.join(BIN_DIR, r'mmc1.exe')
BIN_MS3R = os.path.join(BIN_DIR, r'ms3r.exe')
if MS3R_ioInPlace:
    BIN_MS3R = os.path.join(BIN_DIR, r'ms3rPlus.exe')

BIN_MICROSPLIT = os.path.join(BIN_DIR, r'msplit.exe')

#-----------------------------------------------------------------------
# Initialize Global variables for I/O FILES and DIRECTORIES
PATH_MESO_STATS = 'null'
PATH_MICRO_GEOPHY = 'null'
PATH_Z0_DEFINES = 'null'
PATH_MSMICRO_TILES = 'null'
PATH_MSMICRO_RESULTS = 'null'
WORKING_DIR = 'null'

#-----------------------------------------------------------------------
# Initialize other Global variables
#
#  if true run MSMicro otherwise just create directories and tiles
RUN_MSMICRO = bool(True)
#
# if false retain all tile directories otherwise just keep merged
# results file 'PATH_MSMICRO_RESULTS' and merged log files
DELETE_INTERMEDIATE_FILES = bool(True)
#
MERGE_VAR = 'EUMI'
I1 = int(-1)
I2 = int(-1)
J1 = int(-1)
J2 = int(-1)
ALPHA = int(-1)

LIR_FLAGS = 0
SWEEP_NODES = 1

#################################################################################
# Helper method that cleans up filenames
#--------------------------------------------------------------------------------
def _ValidFileName(fName):
    tmp = fName
    tmp = string.strip(tmp)         # get rid of trailing newlines
    tmp = string.strip(tmp, "'")    # get rid of single quotes
    tmp = string.strip(tmp, '"')    # get rid of double quotes
    tmp = string.strip(tmp)         # final strip of spaces
#    tmp = os.path.normpath(tmp)     # just to make sure 
    return tmp

#################################################################################
# Helper method that reads the contents of an ASCII file and returns everything
# in a variable
#--------------------------------------------------------------------------------
def _ReadParameterFile(paramFile):
    print ' '
    print 'Reading Parameter File: '
    print '    ', paramFile

    file = open(paramFile)
    inputLines = file.readlines()
    file.close()

    return inputLines

#################################################################################
# Helper method that extracts various parameters from the param file contents
# and sets the appropriate global variables
#--------------------------------------------------------------------------------
def _ParseParameterFile(inputLines):
    print ' '
    print 'Parsing Parameter File Contents: '

    global PATH_MESO_STATS
    global PATH_MICRO_GEOPHY
    global PATH_Z0_DEFINES
    global PATH_MSMICRO_TILES
    global PATH_MSMICRO_RESULTS
    global MERGE_VAR
    global I1, I2, J1, J2, ALPHA
    global RUN_MSMICRO
    global DELETE_INTERMEDIATE_FILES

    for line in inputLines:  
        line = string.strip(line)
        items = string.split(line, '=')
        keyword = string.lower(items[0])
        if keyword.startswith('path_meso_stats'):
            PATH_MESO_STATS = _ValidFileName(items[1])
        elif keyword.startswith('path_micro_geophy'):
            PATH_MICRO_GEOPHY = _ValidFileName(items[1])
        elif keyword.startswith('path_z0_defines'):
            PATH_Z0_DEFINES = _ValidFileName(items[1])
        elif keyword.startswith('path_msmicro_tiles'):
            PATH_MSMICRO_TILES = _ValidFileName(items[1])
        elif keyword.startswith('path_msmicro_results'):
            PATH_MSMICRO_RESULTS = _ValidFileName(items[1])
        elif keyword.startswith('merge_var'):
            MERGE_VAR = items[1]
            MERGE_VAR = string.strip(MERGE_VAR, "' ")     # get rid of single quotes
            MERGE_VAR = string.strip(MERGE_VAR, "' ")     # get rid of single quotes
            MERGE_VAR = string.strip(MERGE_VAR)
#            print MERGE_VAR
        elif keyword.startswith('i1'):
            I1 = int(items[1])
        elif keyword.startswith('i2'):
            I2 = int(items[1])
        elif keyword.startswith('j1'):
            J1 = int(items[1])
        elif keyword.startswith('j2'):
            J2 = int(items[1])
        elif keyword.startswith('alpha'):
            ALPHA = int(items[1])
        elif keyword.startswith('run_msmicro'):
            value = string.strip(items[1], " .")
            if value.startswith('F') or value.startswith('f'):
                RUN_MSMICRO = bool(False)
        elif keyword.startswith('delete_intermediate_files'):
            value = string.strip(items[1], " .")
            if value.startswith('F') or value.startswith('f'):
                DELETE_INTERMEDIATE_FILES = bool(False)
        elif keyword.startswith('keep_msmicro_tiles'):      # Old keyword
            value = string.strip(items[1], " .")
            if value.startswith('T') or value.startswith('f'):
                DELETE_INTERMEDIATE_FILES = bool(False)

    print 'Done Parsing Parameter File Contents'

#################################################################################
# Print the current directory/file setup
#--------------------------------------------------------------------------------
def _PrintSetup():
    print 'MESO-MICRO COUPLER (MMC)'
    print ' Settings:'
    print '  PARAM_FILE          =' , PARAM_FILE
    print '  WORKING_DIR         =' , WORKING_DIR
    print ' '
    print '  PATH_MESO_STATS     =' , PATH_MESO_STATS
    print '  PATH_MICRO_GEOPHY   =' , PATH_MICRO_GEOPHY
    print '  PATH_Z0_DEFINES     =' , PATH_Z0_DEFINES
    print '  PATH_MSMICRO_TILES  =' , PATH_MSMICRO_TILES
    print '  PATH_MSMICRO_RESULTS=' , PATH_MSMICRO_RESULTS
    print '  ALPHA               =' , ALPHA
    print '  MERGE_VAR           =' , MERGE_VAR
    print ' '
    print '  BIN_MMC0            =' , BIN_MMC0
    print '  BIN_MMC1            =' , BIN_MMC1
    print '  BIN_MICROSPLIT      =' , BIN_MICROSPLIT
    print '  BIN_MS3R            =' , BIN_MS3R
    print ' '
    print '  RUN_MSMICRO         =' , RUN_MSMICRO
    print '  DELETE_INTERMEDIATE_FILES  =' , DELETE_INTERMEDIATE_FILES

#################################################################################
# Initialize directories for the run
#
# 1. Creates the output and working directories
# 2. Copies all input files into the working directory
#--------------------------------------------------------------------------------
def _InitializeDirsAndFiles():
    print ' '
    print 'Initializing RUN...'

# Create the PATH_MSMICRO_TILES (output directory) if it doesn't exist
    if not os.path.exists(PATH_MSMICRO_TILES):
        print ' Makedir ', PATH_MSMICRO_TILES
        os.makedirs(PATH_MSMICRO_TILES)

# Create the WORKING_DIR if it doesn't exist
    if not os.path.exists(WORKING_DIR):
        print ' Makedir ', WORKING_DIR
        os.mkdir(WORKING_DIR)
                
# Copy all input files into the temporary working directory
    print ' Copy files to temporary working directory.'
    print '  Copy MesoScale Statistics file to mesoStats.fst (%i KB)' % (os.path.getsize(PATH_MESO_STATS)/1024)
    tmpName = os.path.join(WORKING_DIR, 'mesoStats.fst')
    shutil.copy(PATH_MESO_STATS, tmpName)

    print '  Copy MicroScale geophy to microGeophy.fst (%i KB)' % (os.path.getsize(PATH_MICRO_GEOPHY)/1024)
    tmpName = os.path.join(WORKING_DIR, 'microGeophy.fst')
    shutil.copy(PATH_MICRO_GEOPHY, tmpName)

    print '  Copy Z0 Definitions file to z0_define.txt'
    tmpName = os.path.join(WORKING_DIR, 'z0_define.txt')
    shutil.copy(PATH_Z0_DEFINES, tmpName)

    print '  Copy MMC settings file to mmc_settings.nml'
    tmpName = os.path.join(WORKING_DIR, 'mmc_settings.nml')
    shutil.copy(PARAM_FILE, tmpName)

# Save the param file in the tiles/output directory
#    paramFilename = os.path.split(PARAM_FILE)[1]
#    print '  Save', paramFilename, 'to tiles directory'
#    tmpName = os.path.join(PATH_MSMICRO_TILES, paramFilename)
#    shutil.copy(PARAM_FILE, tmpName)


#################################################################################
# MMC0 Produce Sweep Pos Rec and Tile Marker
#
# 1. Run MMC0.exe < mmc_settings.nml
# 2. Write/save mmc0.log.
#--------------------------------------------------------------------------------
def _MicroTileMarker():
    print ' '
    print 'Running MMC0...'
 	
    print ' Run %s < mmc_settings.nml' % BIN_MMC0
    sin, sout = os.popen2(BIN_MMC0 + '< mmc_settings.nml')
    sin.close()

    print ' Save mmc0 run log file: mmc0.log' 
    file = open(WORKING_DIR + '/mmc0.log', 'w+')
    file.writelines(sout.readlines())
    file.close()
    sout.close()

    shutil.move(WORKING_DIR+'/mmc0.log', PATH_MSMICRO_TILES+'/mmc0.log')
    
    print 'Done Running MMC0...'

#################################################################################
# ESTABLISH THE SWEEP DIRECTORIES
# Create the tiles directory structure.
# SWEEP_NODES OPTION 1 : A directory is created for each row (j index).
#   The tile for each row are stored in that directory with the
#   following syntax <PATH_MSMICRO_TILES>/%j/%i_FileName. 
# SWEEP_NODES OPTION 2: A directory is create for each row and column
#   combination (i, j indices) with following
#   syntax <PATH_MSMICRO_TILES>/%j/%i_FileName. 
#--------------------------------------------------------------------------------
def _MakeSweepDir():
    print ' '
    print 'Establish the Sweep Directories...'
    
    for j in range(J1, J2+1, ALPHA):
        ROW = '%s/%i' % (PATH_MSMICRO_TILES, j)

        if not os.path.exists(ROW):
            print ' Makedir: ', ROW
            os.mkdir(ROW)

        for i in range(I1,I2+1,ALPHA):
            if SWEEP_NODES == 2:
                ITAG= '%s/%i' % (ROW, i)
                if not os.path.exists(ITAG):
                    print ' Makedir: ', ITAG
                    os.mkdir(ITAG)
		    
    print 'Done Establishing the Sweep Directories...'

#################################################################################
# GEOPHY SPLITTER
# NOTE Assume topo in new format
# options for microsplit d_topo= 1: Micro-Meso terrain 0: full terrain
#--------------------------------------------------------------------------------
def _MicroSplit():
    print ''
    print 'Running MicroSplit...'

    print ' Creating input file:', WORKING_DIR + '/MicroSplit.nml'
    file = open(WORKING_DIR + '/MicroSplit.nml', 'w+')
    file.writelines(PARAM_FILE_CONTENTS)
    file.write("&msplit_nml\n")
    file.write("   workdir = '%s'\n" % PATH_MSMICRO_TILES)
    file.write("   file_micro = 'microGrid.fst'\n")
    file.write("   file_lu = 'microGeophy.fst'\n")
    file.write("   file_geophy = 'microGeophy.fst'\n")
    file.write("   file_meso = 'mesoStats.fst'\n")
    file.write("   lir_flags = %i\n"% LIR_FLAGS)
    file.write("   split = 1\n")
    file.write("   d_topo = 1\n")
    file.write("   intplgeo2micro = 'CUBIC'\n")
    file.write("   intplmeso2micro = 'LINEAR'\n")
    file.write("/\n")
    file.close()

    print ' Run %s < MicroSplit.nml' % BIN_MICROSPLIT
    sin, sout = os.popen2(BIN_MICROSPLIT + '< MicroSplit.nml')
    sin.close()

    print ' Save msplit run log file: MicroSplit.log' 
    file = open(WORKING_DIR + '/MicroSplit.log', 'w+')
    file.writelines(sout.readlines())
    file.close()
    sout.close()   
    shutil.move(WORKING_DIR+'/MicroSplit.log', PATH_MSMICRO_TILES+'/MicroSplit.log')

 #   microFile = os.path.join(WORKING_DIR, 'microGrid.fst')
 #   print ' Save', PATH_MSMICRO_TILES+'/microGrid.fst'
 #   if not os.path.exists(microFile):
 #       print '  ERROR: Tile: ', microFile, 'does not exist.'
 #       print '            Check: MicroSplit.log for more information.'
 #   else:
 #       shutil.copy(microFile, PATH_MSMICRO_TILES+'/microGrid.fst')
        
    print 'DONE Running MicroSplit...'

#################################################################################
# watch Flow file size
# this Flow file, created by each run of MSMicro (ms3r)
# is the basic output of the MMC
# On virtual machines, it occasionally gets truncated during the creation/move process
# to avoid this error, the _watchFlowSize function has been introduced
# and is called at each tile of the MMC sweep
#--------------------------------------------------------------------------------

def _watchFlowSize(FlowFile, CorrectSize):
    # WORKING_DIR + '/'+MSMASTER_FLOW, FLOW_filesize
    #statinfo=os.stat(FlowFile)
    #tile_size=statinfo.st_size
    tile_size=0
    sum=0
    sleepmax=30
    sleeptime=0.1   #0.5
    notok=True
    growing=True
    old_size=tile_size
    while sum < sleepmax  and notok:  # and growing
        time.sleep(sleeptime)
        statinfo=os.stat(FlowFile)
        new_size=statinfo.st_size
        tile_size=new_size
        growing= new_size > old_size
        #if not new_size > old_size:
        #    growing=False
        old_size=new_size
        print 'watching Flow...',tile_size,CorrectSize,sum,growing
        #time.sleep(sleeptime)
        sum=sum+sleeptime
        if not tile_size < CorrectSize:
            notok=False
    #tile_size=CorrectSize
    verdict=not notok
    return verdict

def _MS3R_legacy(BIN_MS3R,WORKING_DIR,ITAG,MSMASTER_FLOW):
    # facon traditionnelle (WEST-OSE) d'executer MSMicro
    print 'legacy'
    sin, sout = os.popen2(BIN_MS3R)
    sin.flush()
    sin.close()
    sout.flush() #RB
    # Save the run log
    file = open(WORKING_DIR + '/ms3r.log', 'w+')
    file.writelines(sout.readlines())
    os.fsync(file) #RB
    file.close()		
    sout.close()
    ms3rLogFile = ITAG + 'ms3r.log'
    shutil.move(WORKING_DIR + '/ms3r.log', ms3rLogFile)		
    # Save the param file
    shutil.move(WORKING_DIR + '/MSMASTER.PAR', ITAG+'MSMASTER.PAR')

##    FlowFile=WORKING_DIR + '/'+MSMASTER_FLOW
##    if  FLOW_filesize == 0:
##        time.sleep(2)
##        statinfo=os.stat(FlowFile)
##        FLOW_filesize=statinfo.st_size
##        print 'Flow file size:',FLOW_filesize
##        time.sleep(1)
##    else:
##        if not _watchFlowSize(FlowFile, FLOW_filesize):
##            print 'Incorrect Flow file size', tile_size
##            raw_input('Press ENTER to exit')
##            return False

    # Save the MSMicro output
    if os.path.exists(MSMASTER_FLOW):
        shutil.move(WORKING_DIR + '/'+MSMASTER_FLOW, ITAG+MSMASTER_FLOW)
    else:
        print '  ERROR: File ', MSMASTER_FLOW, 'not found.'
        print '            Check:', ms3rLogFile, 'for more information.'
        return False

    
    return True
"""
../../ms3rPlusargs/ms3r.exe <62/50_MSMASTER.PAR >62/50_ms3rtest.log 2>err.log -topofst 62/50_ms3rTopo.fst -flowfst 62/50_FlowTest.fst

"""
def _MS3R_inplace(BIN_MS3R,PATH_MSMICRO_TILES,WORKING_DIR,ITAG,MSMASTER_TOPO,MSMASTER_FLOW):
    print 'inplace'
    # facon nouvelle (surtout pour les machines virtuelles) d'executer MSMicro
    os.chdir(PATH_MSMICRO_TILES)
    #  a la fin revenir au WORKING_DIR
    # BIN_MMC0 = os.path.join(BIN_DIR, r'mmc0.exe')
    ms3rParFile = os.path.normpath(WORKING_DIR + '/MSMASTER.PAR')
    ms3rLogFile = os.path.normpath(ITAG + 'ms3r.log')
    errFile = os.path.normpath(ITAG + 'err.log')
    ms3rTopoFile =os.path.normpath(ITAG + MSMASTER_TOPO)
    ms3rFlowFile =os.path.normpath(ITAG+ MSMASTER_FLOW)
    commande=BIN_MS3R + ' <' + ms3rParFile + ' >' + ms3rLogFile + ' 2>' + errFile + ' -topofst ' \
              + ms3rTopoFile + ' -flowfst ' + ms3rFlowFile
    #         + ITAG + MSMASTER_TOPO + ' -flowfst ' + ITAG + MSMASTER_FLOW
    #
    #print 'execute: ',commande
    os.system(commande)
    #
    # Save the param file
    shutil.move(WORKING_DIR + '/MSMASTER.PAR', ITAG+'MSMASTER.PAR')
    #
##    FlowFile=ITAG +MSMASTER_FLOW
##    if  FLOW_filesize == 0:
##        time.sleep(2)
##        statinfo=os.stat(FlowFile)
##        FLOW_filesize=statinfo.st_size
##        print 'Flow file size:',FLOW_filesize
##        time.sleep(1)
##    else:
##        if not _watchFlowSize(FlowFile, FLOW_filesize):
##            print 'Incorrect Flow file size', tile_size
##            raw_input('Press ENTER to exit')
##            return False
    #
    os.chdir(WORKING_DIR)
    return True

#################################################################################
# MESO SWEEP LOOP.
# Run MSMicro Process for all tiles
#--------------------------------------------------------------------------------
def _ProcessSweep():
    print ' '
    print 'Run MSMicro Process for all tiles...'

    MSMASTER_TOPO = 'ms3rTopo.fst'
    MSMASTER_FLOW = 'ms3rFlow.fst'
    FLOW_filesize=0

    for j in range(J1, J2+1, ALPHA):
        ROW = '%s/%i' % (PATH_MSMICRO_TILES, j)
        for i in range(I1,I2+1,ALPHA):

            if SWEEP_NODES == 1:
                ITAG = '%s/%i_' % (ROW, i)	
            elif SWEEP_NODES == 2:
                ITAG= '%s/%i/' % (ROW, i)

            srcMasterTopo = '%s%s' % (ITAG,MSMASTER_TOPO)
            #RB variable inutile: tarMasterFlow = '%s%s' % (ITAG,MSMASTER_FLOW)

            print ' Processing Tile', i, j
            #sleepsecondes=0.2
	    #print ' sleep de %i secondes... msmicro bug??' % sleepsecondes  #RB
	    #time.sleep(sleepsecondes)  #RB
	    print time.ctime()
            if not os.path.exists(srcMasterTopo):
                print '  ERROR: Tile: ', srcMasterTopo, 'does not exist.'
                print '            Check: MicroSplit.log for more information.'
                return False
            else:
                shutil.copy(srcMasterTopo, WORKING_DIR+'/'+MSMASTER_TOPO)

		# RUN MMC1 -------------------------------------
                sin, sout = os.popen2(BIN_MMC1)
                sin.write('%i %i\n' % (i, j))
                sin.flush()
                sin.close()
                sout.flush() #RB
                # os.fsync() #RB

                # Save the run log
                file = open(WORKING_DIR + '/mmc1.log', 'w+')
                file.writelines(sout.readlines())
                os.fsync(file) #RB
                file.close()
                sout.close()
                mmc1LogFile = ITAG + 'mmc1.log'
                shutil.move(WORKING_DIR + '/mmc1.log', mmc1LogFile)

                # Check the mmc1 output
                if not os.path.exists('MSMASTER.PAR'):
                    print '  ERROR: File MSMASTER.PAR not found.'
                    print '            Check:', mmc1LogFile, 'for more information.'
                    return False

                #sleepsecondes=1
                #print ' sleep de %i secondes... msmicro bug??' % sleepsecondes  #RB
                #time.sleep(sleepsecondes)  #RB

 		# RUN MSMICRO --------------------------------------
                if MS3R_ioInPlace:
                    ms3rStatus = _MS3R_inplace \
                                 (BIN_MS3R,PATH_MSMICRO_TILES,WORKING_DIR,ITAG,MSMASTER_TOPO,MSMASTER_FLOW)
                else:
                    ms3rStatus = _MS3R_legacy(BIN_MS3R,WORKING_DIR,ITAG,MSMASTER_FLOW)
                if not ms3rStatus:
                    return False
                #
##                sin, sout = os.popen2(BIN_MS3R)
##                sin.flush()
##                sin.close()
##                sout.flush() #RB
##                
##                # Save the run log
##                file = open(WORKING_DIR + '/ms3r.log', 'w+')
##                file.writelines(sout.readlines())
##                os.fsync(file) #RB
##                file.close()		
##                sout.close()
##                ms3rLogFile = ITAG + 'ms3r.log'
##                shutil.move(WORKING_DIR + '/ms3r.log', ms3rLogFile)		
##
##                # Save the param file
##                shutil.move(WORKING_DIR + '/MSMASTER.PAR', ITAG+'MSMASTER.PAR')
                #  control FLOW_filesize
##                FlowFile=WORKING_DIR + '/'+MSMASTER_FLOW
##                if  FLOW_filesize == 0:
##                    time.sleep(2)
##                    statinfo=os.stat(FlowFile)
##                    FLOW_filesize=statinfo.st_size
##                    print 'Flow file size:',FLOW_filesize
##                    time.sleep(1)
##                else:
##                    if not _watchFlowSize(FlowFile, FLOW_filesize):
##                        print 'Incorrect Flow file size', tile_size
##                        raw_input('Press ENTER to exit')
##                        return False
##
##                # Save the MSMicro output
##                if os.path.exists(MSMASTER_FLOW):
##                    shutil.move(WORKING_DIR + '/'+MSMASTER_FLOW, ITAG+MSMASTER_FLOW)
##                else:
##                    print '  ERROR: File ', MSMASTER_FLOW, 'not found.'
##                    print '            Check:', ms3rLogFile, 'for more information.'
##                    return False

    print 'Done Processing MESO SWEEP Loop ...'
    return True

#################################################################################
# MERGING ALL TILES 
#
#--------------------------------------------------------------------------------
def _MicroMerge():
    print ' '
    print 'Running MicroSplit (MERGE) ...'
    shutil.copy(WORKING_DIR+'/microGrid.fst', WORKING_DIR+'/microResults.fst')

    print ' Creating input file:', WORKING_DIR + '/MicroMerge.nml'
    file = open(WORKING_DIR + '/MicroMerge.nml', 'w+')
    file.writelines(PARAM_FILE_CONTENTS)
    file.write("&msplit_nml\n")
    file.write("   workdir = '%s'\n" % PATH_MSMICRO_TILES)
    file.write("   file_micro = 'microResults.fst'\n")
    file.write("   split = 0\n")
    file.write("   d_topo = 0\n")
    file.write("   lir_flags = %i\n"% LIR_FLAGS)
    file.write("   merge_var = '%s'\n" % MERGE_VAR)
    file.write("/\n")	
    file.close()

    print ' Run %s < MicroMerge.nml' % BIN_MICROSPLIT
    sin, sout = os.popen2(BIN_MICROSPLIT + '< MicroMerge.nml')
    sin.close()   

    print ' Save msplit (MERGE) run log file: MicroMerge.log' 
    file = open(WORKING_DIR + '/MicroMerge.log', 'w+')
    file.writelines(sout.readlines())
    file.close()
    sout.close()   
    shutil.move(WORKING_DIR + '/MicroMerge.log', PATH_MSMICRO_TILES + '/MicroMerge.log')

    print ' Save microResults.fst'

    shutil.move(WORKING_DIR + '/microResults.fst', PATH_MSMICRO_RESULTS)
#    shutil.move(WORKING_DIR + '/microResults.fst', PATH_MSMICRO_TILES + '/microResults.fst')
    
    print 'Done Running MicroSplit (MERGE) ...'

#################################################################################
# Clean up:
#   1. the temporary working directory
#   2. all tile directories
#--------------------------------------------------------------------------------
def _CleanupDirs():
    print 'Runnning _CleanupDirs()'
    os.chdir('..')  # we can't delete the directory if we're in it! So get out!
    
# 1. the working directory
    if os.path.exists(WORKING_DIR):
        print ' Remove working dir' + WORKING_DIR
        shutil.rmtree(WORKING_DIR, True)

# 2. the tile directories
    for j in range(J1, J2+1, ALPHA):
        ROW = '%s/%i' % (PATH_MSMICRO_TILES, j)
        if os.path.exists(ROW):
            print ' Remove tile directory: ', ROW
            shutil.rmtree(ROW, True)
        for i in range(I1,I2+1,ALPHA):
            if SWEEP_NODES == 2:
                ITAG= '%s/%i' % (ROW, i)
                if os.path.exists(ITAG):
                    print ' Remove tile directory: ', ITAG
                    shutil.rmtree(ITAG, True)


#################################################################################
# Main body of MesoMicroCoupler script
#
#--------------------------------------------------------------------------------

# Read the parameter file contents
PARAM_FILE_CONTENTS = _ReadParameterFile(PARAM_FILE)
_ParseParameterFile(PARAM_FILE_CONTENTS)

# Set working dir inside of the Tiles directory since
# we should know at this point that is is a valid path and we can write to it
WORKING_DIR = PATH_MSMICRO_TILES + '/MMC_WORKING_DIR'

# Show what we've got
_PrintSetup()

# Initialization
_InitializeDirsAndFiles()

# Change the current directory to WORKING_DIR
print 'Chdir ', WORKING_DIR
os.chdir(WORKING_DIR)

# Run MMC0, Creates Tile indeces, Create directories
_MicroTileMarker()
_MakeSweepDir()

# Run MSPLIT, creates a FST grid file for every Tile
_MicroSplit()

#  If the RUN_MSMICRO flag is set then run the micro scale model
# on every tile otherwise we're done.
#  This allows us to look at the layout of the tiles
# before actually running the microscale model.
EXIT_MESSAGE = 'MMC Done...'
if RUN_MSMICRO:
    if _ProcessSweep():    # Process every tile
        _MicroMerge()      # if successful then merge all results
    else:
        EXIT_MESSAGE = 'Please correct ERROR and try again.'
else:
    EXIT_MESSAGE = 'MMC Done (MSMicro was not run)...'

# Clean up if required, Only clean up if we ran MSMicro
if RUN_MSMICRO:
    if DELETE_INTERMEDIATE_FILES:
        _CleanupDirs()

# Done
print ' '
print EXIT_MESSAGE
raw_input('Press ENTER to exit')







