#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os
import os.path
import copy

def main():
	
	os.chdir(sys.argv[1])
	notes = open('notes.txt', 'w')
	
	os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse')
	
	motifList = []
	namesOfMotifs=[]
	sequences=[]
	
	generateInitialLists(namesOfMotifs, sequences, notes)
	
	populateMotifList(namesOfMotifs, sequences, motifList)
	motifLists = generateSepMotifLists(motifList)
	generateSeparateMatrices(motifLists)
	
	print motifLists[0]
	
	generateTextFiles(motifLists)

def generateTextFiles(motifLists):
	for i in range(0,len(motifLists)):
		os.chdir('/Users/pranav/Desktop/ScienceResearch/matrices/noNone/all')
		newFile = open(chooseName(str(i)) + '.txt','w')
		for list in motifLists[i]:
			line =''
			for element in list:
				line = line + str(element) + '\t'
			line = line[:-1] + '\n'
			newFile.write(line)
	
	for i in range(0,len(motifLists)):
		os.chdir('/Users/pranav/Desktop/ScienceResearch/matrices/noNone/numbers')
		newFile = open(chooseName(str(i)) + '_numbers.txt','w')
		for j in range(1,len(motifLists[i])):
			line =''
			for k in range(2,len(motifLists[i][j])):
				line = line + str(motifLists[i][j][k]) + '\t'
			line=line[:-1]
			line = line + '\n'
			newFile.write(line)

def chooseName(number):
	if (number=='0'):
		return 'H3K27ac_dhs'
	elif (number=='1'):
		return 'H3K4me1_dhs'
	elif (number =='2'):
		return 'H3K4me3_dhs'
	elif (number == '3'):
		return 'HDAC2_dhs'
	elif (number == '4'):
		return 'H3K27ac_all'
	elif (number == '5'):
		return 'H3K4me1_all'
	elif (number == '6'):
		return 'H3K4me3_all'
	elif (number == '7'):
		return 'HDAC2_all'

def generateSpecificMatrix(site, mark, motifList):
	number = 0
	order = ['name','sequence']
	os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/'+site+'/'+mark)
	for run in os.listdir(os.getcwd()):
		if (run!='.DS_Store' and run.find('none')==-1):
			os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/'+site+'/'+mark+'/'+run)
			
			if (os.path.isfile('knownresults.txt')):
				number = number+1
				
				order.append(run)
				
				temp = open('knownResults.txt')
				temp.readline()
				
				while True:
					oldLine = temp.readline()
					if not oldLine: break
					
					sections = oldLine.split('\t')
					nameMotif = sections[0]
					pVal = sections[2]
					pValSplit = pVal.split('e')
					pValNum = pValSplit[1]
					
					for i in range (1, len(motifList)):
						if (nameMotif == motifList[i][0]):
							motifList[i].append(-int(pValNum))
				
			for i in range(1,len(motifList)):
				if (len(motifList[i])!= 2+number):
					motifList[i].append(0)
				
	motifList[0]=order
				
def generateSeparateMatrices(motifLists):
	os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse')
	for siteFolder in os.listdir(os.getcwd()):
		if (siteFolder=='dhsSites' or siteFolder=='allSites'):
			os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/'+siteFolder)			
			for markFolder in os.listdir(os.getcwd()):
				if (markFolder!='.DS_Store'):
					generateSpecificMatrix(siteFolder, markFolder, chooseMotifList(siteFolder, markFolder, motifLists))

def populateMotifList(namesOfMotifs, sequences, motifList):
	for i in range (0,len(namesOfMotifs)):
		temp = [namesOfMotifs[i], sequences[i]]
		motifList.append(temp)

def generateSepMotifLists (motifList):
	
	motifListDHS_H3K27ac = copy.deepcopy(motifList)
	motifListDHS_H3K27ac.insert(0,'')
	motifListDHS_H3K4me1 = copy.deepcopy(motifList)
	motifListDHS_H3K4me1.insert(0,'')
	motifListDHS_H3K4me3 = copy.deepcopy(motifList)
	motifListDHS_H3K4me3.insert(0,'')
	motifListDHS_HDAC2 = copy.deepcopy(motifList)
	motifListDHS_HDAC2.insert(0,'')

	motifListAll_H3K27ac = copy.deepcopy(motifList)
	motifListAll_H3K27ac.insert(0,'')
	motifListAll_H3K4me1 = copy.deepcopy(motifList)
	motifListAll_H3K4me1.insert(0,'')
	motifListAll_H3K4me3 = copy.deepcopy(motifList)
	motifListAll_H3K4me3.insert(0,'')
	motifListAll_HDAC2 = copy.deepcopy(motifList)
	motifListAll_HDAC2.insert(0,'')

	motifLists=[]
	motifLists.append(motifListDHS_H3K27ac)
	motifLists.append(motifListDHS_H3K4me1)
	motifLists.append(motifListDHS_H3K4me3)
	motifLists.append(motifListDHS_HDAC2)
	motifLists.append(motifListAll_H3K27ac)
	motifLists.append(motifListAll_H3K4me1)
	motifLists.append(motifListAll_H3K4me3)
	motifLists.append(motifListAll_HDAC2)
	
	return motifLists

def chooseMotifList (site, mark, motifLists):
	if (site == 'dhsSites'):
		if (mark == 'H3K27ac'):
			return motifLists[0]
		if (mark == 'H3K4me1'):
			return motifLists[1]
		if (mark == 'H3K4me3'):
			return motifLists[2]
		else:
			return motifLists[3]
	else:
		if (mark == 'H3K27ac'):
			return motifLists[4]
		if (mark == 'H3K4me1'):
			return motifLists[5]
		if (mark == 'H3K4me3'):
			return motifLists[6]
		else:
			return motifLists[7]

def generateInitialLists (namesOfMotifs, sequences, notes):
	count = 0
	number = 0
	for siteFolder in os.listdir(os.getcwd()):
		if (siteFolder=='dhsSites' or siteFolder=='allSites'):
			os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/'+siteFolder)			
			for markFolder in os.listdir(os.getcwd()):
				if (markFolder!='.DS_Store'):
					os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/'+siteFolder+'/'+markFolder)					
					for runFolder in os.listdir(os.getcwd()):
						if (runFolder!='.DS_Store'):						
							os.chdir('/Users/pranav/Desktop/ScienceResearch/results/UpdADMouse/mouse/'+siteFolder+'/'+markFolder+'/'+runFolder)				
							number = number +1
							if (os.path.isfile('knownResults.txt')):					
								temp = open('knownResults.txt')
								temp.readline()
								while True:
									oldLine = temp.readline()
									if not oldLine: break
									
									sections = oldLine.split('\t')
									
									nameMotif = sections[0]
									sequence = sections[1]
									found = False
						
									for name in namesOfMotifs:
										if nameMotif == name:
											found = True
						
									if not found:
										namesOfMotifs.append(nameMotif)
										sequences.append(sequence)
								
								count = count+1
							else:
								sets = runFolder.split('_')
								notes.write(markFolder + ' in ' + siteFolder + ' does not have a known results file for ' + sets[0] + ' compared to ' + sets[1] + '\n')
	return count					
						
if __name__ == '__main__':
	main()