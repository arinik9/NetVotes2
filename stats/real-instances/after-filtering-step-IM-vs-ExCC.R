# TODO: Add comment
# 
# Author: nejat
###############################################################################

#!/usr/bin/Rscript
source("stats/define-plots.R")

method1 = COMDET.INFOMAP
method2 = ExCC


csv.path = paste(DIR.REAL.INSTANCES.CSV,TARGET.TYPE,sep="/") # TODO bunun normlade FOR loop'dan gelmesi lazim : country and group
output.path = paste(DIR.REAL.INSTANCES.PLOTS,"/",TARGET.TYPE,"/after-filtering-step-",method1,"-vs-",method2,sep="")



filename.filt.IM = paste("filtered-",method1,"-info-after-data-cleansing.csv",sep="")
filepath.filt.IM = paste(csv.path,filename.filt.IM,sep="/")
filename.filt.ExCC = paste("filtered-",method2,"-info-after-data-cleansing.csv",sep="")
filepath.filt.ExCC = paste(csv.path,filename.filt.ExCC,sep="/")


filename.filt.graph.str = paste("filtered-",G.STR,"-info-after-data-cleansing.csv",sep="")
filepath.filt.graph.str = paste(csv.path,filename.filt.graph.str,sep="/")


################################################################################
################################################################################

# =====================================
# INSTANCES vs. NB.CLUSTER
# =====================================
plot.instances.vs.nbCluster.betw.2.methods(output.path, filepath.filt.IM, filepath.filt.ExCC,
		filepath.filt.graph.str, method1, method2)


################################################################################
################################################################################

# =====================================
# NMI vs. FREQUENCE
# =====================================
plot.nmi.vs.freq.betw.2.methods(output.path, filepath.filt.IM, filepath.filt.ExCC, filepath.filt.graph.str, method1, method2)


################################################################################
################################################################################

# =====================================
# DELTA.IMBALANCE vs. FREQUENCE
# =====================================
plot.delta.imb.vs.freq.betw.2.methods(output.path, filepath.filt.IM, filepath.filt.ExCC, method1, method2)


################################################################################
################################################################################

# =====================================
# NMI vs. DELTA.NB.CLUSTER
# =====================================
plot.nmi.vs.nbCluster.betw.2.methods(output.path, filepath.filt.IM, filepath.filt.ExCC,
		filepath.filt.graph.str, method1, method2)
