# TODO: Add comment
# 
# Author: nejat
###############################################################################

EXE.DIR = "exe"
DATA.DIR = "data"
OUT.DIR = "out"
VOTE.AGREEMENT.TYPE = "m3" # there is actually only one choice


EUROPARL.BEGIN.PERIOD.DATE.WITHOUT.YEAR = "01/07/"
EUROPARL.BEGIN.DATE = paste(EUROPARL.BEGIN.PERIOD.DATE.WITHOUT.YEAR,"2009",sep="")
EUROPARL.END.DATE = paste(EUROPARL.BEGIN.PERIOD.DATE.WITHOUT.YEAR,"2014",sep="")
EUROPARL.PERIOD.LENGTH.AS.DAYS = 365


# Algo names
CORCLU.ILS = "ILS"
ILSRCC = "rcc" # desc from Mario's code
ILSCC = "cc" # desc from Mario's code
CORCLU.GRASP = "GRASP"
KMBS = "KMBS"
ExCC = "ExCC"
COMDET.INFOMAP = "IM"


##########################################################################################
## COMMON
##########################################################################################

SIGNED.GRAPH.FILENAME = "signed.G"
SIGNED.UNWEIGHTED.GRAPH.FILENAME = "signed-unweighted.G"
GRAPHML.NETWORK.FILENAME = "signed.graphml"
GRAPHML.GEPHI.NETWORK.FILENAME = "signed-gephi.graphml"
CLU.NO.FOR.ALL.ISOLATED.NODES = 0
CLUSTER.GRAPH.FILENAME = "cluster-graph.pdf"
EXEC.TIME.FILENAME = "exec-time.txt"



NO.PREDEF.NB.CLUSTER = 0 # to use in ilscc



##########################################################################################
## Ex-CC
##########################################################################################

EXCC.RESULT.FILENAME = paste(ExCC,"-result.txt",sep="")
ExCC.JAR.PATH = paste(EXE.DIR,"cplex-partition-openjdk-1_8.jar",sep="/")
# where the .so files are located
CPLEX.BIN.PATH = "/opt/ibm/ILOG/CPLEX_Studio1271/cplex/bin/x86-64_linux/" #  path for Nejat's computer
# CPLEX.BIN.PATH = "/usr/local/ibm/ILOG/CPLEX_Studio1261/cplex/bin/x86-64_linux/"# 'path for "gaia" cluster


##########################################################################################
## ILS-GRASP
##########################################################################################

GRASP.ILS.EXECUTABLE.PATH = paste(EXE.DIR, "/graspcc", sep="")
PYTHON.RESULT.INTERPRETER.EXECUTABLE.PATH = 
		paste("python ", EXE.DIR, "/process-graspcc-output.py", sep="")

RCC.RESULT.FILENAME = paste(ILSRCC,"-result.txt",sep="")
CC.RESULT.FILENAME = paste(ILSCC,"-result.txt",sep="")

IS.PARALLEL.VERSION = FALSE
PREFIX.PAR.VERS = "par"
PREFIX.SEQ.VERS = "seq"

# parameters
ALPHA.DEFAULT = 0.4
PERTURBATION.DEFAULT = 3
TIME.LIMIT.DEFAULT = 3600 # 3600
L.DEFAULT = 1
ITER.DEFAULT = 10
STRATEGY.DEFAULT = CORCLU.ILS
GAIN.FUNC.DEFAULT = 0


##########################################################################################
## INFOMAP
##########################################################################################

INFOMAP.MEM.FILENAME = paste(COMDET.INFOMAP,"-membership.txt",sep="")


##########################################################################################
## KMBS
##########################################################################################

PARTITION.NO.FOR.REMOVED.NODES.BY.KMBS = -1
KMBS.RESULT.FILENAME = paste(KMBS,"-result.txt",sep="")
KMBS.EXECUTABLE.PATH = paste(EXE.DIR, "kmbs", sep="/")


