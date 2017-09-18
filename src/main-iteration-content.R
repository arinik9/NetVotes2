# TODO: Add comment
# 
# Author: nejat
###############################################################################





###############################################################################
#
###############################################################################
do.iteration = function(worker.id = NA, target, domain, period){

	
	if(LOG.ENABLED)
		write.into.log(worker.id, 4, ".........WE ARE IN DO.ITERATION() - BEGIN..........")

	
	# ===========================================================
	# store all plots in this list
	plot.list = list()
	# ===========================================================
	
	
	input.directory = paste(NETWORKS, "/", target, "/", domain, "/", period, sep="")
	
	output.target.directory = paste(PARTITIONS, "/", target, sep="")
	output.domain.directory = paste(output.target.directory, "/", domain, sep="")
	output.directory = paste(output.domain.directory, "/", period, sep="")
	output.dir.desc = paste(target,"-",domain,"-",period,sep="")
	
	dir.create(output.target.directory, showWarnings = FALSE)
	dir.create(output.domain.directory, showWarnings = FALSE)
	dir.create(output.directory, showWarnings = FALSE)
	
	
	# ==============================
	# create output.dir directory
	dir.create(output.directory, showWarnings = FALSE)
	# ==============================
	
	network.path.G = paste(input.directory, SIGNED.GRAPH.FILENAME, sep="/")
	network.path.graphml = paste(output.directory, GRAPHML.NETWORK.FILENAME, sep="/")
	
	# just copy the .G file into output dir (for the ease of access to .G file from output)
	file.copy(
			network.path.G,
			file.path(output.directory, SIGNED.GRAPH.FILENAME, fsep="/"),
			overwrite=TRUE,
			recursive=FALSE,
			copy.mode=TRUE,
			copy.date=FALSE
	)

	
	############################################################################
	# in order to acces mep details, use "MEP.DETAILS"
	
	beg.curr.period = as.Date(paste(EUROPARL.BEGIN.PERIOD.DATE.WITHOUT.YEAR,period,sep=""), format="%d/%m/%Y")
	end.curr.period = beg.curr.period + EUROPARL.PERIOD.LENGTH.AS.DAYS
	
	target.indx = which(MEP.DETAILS[ ,TARGET.TYPE] == target)
	target.MEP.DETAILS = MEP.DETAILS[target.indx, ]
	nb.obs = nrow(target.MEP.DETAILS)
	
	curr.mep.indx.list = c()
	for(i in seq(1, nb.obs)){
		s.date.interval.list = unlist(strsplit(x=as.character(target.MEP.DETAILS[i, "Periods"]), split="::"))
		
		mep.availability.check.list = sapply(s.date.interval.list,
				function(s.date.interval){
				s.date.list = unlist(strsplit(x=s.date.interval, split=":"))
				date.list = as.Date(s.date.list, format="%d/%m/%Y")
				beg.period.mep = date.list[1]
				end.period.mep = date.list[2]
				if(is.na(end.period.mep)) end.period.mep = as.Date(EUROPARL.END.DATE, format="%d/%m/%Y")
				
				# there are 2 posibilities:
				# 1) beg.period.mep = "01/01/2009", end.period.mep = "01/07/2014",
				# beg.curr.period = "01/07/2009", end.curr.period = "01/07/2010"
				case1 = beg.period.mep < beg.curr.period && beg.curr.period < end.period.mep
				
				# 2) beg.period.mep = "16/07/2009", end.period.mep = "01/07/2014",
				# beg.curr.period = "01/07/2009", end.curr.period = "01/07/2010"
				case2 = beg.curr.period < beg.period.mep && beg.period.mep < end.curr.period
				
				return(case1 || case2)
		})

		if(any(mep.availability.check.list) == TRUE)
			curr.mep.indx.list = c(curr.mep.indx.list, i)
	}
	
	current.MEP.details = target.MEP.DETAILS[curr.mep.indx.list, ]
	############################################################################
	

	# convert .G file into .graphml file in output dir
	gg = read.graph.ils(network.path.G)
	V(gg)$MEPid = current.MEP.details[, "MEP Id"]
	V(gg)$Country = current.MEP.details[, "State"]
	V(gg)$Group = current.MEP.details[, "Group"]
	V(gg)$Firstname = current.MEP.details[, "Firstname"]
	V(gg)$Lastname = current.MEP.details[, "Lastname"]
	write.graph(graph=gg, file=network.path.graphml, format="graphml")
	network.size = get.network.size(network.path.graphml)
	
	
	# for KMBS
	unweighted.network.path.G = paste(input.directory,SIGNED.UNWEIGHTED.GRAPH.FILENAME,sep="/")
	convert.weight.into.unweight.ils.input.graph(network.path.G, unweighted.network.path.G)
	
	
	if(LOG.ENABLED){ 
		write.into.log(worker.id, 4, "network.path.G: ", network.path.G)
		write.into.log(worker.id, 4, "network.path.graphml: ", network.path.graphml)
		write.into.log(worker.id, 4, "unweighted.network.path.G: ", unweighted.network.path.G)
		write.into.log(worker.id, 4, ".........BEGIN TRY/CATCH..........")
	}

	
	
	try({	
				
		###################################################################
		#  ILS
		###################################################################
		
		if(ILSCC.ENABLED){		
			# ====================
			# without k-min
			# ====================	
				
			if(LOG.ENABLED)
				write.into.log(worker.id, 4, ".........BEGIN ILSCC WITHOUT K-MIN..........")
			
			desc = "ILSCC"
			result = perform.ils.cc(worker.id = worker.id, desc = desc,
					output.directory = output.directory, output.dir.desc = output.dir.desc,
					target.name = target, network.path.G = network.path.G,
					network.path.graphml = network.path.graphml, network.size = network.size, 
					current.MEP.details = current.MEP.details,
					LOG.ENABLED = LOG.ENABLED,
					RUNNING.PARTITIONING.ALGOS.ENABLED = RUNNING.PARTITIONING.ALGOS.ENABLED,
					UPDATING.GRAPHML.CONTENT.ENABLED = UPDATING.GRAPHML.CONTENT.ENABLED,
					PLOTTING.ENABLED = PLOTTING.ENABLED)
			
			exec.time = result$exec.time
			stats.vec = result$stats.vec
			plot.inputs = result$plot.inputs
			
			plot.list[[desc]] = plot.inputs
			
			
			k.ILSCC = get.nb.cluster.from.membership(plot.inputs$membership)
			
			if(RECORDING.STATS.CSV){
				source("stats/common.R")
				desc.part = prepare.curr.row.desc.part.for.real.instances(target, domain, period, FILTERING.THRESHOLD)
				filename = ILSCC.STATS.CSV.FILENAME
				dir.path = paste(DIR.REAL.INSTANCES.CSV,TARGET.TYPE,sep="/")
				insert.curr.row.into.partitioning.stats.csv(desc.part, dir.path, filename, result, FILTERING.THRESHOLD)
			}
		
			if(LOG.ENABLED)
				write.into.log(worker.id, 4, ".........END ILSCC WITHOUT K-MIN..........")
			
#			# ====================
#			# with k-min
#			# ====================	
#				
#			if(LOG.ENABLED)
#				write.into.log(worker.id, 4, ".........BEGIN ILSCC WITH K-MIN..........")
#			
#			desc = "ILSCC-k-min-enabled"
#			result = perform.ils.cc(k.min.enabled = TRUE, desc = desc,
#					output.directory = output.directory, output.dir.desc = output.dir.desc,
#					target.name = target, network.path.G = network.path.G,
#					network.path.graphml = network.path.graphml, network.size = network.size,
#					current.MEP.details = current.MEP.details,
#					LOG.ENABLED = LOG.ENABLED,
#					RUNNING.PARTITIONING.ALGOS.ENABLED = RUNNING.PARTITIONING.ALGOS.ENABLED,
#					UPDATING.GRAPHML.CONTENT.ENABLED = UPDATING.GRAPHML.CONTENT.ENABLED,
#					PLOTTING.ENABLED = PLOTTING.ENABLED)
#			
#			exec.time = result$exec.time
#			stats.vec = result$stats.vec
#			plot.inputs = result$plot.inputs
#			
#			plot.list[[desc]] = plot.inputs
#			
#			k.min.ILSCC = get.nb.cluster.from.membership(plot.inputs$membership)
#	
#			if(LOG.ENABLED)
#				write.into.log(worker.id, 4, ".........END ILSCC WITH K-MIN..........")
			
		}
		
		
		####################################################################
		# ExCC
		####################################################################
		
		if(EXCC.ENABLED){
			if(LOG.ENABLED)
				write.into.log(worker.id, 4, ".........BEGIN EXCC..........")
			
			desc = "ExCC"
			result = perform.ExCC(worker.id = worker.id, desc = desc,
					output.directory = output.directory, output.dir.desc = output.dir.desc,
					target.name = target, network.path.G = network.path.G,
					network.path.graphml = network.path.graphml, current.MEP.details = current.MEP.details,
					LOG.ENABLED = LOG.ENABLED,
					RUNNING.PARTITIONING.ALGOS.ENABLED = RUNNING.PARTITIONING.ALGOS.ENABLED,
					UPDATING.GRAPHML.CONTENT.ENABLED = UPDATING.GRAPHML.CONTENT.ENABLED,
					PLOTTING.ENABLED = PLOTTING.ENABLED)
			
			exec.time = result$exec.time
			stats.vec = result$stats.vec
			plot.inputs = result$plot.inputs
			
			plot.list[[desc]] = plot.inputs
			
			if(RECORDING.STATS.CSV){
				source("stats/common.R")
				desc.part = prepare.curr.row.desc.part.for.real.instances(target, domain, period, FILTERING.THRESHOLD)
				filename = EXCC.STATS.CSV.FILENAME
				dir.path = paste(DIR.REAL.INSTANCES.CSV,TARGET.TYPE,sep="/")
				insert.curr.row.into.partitioning.stats.csv(desc.part, dir.path, filename, result, FILTERING.THRESHOLD)
			}
			
			if(LOG.ENABLED)
				write.into.log(worker.id, 4, ".........END EXCC..........")
		}
		
		
		####################################################################
		# ILS-RCC
		#####################################################################					
		
		if(ILSRCC.ENABLED){
			
			for(pair in list(
					c(paste("ILS-RCC_k-from=ILS-CC_k=",k.ILSCC,sep="")	  , k.ILSCC)
					#c(paste("ILS-RCC_k-from=ILS-CC_k+1=",k.ILSCC+1,sep=""), k.ILSCC+1),
					#c(paste("ILS-RCC_k-from=ILS-CC_k+2=",k.ILSCC+2,sep=""), k.ILSCC+2),
					#c(paste("ILS-RCC_k-from=ILS-CC_k+3=",k.ILSCC+3,sep=""), k.ILSCC+3),
					#c(paste("ILS-RCC_k-from=ILS-CC_k+4=",k.ILSCC+4,sep=""), k.ILSCC+4)
			)
					){
				
				desc = pair[1]
				k.value = pair[2]
				
				if(LOG.ENABLED)
					write.into.log(worker.id, 4, ".........BEGIN ILS-RCC with k=", k.value,"..........")
				
				result = perform.ils.rcc(worker.id = worker.id, k = k.value, k.from = CORCLU.ILS, desc = desc,
						output.directory = output.directory, output.dir.desc = output.dir.desc,
						target.name = target, network.path.G = network.path.G,
						network.path.graphml = network.path.graphml, network.size = network.size, 
						current.MEP.details = current.MEP.details,
						LOG.ENABLED = LOG.ENABLED,
						RUNNING.PARTITIONING.ALGOS.ENABLED = RUNNING.PARTITIONING.ALGOS.ENABLED,
						UPDATING.GRAPHML.CONTENT.ENABLED = UPDATING.GRAPHML.CONTENT.ENABLED,
						PLOTTING.ENABLED = PLOTTING.ENABLED)
				
				exec.time = result$exec.time
				stats.vec = result$stats.vec
				plot.inputs = result$plot.inputs
				
				plot.list[[desc]] = plot.inputs
				
				if(RECORDING.STATS.CSV){
					source("stats/common.R")
					desc.part = prepare.curr.row.desc.part.for.real.instances(target, domain, period, FILTERING.THRESHOLD)
					filename = paste("k", k.value, "-", ILSRCC.STATS.CSV.FILENAME, sep="")
					dir.path = paste(DIR.REAL.INSTANCES.CSV,TARGET.TYPE,sep="/")
					insert.curr.row.into.partitioning.stats.csv(desc.part, dir.path, filename, result, FILTERING.THRESHOLD)
				}
				
				if(LOG.ENABLED)
					write.into.log(worker.id, 4, ".........END ILS-RCC with k=", k.value,"..........")
				
			}
		}
		

		####################################################################
		# KMBS - k, k+1, k+2
		####################################################################
		
		if(KMBS.ENABLED){
			
			for(pair in list(
					c(paste("KMBS-k=",k.ILSCC,sep="")  , k.ILSCC)
					#c(paste("KMBS-k=",k.ILSCC+1,sep=""), k.ILSCC+1),
					#c(paste("KMBS-k=",k.ILSCC+2,sep=""), k.ILSCC+2)
			)
					){
				desc = pair[1]
				k.value = pair[2]
				
				if(LOG.ENABLED)
					write.into.log(worker.id, 4, ".........BEGIN KMBS with k=", k.value,"..........")
				
				result = perform.KMBS(worker.id = worker.id, k = k.value, desc = desc,
						output.directory = output.directory, output.dir.desc = output.dir.desc,
						target.name = target, network.path.G = network.path.G,
						network.path.graphml = network.path.graphml, current.MEP.details = current.MEP.details,
						LOG.ENABLED = LOG.ENABLED,
						RUNNING.PARTITIONING.ALGOS.ENABLED = RUNNING.PARTITIONING.ALGOS.ENABLED,
						UPDATING.GRAPHML.CONTENT.ENABLED = UPDATING.GRAPHML.CONTENT.ENABLED,
						PLOTTING.ENABLED = PLOTTING.ENABLED)
				
				exec.time = result$exec.time
				stats.vec = result$stats.vec
				plot.inputs = result$plot.inputs
				
				plot.list[[desc]] = plot.inputs
								
				if(RECORDING.STATS.CSV){
					source("stats/common.R")
					desc.part = prepare.curr.row.desc.part.for.real.instances(target, domain, period, FILTERING.THRESHOLD)
					filename = paste("k", k.value, "-", KMBS.STATS.CSV.FILENAME, sep="")
					dir.path = paste(DIR.REAL.INSTANCES.CSV,TARGET.TYPE,sep="/")
					insert.curr.row.into.partitioning.stats.csv(desc.part, dir.path, filename, result, FILTERING.THRESHOLD)
				}
				
				if(LOG.ENABLED)
					write.into.log(worker.id, 4, ".........END KMBS with k=", k.value,"..........")
			}
		
		}
		
		####################################################################
		# Infomap
		####################################################################
		
		if(INFOMAP.ENABLED){
			
			if(LOG.ENABLED)
				write.into.log(worker.id, 4, ".........BEGIN INFOMAP..........")
			
			desc = "IM"
			result = perform.IM(worker.id = worker.id, desc = desc,
					output.directory = output.directory, output.dir.desc = output.dir.desc,
					target.name = target, network.path.G = network.path.G,
					network.path.graphml = network.path.graphml, current.MEP.details = current.MEP.details,
					LOG.ENABLED = LOG.ENABLED,
					RUNNING.PARTITIONING.ALGOS.ENABLED = RUNNING.PARTITIONING.ALGOS.ENABLED,
					UPDATING.GRAPHML.CONTENT.ENABLED = UPDATING.GRAPHML.CONTENT.ENABLED,
					PLOTTING.ENABLED = PLOTTING.ENABLED)
			
			exec.time = result$exec.time
			stats.vec = result$stats.vec
			plot.inputs = result$plot.inputs
			
			plot.list[[desc]] = plot.inputs
			
			infomap.output.file = plot.inputs$algo.output.file
			
			if(RECORDING.STATS.CSV){
				source("stats/common.R")
				desc.part = prepare.curr.row.desc.part.for.real.instances(target, domain, period, FILTERING.THRESHOLD)
				filename = IM.STATS.CSV.FILENAME
				dir.path = paste(DIR.REAL.INSTANCES.CSV,TARGET.TYPE,sep="/")
				insert.curr.row.into.partitioning.stats.csv(desc.part, dir.path, filename, result, FILTERING.THRESHOLD)
			}
			
			if(LOG.ENABLED)
				write.into.log(worker.id, 4, ".........END INFOMAP..........")
		
		}
		
#		####################################################################
#		# ILS.CC and init partition from IM
#		####################################################################
#		
#		if(LOG.ENABLED)
#			write.into.log(worker.id, 4, ".........BEGIN ILSCC & INIT PARTITION FROM INFOMAP..........")
#		
#		desc = paste("ILS-CC", "_Init-Partition-from-IM-1-iter",sep="")
#		
#		result = perform.ils.cc(init.partition.file = infomap.output.file, init.partition.from = COMDET.INFOMAP,
#				worker.id = worker.id, desc = desc,
#				output.directory = output.directory, output.dir.desc = output.dir.desc,
#				target.name = target, network.path.G = network.path.G,
#				network.path.graphml = network.path.graphml, network.size = network.size, 
#				current.MEP.details = current.MEP.details,
#				LOG.ENABLED = LOG.ENABLED,
#				RUNNING.PARTITIONING.ALGOS.ENABLED = RUNNING.PARTITIONING.ALGOS.ENABLED,
#				UPDATING.GRAPHML.CONTENT.ENABLED = UPDATING.GRAPHML.CONTENT.ENABLED,
#				PLOTTING.ENABLED = PLOTTING.ENABLED)
#		
#		exec.time = result$exec.time
#		stats.vec = result$stats.vec
#		plot.inputs = result$plot.inputs
#		
#		plot.list[[desc]] = plot.inputs
#		
#		if(LOG.ENABLED)
#			write.into.log(worker.id, 4, ".........END ILSCC & INIT PARTITION FROM INFOMAP..........")
#		
#		
		####################################################################
		# MULTI PLOT - Plot only cc, rcc.from.cc 
		####################################################################
		if(PLOTTING.ENABLED == TRUE){
			if(MULTIPLOT.ENABLED){
			
				if(LOG.ENABLED)
					write.into.log(worker.id, 4, ".........BEGIN MULTI PLOT..........")
				
				plots.inputs = 
						list(
								plot.list[["ExCC"]],
								plot.list[["ILSCC"]]
						)
				
				plot.multigraph(
						desc = "ExCC-ILSCC",
						network.path = network.path.graphml,
						plots.inputs = plots.inputs, target.type = TARGET.TYPE,
						output.directory = output.directory, output.dir.desc = output.dir.desc,
						current.MEP.details = current.MEP.details,
						circ.layout.enabled=TRUE,
						node.shape.enabled=TRUE, imbalance.edge.contribution.enabled=FALSE, node.id.label.enabled=FALSE
				)
				
				if(LOG.ENABLED)
					write.into.log(worker.id, 4, ".........END MULTI PLOT..........")
			}
		}
		
		####################################################################
		
		if(RECORDING.STATS.CSV){
			# ==================================================================
			# graph-structure-info
			# ==================================================================
			source("stats/common.R")
			desc.part = prepare.curr.row.desc.part.for.real.instances(target, domain, period, FILTERING.THRESHOLD)
			filename = GRAPH.STR.STATS.CSV.FILENAME
			dir.path = paste(DIR.REAL.INSTANCES.CSV,TARGET.TYPE,sep="/")
			insert.curr.row.into.graph.stats.csv(desc.part, dir.path, filename, network.path.graphml, FILTERING.THRESHOLD)
		}
		
		
		## =========================================================================
		if(LOG.ENABLED)
			write.into.log(worker.id, 4, ".........BEGIN CREATING GEPHI GRAPHML..........")
		
		# at the end, convert graphml file into gephi-graphml file
		# What is specific in the format of gephi-graphml is not using negative edge signs
		# So, we remove negative edge signs and add them as a new edge atrribute in the graphml file
		
		file.path = file.path(output.directory, GRAPHML.NETWORK.FILENAME, fsep="/")
		new.file.path = file.path(output.directory, GRAPHML.GEPHI.NETWORK.FILENAME, fsep="/")
		newGraphDoc = addSignAttrIntoGraphmlFiles(file.path)
		saveXML(newGraphDoc, file=new.file.path)
		
		if(LOG.ENABLED)
			write.into.log(worker.id, 4, ".........END CREATING GEPHI GRAPHML..........")
		## =========================================================================
			
	}, silent=FALSE) # END TRY BLOCK
	
	if(LOG.ENABLED){
		write.into.log(worker.id, 4, ".........END TRY/CATCH..........")
		write.into.log(worker.id, 4, ".........EXIT DO.ITERATION() - END..........")
	}
	
	return(plot.list)
}
