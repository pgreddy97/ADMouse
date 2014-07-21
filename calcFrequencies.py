#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os
import os.path
import copy

def main():
	count=[0]*69
	max=0
	os.chdir('/Users/pranav/Desktop/ScienceResearch/matrices/orderedMatricesNumbers')
	for file in os.listdir(os.getcwd()):
		temp = open("H3K4me1_dhs.txt")
	
		temp.readline()
		
		while True:
			oldLine = temp.readline()
			if not oldLine: break
	
			parts = oldLine.split('\t')
	
			for i in range(2,len(parts)):
				if int(parts[i])>max:
					max = int(parts[i])
				count[int(parts[i])]=count[int(parts[i])]+1
				if int(parts[i])>100: print 'here'
	
	for i in range(0,len(count)):
		print str(i) + ': ' + str(count[i])
	print max
	
	
if __name__ == '__main__':
	main()