##########################################################################################
## PLOT CONFIG
##########################################################################################

# TODO: STATE.LIST is the same as TARGET.STATES in src/main.R

STATE.LIST =
		c(
				"Austria","Belgium","Bulgaria","Croatia","Cyprus","Czech Republic",
				"Denmark","Estonia","Finland","France","Germany","Greece","Hungary",
				"Ireland","Italy","Latvia","Lithuania","Luxembourg","Malta",
				"Netherlands","Poland","Portugal","Romania","Slovakia","Slovenia",
				"Spain","Sweden","United Kingdom"
		)

EU.REGION.FOR.STATE = list()
EU.REGION.FOR.STATE[["Austria"]] = "Central"
EU.REGION.FOR.STATE[["Belgium"]] = "Western"
EU.REGION.FOR.STATE[["Bulgaria"]] = "Southeastern"
EU.REGION.FOR.STATE[["Croatia"]] = "Central"
EU.REGION.FOR.STATE[["Cyprus"]] = "Southeastern"
EU.REGION.FOR.STATE[["Czech Republic"]] = "Central"
EU.REGION.FOR.STATE[["Denmark"]] = "Northern"
EU.REGION.FOR.STATE[["Estonia"]] = "Central"
EU.REGION.FOR.STATE[["Finland"]] = "Northern"
EU.REGION.FOR.STATE[["France"]] = "Western"
EU.REGION.FOR.STATE[["Germany"]] = "Central"
EU.REGION.FOR.STATE[["Greece"]] = "Southeastern"
EU.REGION.FOR.STATE[["Hungary"]] = "Central"
EU.REGION.FOR.STATE[["Ireland"]] = "Western"
EU.REGION.FOR.STATE[["Italy"]] = "Southern"
EU.REGION.FOR.STATE[["Latvia"]] = "Central"
EU.REGION.FOR.STATE[["Lithuania"]] = "Central"
EU.REGION.FOR.STATE[["Luxembourg"]] = "Central"
EU.REGION.FOR.STATE[["Malta"]] = "Southern"
EU.REGION.FOR.STATE[["Netherlands"]] = "Western"
EU.REGION.FOR.STATE[["Poland"]] = "Central"
EU.REGION.FOR.STATE[["Portugal"]] = "Southern"
EU.REGION.FOR.STATE[["Romania"]] = "Southeastern"
EU.REGION.FOR.STATE[["Slovakia"]] = "Central"
EU.REGION.FOR.STATE[["Slovenia"]] = "Central"
EU.REGION.FOR.STATE[["Spain"]] = "Southern"
EU.REGION.FOR.STATE[["Sweden"]] = "Northern"
EU.REGION.FOR.STATE[["United Kingdom"]] = "Western"





# 'check.names'=FALSE ensures that the column names will not be changed 
# (e.g. when there are spaces between 2 words)
MEP.DETAILS = 
		read.table(
				paste(DATA.DIR,"/overall/mep-details.csv",sep=""), 
				header=1, 
				sep=";", 
				check.names= FALSE
		)

# insert "region" information for each state:
# Northern europe:1, Central Europe:2, Western Europe:3, 
# Southern Europe:4, Southeastern Europe:5

MEP.DETAILS["Region"] = NA # initialize the "Region" column with NA
for(i in 1:length(STATE.LIST)){
	state = STATE.LIST[i]
	region = EU.REGION.FOR.STATE[[state]]
	indx = which(state == MEP.DETAILS[,"State"])
	
	#if(length(indx)>0)
	MEP.DETAILS[indx,"Region"] = region
}

POLITICAL.GROUP.LIST = sort(unique(MEP.DETAILS[,"Group"]))
REGION.LIST = sort(unique(MEP.DETAILS[,"Region"]))
COUNTRY.LIST = sort(unique(MEP.DETAILS[,"State"])) # not used
