# TODO: Add comment
# 
# Author: nejat
###############################################################################

source("stats/define-consts.R")


unlink(DIR.REAL.INSTANCES.PLOTS, recursive = TRUE)



################################################
# 1) 
################################################
# run 'src/main.R' and assing TRUE only to RECORDING.STATS.CSV, ILSCC.ENABLED, EXCC.ENABLED, INFOMAP.ENABLED

# .libPaths() does not contain the path located in user dir, you might add this into .libPaths()
LIBRARY.LOC.PATH = .libPaths() # for nejat's pc
#LIBRARY.LOC.PATH = "../../../../libs/R" # for cluster


# PARALLEL.COMPUTING is good for process speed, but SEQ.COMPUTING is good for debugging and printing on the console
PARALLEL.COMPUTING.ENABLED = FALSE
NB.CORES.FOR.PARALLEL.COMPUTING = 3 # NA will cause to use the max nb cores if PARALLEL.COMPUTING is enabled

LOG.ENABLED = TRUE
RUNNING.PARTITIONING.ALGOS.ENABLED = FALSE
PLOTTING.ENABLED = FALSE
UPDATING.GRAPHML.CONTENT.ENABLED = FALSE
RECORDING.STATS.CSV = TRUE

ILSCC.ENABLED = TRUE
EXCC.ENABLED = TRUE
ILSRCC.ENABLED = FALSE
KMBS.ENABLED = FALSE
INFOMAP.ENABLED = TRUE
MULTIPLOT.ENABLED = FALSE

source("src/main.R") # run it to get stats csv



################################################
# 2)
################################################
source(paste(DIR.REAL.INSTANCES, "data-cleansing-csv.R",sep="/"))


################################################
# 3)
################################################
source(paste(DIR.REAL.INSTANCES, "combine-state-group-csv.R",sep="/"))


################################################
# 4)
################################################
source(paste(DIR.REAL.INSTANCES, "plot-stats.R",sep="/"))
