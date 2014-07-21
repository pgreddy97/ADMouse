#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys

def main():
	old = open(sys.argv[1])
	listOfMarks = ['holder','holder','holder','holder','holder','holder']
	
	while True:
		oldLine = old.readline()
		if not oldLine: break
		
		listOfWords = oldLine.split('\t')
	
	print listOfWords[7]
	
if __name__ == '__main__':
	main()