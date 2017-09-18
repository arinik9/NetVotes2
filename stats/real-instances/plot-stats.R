# TODO: Add comment
# 
# Author: nejat
###############################################################################

source("stats/define-consts.R")
library(package="igraph")

dir.create(DIR.REAL.INSTANCES.PLOTS, showWarnings = TRUE)


for(TARGET.TYPE in c("State", "Group", "All")){
	
	dir.create(paste(DIR.REAL.INSTANCES.PLOTS,TARGET.TYPE,sep="/"), showWarnings = TRUE)
	
	# ============================================================================
	# filtering-step-assessment
	# ============================================================================
	plot.folder = paste(DIR.REAL.INSTANCES.PLOTS,TARGET.TYPE,"filtering-step-assessment",sep="/")
	dir.create(plot.folder, showWarnings = TRUE)
	source(paste(DIR.REAL.INSTANCES,"/filtering-step-assessment.R",sep=""))
	
	# ============================================================================
	# after-filtering-step-IM-vs-ExCC
	# ============================================================================
	#plot.folder = paste(DIR.REAL.INSTANCES.PLOTS,"/",TARGET.TYPE,"/after-filtering-step-",COMDET.INFOMAP,"-vs-",ExCC,sep="")
	#dir.create(plot.folder, showWarnings = TRUE)
	#source(paste(DIR.REAL.INSTANCES,"/after-filtering-step-",COMDET.INFOMAP,"-vs-",ExCC,".R",sep=""))
	
	# ============================================================================
	# after-filtering-step-ILSCC-vs-ExCC
	# ============================================================================
	plot.folder = paste(DIR.REAL.INSTANCES.PLOTS,"/",TARGET.TYPE,"/after-filtering-step-",ILSCC,"-vs-",ExCC,sep="")
	dir.create(plot.folder, showWarnings = TRUE)
	source(paste(DIR.REAL.INSTANCES,"/after-filtering-step-",ILSCC,"-vs-",ExCC,".R",sep=""))
	
	# ============================================================================
	# infomap-robustness-check
	# ============================================================================
	#plot.folder = paste(DIR.REAL.INSTANCES.PLOTS,"/",TARGET.TYPE,"/",COMDET.INFOMAP,"-robustness-check",sep="")
	#dir.create(plot.folder, showWarnings = TRUE)
	#source(paste(DIR.REAL.INSTANCES,"/",COMDET.INFOMAP,"-robustness-check.R",sep=""))
	
	
	# ============================================================================
	# graph strucure: connected-components
	# ============================================================================
	plot.folder = paste(DIR.REAL.INSTANCES.PLOTS,TARGET.TYPE,"graph-connected-components",sep="/") 
	dir.create(plot.folder, showWarnings = TRUE)
	source(paste(DIR.REAL.INSTANCES,"/graph-connected-components.R",sep=""))
	
	# ============================================================================
	# graph strucure: graph-density
	# ============================================================================
	plot.folder = paste(DIR.REAL.INSTANCES.PLOTS,TARGET.TYPE,"graph-density",sep="/") 
	dir.create(plot.folder, showWarnings = TRUE)
	source(paste(DIR.REAL.INSTANCES,"/graph-density.R",sep=""))
	
	# ============================================================================
	# graph strucure: pos-neg-edges
	# ============================================================================
	plot.folder = paste(DIR.REAL.INSTANCES.PLOTS,TARGET.TYPE,"graph-pos-neg-edges",sep="/") 
	dir.create(plot.folder, showWarnings = TRUE)
	source(paste(DIR.REAL.INSTANCES,"/graph-pos-neg-edges.R",sep=""))

}
