# TODO: Add comment
# 
# Author: nejat
###############################################################################


source("stats/define-consts.R")
source("stats/common.R")

start=Sys.time()

# ==============================================================================
# REAL INSTANCES
# ==============================================================================

source("stats/real-instances/main.R")


# ==============================================================================
# RANDOM INSTANCES
# ==============================================================================

source("stats/random-instances/main.R")


end=Sys.time()
print(end - start)
warnings()
