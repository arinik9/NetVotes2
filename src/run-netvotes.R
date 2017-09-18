# TODO: Add comment
# 
# Author: nejat
###############################################################################


# ==============================================================================
# MANUAL CONFIG NEEDED
# ==============================================================================

# .libPaths() does not contain the path located in user dir, you might add this into .libPaths()
LIBRARY.LOC.PATH = .libPaths() # for nejat's pc
#LIBRARY.LOC.PATH = "../../../../libs/R" # for cluster


# PARALLEL.COMPUTING is good for process speed, but SEQ.COMPUTING is good for debugging and printing on the console
PARALLEL.COMPUTING.ENABLED = FALSE
NB.CORES.FOR.PARALLEL.COMPUTING = 3 # NA will cause to use the max nb cores if PARALLEL.COMPUTING is enabled

LOG.ENABLED = TRUE # hata var == paste(LOG.FILENAME.PREFIX, worker.id, ".txt", sep = "") :  object 'LOG.FILENAME.PREFIX' not found
RUNNING.PARTITIONING.ALGOS.ENABLED = TRUE
PLOTTING.ENABLED = FALSE
UPDATING.GRAPHML.CONTENT.ENABLED = TRUE
RECORDING.STATS.CSV = FALSE

ILSCC.ENABLED = TRUE
EXCC.ENABLED = TRUE
ILSRCC.ENABLED = TRUE
KMBS.ENABLED = TRUE
INFOMAP.ENABLED = TRUE
MULTIPLOT.ENABLED = TRUE


# ==============================================================================
# START TO RUN ALL
# ==============================================================================


start=Sys.time()

source("src/main.R")

end=Sys.time()
print(end - start)
warnings()
