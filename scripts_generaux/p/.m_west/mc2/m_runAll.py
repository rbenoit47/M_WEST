#!/bin/python
"""
    M_WEST   MATLAB Wind simulation application
    
"""
#
#  Executer les runs du modele MC2

#
import os
import subprocess
import sys
import time
import signal
#  ajouts m_WEST:
import argparse
import glob
#
def handler_int(signum, frame):
    write_status(None, None, None, None, canceled=True)
    sys.exit(1)

signal.signal(signal.SIGINT, handler_int)

STATUS_FILENAME = os.path.splitext(sys.argv[0])[0]+".status"
ALIVE_FILENAME = os.path.splitext(sys.argv[0])[0]+".alive"
ALIVE = 0

#def start_run_py(climate_state, rerun=False):
def start_run_py(climate_state, verbose, uselogfiles, rerun=False):    
    #
    climate_state_path = os.path.join(rundir, climate_state)
    status_dot_path = os.path.join(climate_state_path, "status.dot")

    if os.path.isfile(status_dot_path):
        os.remove(status_dot_path)

    os.chdir(climate_state_path)
    if not rerun:
        print "-=  Processing "+climate_state+"...  =-"
    else:
        print "**  Rerun "+climate_state+"...  **"
    macmd="m_run.py " # +climate_state
    if verbose:
        print ["m_run.py",str(climate_state),str(uselogfiles)]
    process = subprocess.Popen(["m_run.py",str(climate_state),str(uselogfiles)], shell=True)   #on passe le climate_state avec "m_run.py" pour M_WEST

    return process


def wait(maxProcess, active_process, waitTime=2):
    done_process = []
    enter_loop = 0

    while (len(active_process) >= maxProcess and active_process != []) or (not enter_loop and active_process != []):
        write_alive()

        enter_loop=1
        tmp_process = []
        for p in active_process:
            if p.poll() == None:
                tmp_process.append(p)
            else:
                done_process.append(p)
        active_process = tmp_process
        if len(active_process) >= maxProcess:
            time.sleep(waitTime)

    return (active_process, done_process)


def write_status(toProcessList, toReprocessList, processingList, nbTotal, canceled=False, completed=False):
    global STATUS_FILENAME
    file = open(STATUS_FILENAME, 'w')
    if not canceled and not completed:
        file.write("Status=Running\n")
    elif canceled and not completed:
        file.write("Status=Canceled\n")
    elif not canceled and completed:
        file.write("Status=Completed\n")
    else:
        file.write("Status=It shouldn't happen")
        
    if not canceled:
        nbDone = nbTotal - len(toProcessList) - len(toReprocessList) - len(processingList)
        file.write("Progress="+str(nbDone)+"/"+str(nbTotal)+"\n")
        
    file.close()

def write_alive():
    global ALIVE_FILENAME
    global ALIVE

    file = open(ALIVE_FILENAME, "w")
    file.write(str(ALIVE)+"\n")
    file.close()
    
    ALIVE = ALIVE+1

def run_is_ok(climate_state):
    #
    climate_state_path = os.path.join(rundir, climate_state)
    status_dot_path = os.path.join(climate_state_path, "status.dot")

    status_abort=0
    startstep=0
    endstep=0
    status_ed=0

    if not os.path.isfile(status_dot_path):
        return 0

    with open(status_dot_path) as f:
        for line in f:
            if line.find("_status=ABORT") != -1:
                status_abort=1
            if line.find("_startstep=") != -1:
                startstep=1
            if line.find("_endstep=") != -1:
                endstep=1
            if line.find("_status=ED") != -1:
                status_ed=1
                
    if status_abort and startstep and endstep and status_ed:
        return 1
    else:
        return 0
#  M_WEST
args = argparse.ArgumentParser(description='Script pour controler les simulations meso MC2')
##args.add_argument('-dotwest',dest='dotwest',required=False,\
##                  help='La racine des repertoires de M_WEST')
##args.add_argument('-climatetable',dest='climatetable',required=False,\
##                  help='La table de frequence climatique fournie (soit WEST soit Atlas Canada)')
args.add_argument('-rundirectory',dest='rundirectory',required=True,\
                  help='Repertoire dexecution du MC2 (deja prepare)')
args.add_argument('-uselogfiles',dest='uselogfiles',required=False,type=int,default=0,\
                  help='Pour ecrire des log file par MC2 (0/1)')
args.add_argument('-verbose',dest='verbose',type=int,default=0,\
                  help='Controle de la verbosite (0/1)')
args.add_argument('-ClimateStatePrefix',dest='ClimateStatePrefix',default='CAN',\
                  help='Prefixe des noms de classe climatique')
#
args.parse_args(namespace=args)
#DOT_WEST = os.path.abspath(args.dotwest) 
#settings = args.settings
#grillefile = args.gridfile
#tableef = args.climatetable
#template = args.mc2template
verbose=bool(args.verbose)
rundirectory = args.rundirectory
rundirpath=os.path.abspath(rundirectory)   #.dirname(rundir)
rundir=rundirpath
uselogfiles=args.uselogfiles
ClimateStatePrefix=args.ClimateStatePrefix
#os.listdir(rundir)
#states=glob.glob(rundir+'/CAN*')  --> generaliser
print 'ClimateStatePrefix=',ClimateStatePrefix
#quit()
states=glob.glob(rundir+'/'+ClimateStatePrefix+'*')
nbstates=len(states)
if nbstates <= 0 :
    print 'Pas de classes climatiques a simuler. STOP'
    quit()
print 'states,nb=',states,nbstates

#
climate_states_to_process = []
##
#  une telle ligne par classe a traiter
for state in states:
    classe=os.path.basename(os.path.abspath(state))
    climate_states_to_process.append(classe)  #"CAN1D000C10M")
    print 'classe ',classe,' ajoutee'
#quit()
#
#

climate_states_to_rerun = []
climate_states_done = []

max_concurrent_process = int("4")
nb_climate_state = len(climate_states_to_process)


active_process = []
done_process = []
process_climateState_dict = dict()

while len(climate_states_to_process) > 0 or len(climate_states_to_rerun) > 0 or len(active_process) > 0:
    # Make sure we don't create more process than asked
    (active_process, done_process) = wait(max_concurrent_process, active_process)

    # Verify the status of each terminated process
    for p in done_process:
        cs = process_climateState_dict[p]
        if not run_is_ok(cs):
            climate_states_to_rerun.append(cs)

    # Give some feedback
    write_status(climate_states_to_process, climate_states_to_rerun, active_process, nb_climate_state)

    if len(climate_states_to_process) > 0 or len(climate_states_to_rerun) > 0 :
        # Get the climate state to process and run it
        if len(climate_states_to_rerun) > 0:
            climate_state = climate_states_to_rerun.pop(0)
            if verbose:
                print 'On re-lance MC2 sur classe=', climate_state
            process = start_run_py(climate_state, verbose, uselogfiles, rerun=True)  #M_WEST extra args
        else:
            climate_state = climate_states_to_process.pop(0)
            if verbose:
                print 'On lance MC2 sur classe=', climate_state
            process = start_run_py(climate_state, verbose, uselogfiles)  #M_WEST extra args

        # Monitor process
        active_process.append(process)
        process_climateState_dict[process] = climate_state
    else:
        time.sleep(2)


write_status(climate_states_to_process, climate_states_to_rerun, active_process, nb_climate_state, completed=True)

print 'Done...'
raw_input('Press ENTER to exit')
