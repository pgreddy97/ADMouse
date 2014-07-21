#!/usr/bin/env bash 

./initializeFolders.py $1
./createMatrixServer.py $1 $2 $3
Rscript makeClustersGeneral.R $1
./orderCopy.py $1
./getGroupedListServer.py $1 $2 $3
Rscript makeHeatmapsGeneral.R $1