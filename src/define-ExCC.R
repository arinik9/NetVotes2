



################################################################################
# Loads the partition estimated by the CC.METHOD.EXACT tool.
# 
# file.name: the path and name of the file to load.
#
# returns: the corresponding partition as a membership vector.
###############################################################################
load.ExCC.partition <- function(file.name)
{	# open and read the file
#	print(file.name)
	con <- file(file.name, "r")
	lines <- readLines(con)
	close(con)
	
	
	# process the file content
	i <- 1
	line <- lines[i]
	res <- list()
	
	# TODO: change here if the result file has more information than just the partition
	# in that case, put this line: while(line!="")
	while(!is.na(line)) # line!=""
	{  # process current line
		#print(line)
		line <- strsplit(x=line, "[", fixed=TRUE)[[1]][2]
		line <- strsplit(x=line, "]", fixed=TRUE)[[1]][1]
		
		# we increment by 1 at the end because C++ starts counting from 0
		nodes <- as.integer(strsplit(x=line,", ", fixed=TRUE)[[1]]) + 1
		
		res[[length(res)+1]] <- nodes
		
		# process next line
		i <- i + 1
		line <- lines[i]  
	}
	
	
	# build the membership vector
	mx <- max(unlist(res))
	membership <- rep(NA,mx)
	for(i in 1:length(res))
	{  nodes <- res[[i]]
		membership[nodes] <- i 
	}
	
#	# record the partition using the internal format
#	write.table(x=membership, file=partition.file, row.names=FALSE, col.names=FALSE)
	
	return(membership)
}


########################################################################
# 
########################################################################
create.output.ExCC.result.dir = function(output.directory){
	sub.dirname = ExCC
	dir.name = paste(output.directory, sub.dirname, sep="/")
	
	dir.create(dir.name, showWarnings = FALSE)
	
	return(sub.dirname)
}


########################################################################
# 
########################################################################
prepare.ExCC.full.output.filename = function(ExCC.directory){
	
	return(paste(ExCC.directory, EXCC.RESULT.FILENAME, sep="/"))
}



########################################################################
# 
########################################################################
prepare.ExCC = function(output.directory)
{
	inputs = list()

	output.dir.basename = create.output.ExCC.result.dir(output.directory)
	output.full.dir.name = paste(output.directory, output.dir.basename, sep="/")
	algo.output.file = 
			prepare.ExCC.full.output.filename(output.full.dir.name)
	
	inputs$output.dir.basename = output.dir.basename
	inputs$output.full.dir.name = output.full.dir.name
	inputs$algo.output.file = algo.output.file

	return(inputs)
}



########################################################################
# 
########################################################################
run.ExCC = function(network.path, full.output.filename){
	
	start=Sys.time()
	cmd = 
			paste(
					"java",		
					paste("-Djava.library.path=", CPLEX.BIN.PATH, sep=""),
					"-jar",
					ExCC.JAR.PATH,
					paste("'", network.path, "'", sep=""),
					">", # redirects output into a file
					paste("'", full.output.filename, "'", sep=""),
					sep=" "
			)
	
	system(cmd, wait=TRUE)
	end=Sys.time()
	exec.time = as.numeric(end) - as.numeric(start)
	print(cmd)

	return(exec.time)
}


########################################################################
########################################################################
########################################################################


