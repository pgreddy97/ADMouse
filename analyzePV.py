#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import sys
import os
import os.path
import copy

def main():

	os.chdir(sys.argv[1]+'/pvValues')
	for folder in os.listdir(os.getcwd()):
		if (folder!='.DS_Store'):
			makeAndPrintClusters(folder)

def makeAndPrintClusters(folderName):
	os.chdir(sys.argv[1]+'/pvValues/'+folderName+'/au')
	
	
	for auFile in os.listdir(os.getcwd()):
		if (auFile!='.DS_Store'):
			os.chdir(sys.argv[1]+'/pvValues/'+folderName+'/au')
			sigRows = getSignificantRows(auFile)
			clusterList = getClusters(sigRows, folderName, auFile)
		
			os.chdir(sys.argv[1]+'/pvValues/'+folderName+'/clusters')
			outputFile = open(auFile, 'w')
			outputFile.write('clusters\n')
			for cluster in clusterList:
				outputFile.write(cluster+'\n')
	
	

#def getSingleCluster(num, labelList, mergeList, str):
#	str = str + '<'
#	num = int(num)
#	print num
#	print mergeList[num]
#	
#	if (int(mergeList[num][0])<0):
#		str = str + labelList[-int(mergeList[num][0])]+' '
#	else:
#		getSingleCluster(mergeList[num][0], labelList, mergeList, str)
#	
#	if (int(mergeList[num][1])<0):
#		str = str + labelList[-int(mergeList[num][1])]+ ' '
#	else:
#		getSingleCluster(mergeList[num][1],labelList, mergeList, str)
#	
#	str = str + '>'
#	return str

def getSingleCluster(num, labelList, mergeList):
	str = '<'
	num = int(num)
	
	if (int(mergeList[num][0])<0):
		str=str+labelList[-int(mergeList[num][0])]+' '
	else:
		str=str+getSingleCluster(mergeList[num][0],labelList,mergeList)
	
	if (int(mergeList[num][1])<0):
		str=str+labelList[-int(mergeList[num][1])]+' '
	else:
		str=str+getSingleCluster(mergeList[num][1],labelList,mergeList)
	
	str=str+'>'
	return str

def getClusters(sigRows, folderName, auFile):
	clusterList = []
	labelList = getLabelList(folderName, auFile)
	mergeList = getMergeList(folderName, auFile)
	for i in range(0,len(sigRows)):
		temp = getSingleCluster(int(sigRows[i]), labelList, mergeList)
		clusterList.append(temp)
	return clusterList

def getSignificantRows(auFile):
	sigRows=[]
	temp=open(auFile)
	auLine = ''
	while True:
		line = temp.readline()
		if not line: break
		
		pasteLine = line[:-1]+' '
		auLine = auLine + pasteLine
	
	auVector = auLine.split(' ')
	auVector.pop()
	
	for i in range(0,len(auVector)):
		if (float(auVector[i])>0.95):
			temp = i + 1
			sigRows.append(temp)
		
	return sigRows

def getLabelList (folderName, auFile):
	os.chdir(sys.argv[1]+'/labels/'+folderName)
	temp = open(auFile)
	lines = temp.readlines()
	
	for i in range(0,len(lines)):
		lines[i]=lines[i][:-1]
	
	return lines

def getMergeList (folderName, auFile):
	os.chdir(sys.argv[1]+'/pvValues/'+folderName+'/merge')
	temp = open(auFile)
	mergeList = [['0','0']]
	temp.readline()
	while True:
		line = temp.readline()
		if not line: break
		
		splitLine = line.split(' ')
		second = splitLine[2][:-1]
		tempObj = [splitLine[1],second]
		mergeList.append(tempObj)
	
	return mergeList

def decMag (num):
	if (num<0):
		return num+1
	else:
		return num-1




if __name__ == '__main__':
	main()