

########################################################################
# 
########################################################################
create.output.IM.result.dir = function(output.directory){
	sub.dirname = COMDET.INFOMAP
	dir.name = paste(output.directory, sub.dirname, sep="/")
	dir.create(dir.name, showWarnings = FALSE)
	
	return(sub.dirname)
}



########################################################################
# 
########################################################################
prepare.IM.full.output.filename = function(IM.directory){
	
	return(paste(IM.directory, INFOMAP.MEM.FILENAME, sep="/"))
}





########################################################################
# 
########################################################################
load.IM.partition = function(full.output.filename){
	membership = read.table(full.output.filename)$V1 # infomap: membership.txt file
	
	return(membership)
}


########################################################################
# 
########################################################################
prepare.IM = function(output.directory)
{
	inputs = list()
	output.dir.basename = create.output.IM.result.dir(output.directory)
	output.full.dir.name = paste(output.directory, output.dir.basename, sep="/")
	algo.output.file = 
			prepare.IM.full.output.filename(output.full.dir.name)
	
	inputs$output.dir.basename = output.dir.basename
	inputs$output.full.dir.name = output.full.dir.name
	inputs$algo.output.file = algo.output.file
	
	return(inputs)
}





########################################################################
# Vincent Labatut daha onceden calistirmis Infomap result'larini.
# O yuzden gerek yok benim bir daha burda calistirmaya
########################################################################
run.IM = function(network.path, full.output.filename){		
	g = read.graph.graphml(network.path)

	# ===========================================================
	# remove negative links from the graph
	gpos <- delete.edges(graph=g,edges=which(E(g)$weight<0))
	# ===========================================================

	start=Sys.time()
	imc <- cluster_infomap(gpos)
	end=Sys.time()
	exec.time = as.numeric(end) - as.numeric(start)
	
	membership = membership(imc)
	write(membership, file=full.output.filename, ncolumns=1)
	
	return(exec.time)
}




########################################################################
# 
########################################################################
perform.IM = function(worker.id, desc, output.directory, output.dir.desc,
		target.name, network.path.G, network.path.graphml, current.MEP.details,
		LOG.ENABLED = TRUE, RUNNING.PARTITIONING.ALGOS.ENABLED = TRUE, UPDATING.GRAPHML.CONTENT.ENABLED = TRUE,
		PLOTTING.ENABLED = TRUE)
{	
	result = list(exec.time = NA, stats.vec = NA, plot.inputs = NA)
	
	# =========================================================================
	if(LOG.ENABLED)
		write.into.log(worker.id, 12, ".........BEGIN PREPARE.INFOMAP.........")
	
	inputs = prepare.IM(
			output.directory = output.directory
	)
	
	if(LOG.ENABLED)
		write.into.log(worker.id, 12, ".........END PREPARE.INFOMAP.........")
	# =========================================================================

	
	# =========================================================================
	if(RUNNING.PARTITIONING.ALGOS.ENABLED == TRUE){
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, ".........BEGIN RUN.INFOMAP.........")
		
		exec.time = run.IM(
				network.path = network.path.graphml,
				full.output.filename = inputs$algo.output.file
		)
		
		# save exec.time: write into file
		write(x=exec.time, file=paste(inputs$output.full.dir.name,"/",EXEC.TIME.FILENAME,sep=""))
		
		if(LOG.ENABLED)
			write.into.log(worker.id, 12, ".........END RUN.INFOMAP.........")	
	}
	
	# in case of RUNNING.PARTITIONING.ALGOS.ENABLED == FALSE, read the exec.time from the file
	result$exec.time = as.numeric(readLines(con=paste(inputs$output.full.dir.name,"/",EXEC.TIME.FILENAME,sep="")))
	
	membership = load.IM.partition(inputs$algo.output.file)
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