########################################################################
# 
########################################################################
perform.ExCC = function(worker.id, desc, output.directory, output.dir.desc,
		target.name, network.path.G, network.path.graphml, current.MEP.details,
		LOG.ENABLED = TRUE, RUNNING.PARTITIONING.ALGOS.ENABLED = TRUE, UPDATING.GRAPHML.CONTENT.ENABLED = TRUE,
		PLOTTING.ENABLED = TRUE)
{
	result = list(exec.time = NA, stats.vec = NA, plot.inputs = NA)
	
	# ==========================================================================
	if(LOG.ENABLED)
		write.into.log(worker.id, 12, "BEGIN PREPARE.EXCC")

	inputs = prepare.ExCC(
			output.directory = output.directory
	)
	
	if(LOG.ENABLED)
		write.into.log(worker.id, 12, "END PREPARE.EXCC")
	# ==========================================================================
	
	
	# ==========================================================================
	if(RUNNING.PARTITIONING.ALGOS.ENABLED == TRUE){
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, "BEGIN RUN.EXCC")
		
		exec.time = run.ExCC(
				network.path = network.path.G,
				full.output.filename = inputs$algo.output.file
		)
		
		# save exec.time: write into file
		write(x=exec.time, file=paste(inputs$output.full.dir.name,"/",EXEC.TIME.FILENAME,sep=""))

		if(LOG.ENABLED)
			write.into.log(worker.id, 12, "END RUN.EXCC")
	}
	
	# in case of RUNNING.PARTITIONING.ALGOS.ENABLED == FALSE, read the exec.time from the file
	result$exec.time = as.numeric(readLines(con=paste(inputs$output.full.dir.name,"/",EXEC.TIME.FILENAME,sep="")))
	
	membership = load.ExCC.partition(inputs$algo.output.file)
	membership = post.proc.membership.for.isolated.nodes(network.path.graphml, membership)
	
	if(LOG.ENABLED){
		write.into.log(worker.id, 12, "result$exec.time", result$exec.time)
		write.into.log(worker.id, 12, "membership", membership)		
	}
	# ==========================================================================
	
	
	# ===================================================================
	if(UPDATING.GRAPHML.CONTENT.ENABLED == TRUE){
		# update graphml file with kmbs partition info
		attr.name = desc
		newGraphDoc = addPartitionInfoIntoNodes(
				network.path.graphml, attr.name, membership
		)
		saveXML(newGraphDoc, file=network.path.graphml)	
	}
	# ===================================================================


	# ===================================================================
	result$stats.vec = perform.stats.after.partitioning(
			network.path = network.path.graphml,
			membership = membership
	)
	
	plot.title = make.plot.title(output.dir.desc, inputs$output.dir.basename, result$stats.vec)
	result$plot.inputs = list(
			output.full.dir.name=inputs$output.full.dir.name,
			algo.output.file = inputs$algo.output.file,
			membership = membership,
			plot.title = plot.title,
			desc = desc
	)
	# ===================================================================
	
	

	if(PLOTTING.ENABLED == TRUE){
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, "BEGIN PLOTTING")
		
		# with circular layout
		plot.graph(
				network.path = network.path.graphml,
				plot.inputs = result$plot.inputs, target.type = TARGET.TYPE,
				output.directory = output.directory, output.dir.desc = output.dir.desc,
				current.MEP.details = current.MEP.details,
				circ.layout.enabled=FALSE,
				node.shape.enabled=TRUE, imbalance.edge.contribution.enabled=FALSE, node.id.label.enabled=TRUE
		)
		# without circular layout
		plot.graph(
				network.path = network.path.graphml,
				plot.inputs = result$plot.inputs, target.type = TARGET.TYPE,
				output.directory = output.directory, output.dir.desc = output.dir.desc,
				current.MEP.details = current.MEP.details,
				circ.layout.enabled=TRUE,
				node.shape.enabled=TRUE, imbalance.edge.contribution.enabled=FALSE, node.id.label.enabled=TRUE
		)
		plot.treemap(
				network.path=network.path.graphml, plot.inputs = result$plot.inputs,
				target.type=TARGET.TYPE, target.name=target.name
		)
		
		
		output.full.path = paste(output.directory, "/", inputs$output.dir.basename, "/", CLUSTER.GRAPH.FILENAME, sep="")
		create.cluster.graph(
				TARGET.TYPE,
				network.path.graphml, 
				membership, 
				MEP.DETAILS, 
				output.full.path = output.full.path
		)
		
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, "END PLOTTING")
	}
	
	return(result)
}



