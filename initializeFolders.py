#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os
import os.path
import copy

def main():
	os.chdir(sys.argv[1])
	folders = ['all','complete','dendograms','heatmaps','labels','numbers','orderedMatrices','orderedMatricesNumbers','orders','pvDendograms','pvValues']
	for name in folders:
		if not os.path.exists(name):
			os.makedirs(name)
	
	os.chdir('labels')
	labelFolders = ['run', 'motif']
	for name in labelFolders:
		if not os.path.exists(name):
			os.makedirs(name)
	
	pvFolders = ['au','merge','clusters']
	for name in labelFolders:
		os.chdir(sys.argv[1]+'/pvValues')
		if not os.path.exists(name):
			os.makedirs(name)
		os.chdir(sys.argv[1]+'/pvValues/'+name)
		for label in pvFolders:
			if not os.path.exists(label):
				os.makedirs(label)
				
	
    	
if __name__ == '__main__':
	main()