#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys

def main():
	old = open (sys.argv[1])
	positive = open (sys.argv[2]+'_positive.bed', 'w')
	negative = open (sys.argv[2]+'_negative.bed', 'w')
	while True:
		oldLine = old.readline()
		if not oldLine: break
		
		pos = True
		exists = False
		
		colon = oldLine.find(':',0,len(oldLine)-1)
		chrNumber = oldLine[:colon]
		tempLine = oldLine[colon+1:]
		dash = tempLine.find('-',0,len(tempLine)-1)
		chrStart = tempLine[:dash]
		tempLine2 = tempLine[dash+1:]
		listOfWords = tempLine2.split('\t')
		chrEnd = listOfWords[0]
		score = listOfWords[-1]
		sign = listOfWords[-3]
		if (sign != ''):
			exists=True
			if (sign[0] == '-'):
				pos = False
		if (exists and pos):
			positive.write(chrNumber + "\t" + chrStart + "\t" + chrEnd + "\t" + chrNumber + "\t" + score)
		elif (exists and not pos):
			negative.write(chrNumber + "\t" + chrStart + "\t" + chrEnd + "\t" + chrNumber + "\t" + score)
	
if __name__ == '__main__':
	main()