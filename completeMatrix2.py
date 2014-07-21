#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os
import os.path
import subprocess

def main():

	os.chdir(sys.arv[1]+'/numbers')
	
	for fileName in os.listdir(os.getcwd()):
		subprocess(['./qrun"','Rscript','pvClustSpecific.R',sys.argv[1],fileName])
	

if __name__ == '__main__':
	main()