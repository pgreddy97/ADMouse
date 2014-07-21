#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os

os.chdir('/Users/pranav/Desktop/ScienceResearch/data/UpdADMouse/mouse')
print "here"
for folder in os.listdir(os.getcwd()):
	os.chdir('/Users/pranav/Desktop/ScienceResearch/data/UpdADMouse/mouse')
	if (folder!='.DS_Store'):
		print folder
		os.chdir(folder)
		for fileName in os.listdir(os.getcwd()):
			count=0
			temp = open(fileName)
			while True:
				oldLine = temp.readline()
				if not oldLine: break
				count=count+1
			print fileName +":\t" + str(count)
			temp.close

if __name__ == '__main__':
	main()