"""
    M_WEST   MATLAB Wind simulation application
    
"""
#
#  Prepare les runs du modele MC2
#  generer les model settings du mc2
#
import argparse
import re
import os
import sys
import shutil
#
args = argparse.ArgumentParser(description='Script pour preparer les simulations meso MC2')
args.add_argument('-dotwest',dest='dotwest',required=True,\
                  help='La racine des repertoires de M_WEST')
args.add_argument('-settings',dest='settings',required=True,\
                  help='La configuration MC2 preparee avec Matlab')
args.add_argument('-gridfile',dest='gridfile',required=True,\
                  help='La configuration de grille meso preparee avec Matlab')
args.add_argument('-climatetable',dest='climatetable',required=True,\
                  help='La table de frequence climatique fournie (soit WEST soit Atlas Canada)')
args.add_argument('-mc2template',dest='mc2template',required=False,\
                  default='template.model_settings.nml', \
                  help='Le gabarit de configuration MC2 qui sera ajuste pour chaque classe climatique')
args.add_argument('-rundirectory',dest='rundirectory',required=True,\
                  help='Repertoire dexecution du MC2 (vide)')
args.add_argument('-verbose',dest='verbose',type=int,default=0,\
                  help='Controle de la verbosite (0/1)')
#
args.parse_args(namespace=args)
#
DOT_WEST = os.path.abspath(args.dotwest) 
settings = args.settings
grillefile = args.gridfile
tableef = args.climatetable
template = args.mc2template
verbose=bool(args.verbose)
rundir = args.rundirectory
#
#CommonDirectory=r'M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\p\.m_west\mc2\CommonDirectory'
CommonDirectory=os.path.join(DOT_WEST,'mc2\CommonDirectory')
template=os.path.join(DOT_WEST,'mc2',template)
mc2file=settings
#
# get working directory: os.getcwd()
# faire un ls: os.listdir(....)

if os.path.exists(rundir) and len(os.listdir(rundir)) == 0:
    os.rmdir(rundir)
    shutil.copytree(CommonDirectory,os.path.join(rundir,'CommonDirectory'))
else:
    print ('rundir:%s inexistant ou non vide. stop' % rundir)
    quit()
#
f = open(template, 'r') 
toutf=f.read()
f.close()
#
Here=os.getcwd()
#
g = open(mc2file, 'r')
gr = open(grillefile,'r')
#
#
toutg=g.read()
t=open(tableef,'r')
table=t.readlines()  #un element de liste par ligne
if verbose:print table[3]
grille=gr.read()
#
grillel=re.split(r'\n',grille)
#
i=0;i1=-1;i2=-1
i_typ_S=-1;i_Grd_dy=-1
for ligne in grillel:
    if r'&grid' in ligne and i1 <0:
        i1=i
        if verbose:print i,ligne
    if r'/' in ligne and i2 <0:
        i2=i
        if verbose:print i,ligne
    #  pour eliminer ligne indesirable: 'Grd_typ_S' et 'Grd_dy'
    if 'Grd_typ_S' in ligne:
        i_typ_S=i
    if 'Grd_dy' in ligne:
        i_Grd_dy=i
    i=i+1
#  eliminer lignes indesirables:
if i_typ_S >= 0 :
    grillel[i_typ_S]=' '
if i_Grd_dy >= 0 :
    grillel[i_Grd_dy]=' '
#
if verbose:print 'gridnml=\n',grillel[i1:i2+1]
#
gridnml=grillel[i1:i2+1]
gridnml='\n'.join(gridnml)
#  changer nom du namelist de &grid a &grille
gridnml=re.sub(r'&grid',r'&grille',gridnml)
#
if verbose:print gridnml
#quit()
#

tokens=['step','tstep','sample','sample','sample','sample',          'nlvs','nlvspbl','vmh_ndt']
#targets=['grdt','gnnt','gndstat','gnpstat','nstepsor_d','nstepsor_p','gnk','gnnpbl','vmh_ndt']
i=0
for token in tokens:
    if verbose:print token
    hit=re.search(token+'[ 0-9\.]+',toutg)
    if verbose:print 'hit='+hit.group(0)
    pair=re.split('\W+',hit.group())
    if verbose:print 'value='+pair[1]
    toutf=re.sub('<'+pair[0]+'>',pair[1],toutf)
    #
    i=i+1
