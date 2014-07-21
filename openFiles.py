#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os

def main():
	mark = sys.argv[1]
	target = sys.argv[2]
	background = sys.argv[3]
	
	os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/allSites/'+mark+'/'+target+'_'+background)
	os.system('open homerResults.html')
	
	os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/dhsSites/'+mark+'/'+target+'_'+background)
	os.system('open homerResults.html')
	
if __name__ == '__main__':
	main()