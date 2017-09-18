# TODO: Add comment
# 
# Author: nejat
###############################################################################


########################################################################
# 
########################################################################
get.tmp.partition.no.for.removed.nodes.by.KMBS = function(membership){
	# I can not plot with a partition no which is -1
	# I replace -1 by nb.partition
	# It is 100% sure that there is not another partition no whose id=nb.partition
	
	nb.partition = length(unique(membership))
	return(nb.partition)
}



########################################################################
# 
########################################################################
load.KMBS.partition = function(kmbs.output.file){
	con <- file(kmbs.output.file, "r")
	lines <- readLines(con)
	close(con)
	
	# process the file content
	i <- 2
	line = lines[i]
	counter = 0
	membership <- c()
	while(is.na(suppressWarnings(as.integer(line))) == FALSE)
	{  # process current line
		#print(line)
		
		counter = counter + 1
		membership[counter] <- as.numeric(line)
		
		# process next line
		i = i + 1
		line <- lines[i]      
	}

	return(membership)
	
}



########################################################################
# 
########################################################################
update.KMBS.membership.for.plot = function(mems){
	
	# =====================================
	# I can not plot with a partition no which is -1
	# I replace -1 by nb.partition
	# It is 100% sure that there is not another partition no whose id=nb.partition
	tmp.part.no = get.tmp.partition.no.for.removed.nodes.by.kmbs(mems)
	
	mems[which(mems == PARTITION.NO.FOR.REMOVED.NODES.BY.KMBS)] = tmp.part.no
	# ======================================
	
	return(mems)
	
}



########################################################################
# 
########################################################################
create.output.KMBS.result.dir = function(output.directory, k){
	sub.dirname = paste(KMBS, "-", k, sep="")
	dir.name = paste(output.directory, sub.dirname, sep="/")
	dir.create(dir.name, showWarnings = FALSE)
	
	return(sub.dirname)
}



########################################################################
# 
########################################################################
prepare.KMBS.full.output.filename = function(kmbs.directory){
	return(paste(kmbs.directory, KMBS.RESULT.FILENAME, sep="/"))
	
}



########################################################################
# 
########################################################################
prepare.KMBS = function(output.directory, k)
{
	inputs = list()
	
	output.dir.basename = create.output.KMBS.result.dir(output.directory, k)
	output.full.dir.name = paste(output.directory, output.dir.basename, sep="/")
	algo.output.file = prepare.KMBS.full.output.filename(output.full.dir.name)
	
	inputs$output.dir.basename = output.dir.basename
	inputs$output.full.dir.name = output.full.dir.name
	inputs$algo.output.file = algo.output.file
	
	return(inputs)
}



########################################################################
# 
########################################################################
run.KMBS = function(network.path, full.output.filename, k){
	start=Sys.time()
	cmd = 
		paste(
				KMBS.EXECUTABLE.PATH,
				network.path,
				full.output.filename,
				k,
				sep=" "
			)
	system(cmd, wait=TRUE)
	end=Sys.time()
	exec.time = as.numeric(end) - as.numeric(start)
	print(cmd)
	
	return(exec.time)
}



########################################################################
# 
########################################################################
perform.KMBS = function(worker.id, k, desc, output.directory, output.dir.desc,
		target.name, network.path.G, network.path.graphml, current.MEP.details,
		LOG.ENABLED = TRUE, RUNNING.PARTITIONING.ALGOS.ENABLED = TRUE, UPDATING.GRAPHML.CONTENT.ENABLED = TRUE,
		PLOTTING.ENABLED = TRUE)
{
	result = list(exec.time = NA, stats.vec = NA, plot.inputs = NA)
	
	# =========================================================================
	if(LOG.ENABLED)
		write.into.log(worker.id, 12, ".........BEGIN PREPARE.KMBS.........")
	
	inputs = prepare.KMBS(
			output.directory = output.directory,
			k = k
	)
	
	if(LOG.ENABLED)
		write.into.log(worker.id, 12, ".........END PREPARE.KMBS.........")
	# =========================================================================
	
	# =========================================================================
	if(RUNNING.PARTITIONING.ALGOS.ENABLED == TRUE){
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, ".........BEGIN RUN.KMBS.........")
		
		exec.time = run.KMBS(
				network.path = network.path.G,
				full.output.filename = inputs$algo.output.file,
				k = k
		)
		
		# save exec.time: write into file
		write(x=exec.time, file=paste(inputs$output.full.dir.name,"/",EXEC.TIME.FILENAME,sep=""))
	
		
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, ".........END RUN.KMBS.........")
	}
	
	# in case of RUNNING.PARTITIONING.ALGOS.ENABLED == FALSE, read the exec.time from the file
	result$exec.time = as.numeric(readLines(con=paste(inputs$output.full.dir.name,"/",EXEC.TIME.FILENAME,sep="")))
	
	membership = load.KMBS.partition(inputs$algo.output.file)
	membership = post.proc.membership.for.isolated.nodes(network.path.graphml, membership)
	
	if(LOG.ENABLED){
		write.into.log(worker.id, 12, "result$exec.time", result$exec.time)
		write.into.log(worker.id, 12, "membership", membership)		
	}
	# =========================================================================
	
	
	# ===================================================================
	if(UPDATING.GRAPHML.CONTENT.ENABLED == TRUE){
		# update graphml file with kmbs partition info
		attr.name = desc
		newGraphDoc = addPartitionInfoIntoNodes(
				network.path.graphml, attr.name, membership
		)
		saveXML(newGraphDoc, file=network.path.graphml)	
	}
	# =========================================================================
	
	
	# =========================================================================
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
	# =========================================================================


	# =========================================================================
	if(PLOTTING.ENABLED == TRUE){
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, ".........BEGIN PLOTTING.........")
		
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
			write.into.log(worker.id, 12, ".........END PLOTTING.........")
	}
	# =========================================================================
	
	return(result)
}


