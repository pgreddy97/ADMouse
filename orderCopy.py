#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os
import os.path
import copy
import shutil

def main():
	os.chdir(sys.argv[1]+'/complete')
	for file in os.listdir(os.getcwd()):
		newFile = file.replace('H3K27ac_dhs','0')
		newFile = newFile.replace('H3K27ac_all','4')
		newFile = newFile.replace('H3K4me1_dhs','1')
		newFile = newFile.replace('H3K4me1_all','5')
		newFile = newFile.replace('H3K4me3_dhs','2')
		newFile = newFile.replace('H3K4me3_all','6')
		newFile = newFile.replace('HDAC2_dhs','3')
		newFile = newFile.replace('HDAC2_all','7')
		
		shutil.copyfile(file,sys.argv[1]+'/orders/'+newFile)
		
    	
if __name__ == '__main__':
	main()