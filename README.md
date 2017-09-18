
NetVotes
==================

* Copyright 2017 Arinik Nejat

NetVotes is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation. For source availability and license information see `licence.txt`

* Contact: Vincent Labatut <nejat.arinik@univ-avignon.fr>

-----------------------------------------------------------------------

# Description
This repo is based on (and is complementary to) the following repo:
https://github.com/CompNet/NetVotes
This set of R scripts was designed to process signed graph algorithms, plot their graph results,
and perform some statistical plots.


# Data
Data representing the activity of the members of the European Parliament (MEPs) during the 7th term (from June 2009 to June 2014), as described in [MFLM'15]


# Organization
Here are the folders composing the project:
* Folder `src`: contains the source code (R scripts) to process signed graphs and plot their graph results.
* Folder `stats`: contains the other source code (R scripts) to plot some statistics.
* Folder `out`: contains the produced files (by 'src/run-netvotes.R').


# Installation
1. Install the [`R` language](https://www.r-project.org/)
2. Install the following R packages:
   * [`igraph`](http://igraph.org/r/): required (tested with version 1.0.1).
     * first, type in terminal for `XML` package: `sudo apt-get install libxml2-dev`
     * in R, type: `install.packages("XML")`
     * then, type in R: `install.packages("igraph")`
   * install `iterators`
   * install `foreach`
   * install `doParallel`
   * install `sourcetools`
   * install `ggplot2` (if an error occurs like ‘ggplot2 is not available’, type in terminal ‘sudo apt-get install r-cran-ggplot2’)
   * install `treemap`
3. Install `IBM Cplex 12.7.1`
   * for ubuntu, type the following command:
     * `sudo ./cplex_studio12.7.1.linux-x86-64.bin` 
       * the default installation location for education version is: `/opt/ibm/ILOG/CPLEX_Studio1271` 
       * the default installation location for trial version is:  `/opt/ibm/ILOG/CPLEX_Studio_Community127/cplex/bin/x86-64_linux/`
       * If you use trial version or want to change the default installation folder, update the corresponding variable `CPLEX.BIN.PATH` located in `define-consts.R`. Otherwise, no need to update it
4. Install Open Java 1.8 (our `ExCC` jar file is compiled with that - **TODO**)
5. Install `OpenMPI` for C++. Export `LD_LIBRARY_PATH` variable to the path where openmpi shared objects are located. For example, in my case: `export LD_LIBRARY_PATH=/usr/lib/openmpi/lib:$LD_LIBRARY_PATH`  (if `LD_LIBRARY_PATH` is not set correctly, you will get ‘error when loading shared object ...’)
6. Install `numpy` and `scipy` for python
7. Download this project from GitHub and unzip the archive.
8. Go to the current project directory
9. In terminal: `chmod a+x exe/grapspcc` and `chmod a+x exe/kmbs`
10. configure `src/netvotes.R` file.
11. configure  `LIBRARY.LOC.PATH` in `src/netvotes.R` and `stats/real-instances/main.R`
Initially, `LIBRARY.LOC.PATH = .libPaths()`. But, you can configure it (especially, if you downloaded all R libs in a specific dir)
12. configure/update `CPLEX.BIN.PATH`  in `src/define-consts.R`
13. configure `MAX.G.SIZE` located in `stats/define-consts.R`. I set to 150 because when graph-size increases (especially after 250), the execution of ExCC is getting slower.



# Use
In order to replicate the experiments from the article, perform the following operations:

1. Open the `R` console.
2. Set the current projetct directory as the working directory, using `setwd("my/path/to/the/project/SignedBenchmark")`.
3. Run `src/run-netvotes.R`
4. Run `stats/main.R`


# Info
* The variables we are using are global variables (`src/run-netvotes.R`, `src/define-consts.R`, ...). They will be used throughout the code.
* Stats'lardaki plotlar icin: regarding "assessment for filtering": isolated node'lari kaldirmadan islem yapiyorum. Bununla birlikte, filtering versiyonda 2 algo sonculari karsilastirmasinda isolated node'lar membership bilgisinden cikariliyor.
* in `prepare.grasp.ils.parameter.set`: g.size'a gore parameter set degisiyo => section 4 in [MRYL'17]
* handling membership/nb.cluster variables for isolated nodes: we put all isolated nodes in the same cluster in the 'membership' variable. Their cluster no is `CLU.NO.FOR.ALL.ISOLATED.NODES` ==> in plots, they are visualized in white color.
* stats’daki scriptin duzgun calismasi icin: input olarak verilen metodlarin hem filtresiz hem de filtreli versiyonlari ile birlikte olmasi lazim. Sadece filtreli versiyon varsa bug yaratir
* ExCC’yi parallel calistirirken bug oluyo. Muhtemelen memory cok gerektiren bi algo eger graph-size yuksekse. O yuzden o algo’yu sequential modda calistir
* plot’taki “node-id-enabled” option’u ile “imb-edge-contr” opsiyonu ayni anda kullanilmaz. Cunku ikisi de vertex.label kullaniyo. Vertex.frame kalinligi ile belki “imb-edge-contr”  opsiyonu kullanilabilir ama su an igraph’ta o ozellik yok
* plot’taki “imb-edge-contr” opsiyonu su an aktif degil. Cunku onu benim R’de kodlamam lazil. Yani vertex’lerin imbalance contribution’larini hesaplatmak gerek. Mario’nun yaptigini pek dogru degil gibi. Zaten eger R’de hesaplatirsam dige algo’lar icin de uygulamis olurum
* Mario’nun algosu normalde parallel modda calistirabilriiz. Mpirun ile ayarlanabilir kolayca. Ama ben hic calistirmadim oyle.


# To-do List
* imbalance hesaplamasini genislet. `Total.imbalance`, `neg.imbalance` ve `pos.imbalance`
* implement vertex imbalance contributions from membership file. It will be the same task that Mario has done. But, we will be able to use it for algorithms if we implement it in R. Also, I do not understand what Mario's code for this task. The result might be wrong in some cases.
* Target types 2 tane. 1 tane olursa sikinti olur mu execution’da? Duzelt.
* treemap’te isolated node’u (dikdortgen parca) beyaz ile goster


# References
* [MFLM'15] Mendonça, I.; Figueiredo, R.; Labatut, V. & Michelon, P. Relevance of Negative Links in Graph Partitioning: A Case Study Using Votes From the European Parliament, 2nd European Network Intelligence Conference (ENIC), 2015.
* [MRYL'17] Mario Levorato, Rosa Figueiredo, Yuri Frota & Lúcia Drummond. Evaluating balancing on social networks through the efficient solution of correlation clustering problems, 2017