if verbose:print '\ntoutf=\n',toutf
#
if verbose:print '\ntoutg=\n',toutg
#
#  generer un fichier de settings par climate state
#
hits=re.findall('CLIMATE_STATE'+'[A-Z0-9 \t]+',toutg)
print ('\n\nClasses climatiques a traiter...\n\n')
for hit in hits:
    print hit
hitsAO=re.findall('ADVANCED_OPTION'+'[A-Za-z0-9\._=, \'-:\t]+',toutg)
print ('\n\nOptions avancees...\n\n')
for hit in hitsAO:
    print hit
#
if verbose:
    print hits, len(hits)
    print hitsAO, len(hitsAO)
for i in range(len(hitsAO)):
    #AO=re.split('\t| |\s!<,|=',hitsAO[i])   # pas de =.  enlever. sept 2015
    #AO=re.split('\t| |\s!<,|',hitsAO[i])     # pas de =. sept 2015
    AO=re.split('\t| |\s!<,|=',hitsAO[i])    # oct 2017 on remet le caractere =
    #2017 mais il faut editer value pour y remplacer = par :

    tokens=re.split('\.',AO[1])
    token=tokens[1]
    value='';value=value.join(AO[2:])
    value=re.sub('=',':',value) #2017
    if verbose:
        print token,'||',value
        print '==========',AO 
    #
    # appliquer dans toutf
    #
    str1=r'.+'+token+r'.+'
    str2=r'  '+token+' = '+value
    toutf=re.sub(str1,str2,toutf)
    if verbose: print str1,'\n',str2
if verbose: print toutf
#
ltable=len(table)
#
# ici on genere le repertoire dexecution pour chaque classe climatique
#
rundircsTemplate=os.path.join(DOT_WEST,'mc2','ClimateClassTemplate')
for hit in hits:
    #pair= re.split('\t',hit)  #attention tab et espace possibles
    pair= re.split('\t+\s+',hit)
    if verbose:print pair[1]
    if verbose:print 'longueur de table=',ltable

for hit in hits:
    #pair= re.split('\t',hit)
    pair= re.split('\t+\s+',hit)  #mix de tab et blancs
    cs=pair[1]
    #
    print ('\nConstruction du repertoire MC2 pour la classe:%s\n' % cs)
    #
    rundircs=os.path.join(rundir,cs)
    shutil.copytree(rundircsTemplate,rundircs)
    #
    #
    if verbose:print 'climate state target=',cs
    for state in table[2:ltable-1]:
        elems=re.split('\s+',state)  #au moins un blanc
        if cs in state:
            cs_values=elems
            if verbose:print state
            if verbose:print 'uu1=',elems[7]
    #
    csdir=rundircs   #os.path.join(Here,cs)
    if not os.path.exists(csdir):
        os.mkdir(csdir)
    cs_file=os.path.join(csdir,'process',r'model_settings.nml')  #cfg')
    #
    #  <climateStateId>
    #
    uu1=cs_values[7]; uu2=cs_values[8]; uu3=cs_values[9];uu4=cs_values[10]
    vv1=cs_values[11];vv2=cs_values[12];vv3=cs_values[13];vv4=cs_values[14]
    tt1=cs_values[15];tt2=cs_values[16];tt3=cs_values[17];tt4=cs_values[18]
    #
    toutcs=toutf  #une copie fraiche
    toutcs=re.sub('<climateStateId>',cs,toutcs)
    toutcs=re.sub('<uu1>',str(uu1),toutcs)
    toutcs=re.sub('<uu2>',str(uu2),toutcs)
    toutcs=re.sub('<uu3>',str(uu3),toutcs)
    toutcs=re.sub('<uu4>',str(uu4),toutcs)
    toutcs=re.sub('<vv1>',str(vv1),toutcs)
    toutcs=re.sub('<vv2>',str(vv2),toutcs)
    toutcs=re.sub('<vv3>',str(vv3),toutcs)
    toutcs=re.sub('<vv4>',str(vv4),toutcs)
    toutcs=re.sub('<tt1>',str(tt1),toutcs)
    toutcs=re.sub('<tt2>',str(tt2),toutcs)
    toutcs=re.sub('<tt3>',str(tt3),toutcs)
    toutcs=re.sub('<tt4>',str(tt4),toutcs)
    #
    #  grille
    #
    if verbose:print 'grille=\n',grille
    toutcs=re.sub('<grilleNamelist>',gridnml,toutcs)  #grille
    cs_settings=open(cs_file,'w')
    cs_settings.write(toutcs)
    cs_settings.close()
    if verbose: print toutcs
#
#
print 'Done...'
raw_input('Press ENTER to exit')
# quit()
