# TODO: Add comment
# 
# Author: nejat
###############################################################################

source("stats/define-consts.R")

output.path = paste(DIR.REAL.INSTANCES.CSV,"All",sep="/") # TODO
dir.create(output.path, showWarnings = TRUE)



################################################################################
# combine "State" and "Group" and write into a file BEFORE DATA CLEANSING
################################################################################

csv.file.descs = c(ExCC, ILSCC, COMDET.INFOMAP, G.STR)
for(csv.file.desc in csv.file.descs){
	for(filtering.type in c("filtered", "original")){
		
			csv.path.state = paste(DIR.REAL.INSTANCES.CSV,"State",sep="/")
			csv.filename = paste(csv.path.state,"/",filtering.type,"-",csv.file.desc, "-info.csv", sep="")
			df.state = read.csv(csv.filename)
	
			csv.path.group = paste(DIR.REAL.INSTANCES.CSV,"Group",sep="/")
			csv.filename = paste(csv.path.group,"/",filtering.type,"-",csv.file.desc, "-info.csv", sep="")
			df.group = read.csv(csv.filename)
			
			df.all = rbind(df.state, df.group)
			write.csv(file=paste(output.path,"/",filtering.type,"-",csv.file.desc, "-info.csv",sep=""), x=df.all)
	}
}

################################################################################
# combine "State" and "Group" and write into a file AFTER DATA CLEANSING
################################################################################

csv.file.descs = c(ExCC, ILSCC, COMDET.INFOMAP, G.STR)
for(csv.file.desc in csv.file.descs){
	for(filtering.type in c("filtered", "original")){
		
			csv.path.state = paste(DIR.REAL.INSTANCES.CSV,"State",sep="/")
			csv.filename = paste(csv.path.state,"/",filtering.type,"-",csv.file.desc, "-info-after-data-cleansing.csv", sep="")
			df.state = read.csv(csv.filename)
			
			csv.path.group = paste(DIR.REAL.INSTANCES.CSV,"Group",sep="/")
			csv.filename = paste(csv.path.group,"/",filtering.type,"-",csv.file.desc, "-info-after-data-cleansing.csv", sep="")
			df.group = read.csv(csv.filename)
			
			df.all = rbind(df.state, df.group)
			write.csv(file=paste(output.path,"/",filtering.type,"-",csv.file.desc, "-info-after-data-cleansing.csv",sep=""), x=df.all)
	}
}