#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys

def main():
	old = open(sys.argv[1])
	
	categories = ['none','lateDec','dec','lateInc','inc','earlyInc','earlyDec']

	countsH3K4me3=[0,0,0,0,0,0,0]
	countsH3K4me1=[0,0,0,0,0,0,0]
	countsH3K27ac=[0,0,0,0,0,0,0]
	countsHDAC2=[0,0,0,0,0,0,0]
	countsH3K27me3_narrow=[0,0,0,0,0,0,0]
	countsH3K9me3=[0,0,0,0,0,0,0]
	
	
	intListHistone = 0
	intListStatus = 0
	
	while True:
		oldLine = old.readline()
		if not oldLine: break
		
		listOfWords = oldLine.split('\t')
		
		found = False
		
		if (listOfWords[6]=='H3K4me3'):
			for i in range (0,len(categories)):
				if (listOfWords[7]==categories[i]):
					countsH3K4me3[i]=countsH3K4me3[i]+1
		elif (listOfWords[6]=='H3K4me1'):
			for i in range (0,len(categories)):
				if (listOfWords[7]==categories[i]):
					countsH3K4me1[i]=countsH3K4me1[i]+1	
		elif (listOfWords[6]=='H3K27ac'):
			for i in range (0,len(categories)):
				if (listOfWords[7]==categories[i]):
					countsH3K27ac[i]=countsH3K27ac[i]+1		
		elif (listOfWords[6]=='HDAC2'):
			for i in range (0,len(categories)):
				if (listOfWords[7]==categories[i]):
					countsHDAC2[i]=countsHDAC2[i]+1	
		elif (listOfWords[6]=='H3K27me3_narrow'):
			for i in range (0,len(categories)):
				if (listOfWords[7]==categories[i]):
					countsH3K27me3_narrow[i]=countsH3K27me3_narrow[i]+1	
		elif (listOfWords[6]=='H3K9me3'):
			for i in range (0,len(categories)):
				if (listOfWords[7]==categories[i]):
					countsH3K9me3[i]=countsH3K9me3[i]+1			
		
			
	print 'H3K4me3'	
	for i in range(0,len(countsH3K4me3)):
		print categories[i]+': '+str(countsH3K4me3[i])
	print
	
	print 'H3K4me1'	
	for i in range(0,len(countsH3K4me1)):
		print categories[i]+': '+str(countsH3K4me1[i])
	print
	
	print 'H3K27ac'	
	for i in range(0,len(countsH3K27ac)):
		print categories[i]+': '+str(countsH3K27ac[i])
	print
	
	print 'HDAC2'	
	for i in range(0,len(countsHDAC2)):
		print categories[i]+': '+str(countsHDAC2[i])
	print
	
	print 'H3K27me3_narrow'	
	for i in range(0,len(countsH3K27me3_narrow)):
		print categories[i]+': '+str(countsH3K27me3_narrow[i])
	print
	
	print 'H3K9me3'	
	for i in range(0,len(countsH3K9me3)):
		print categories[i]+': '+str(countsH3K9me3[i])
	print
	
if __name__ == '__main__':
	main()