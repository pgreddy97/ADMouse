#!/usr/bin/python -tt
import sys

def main():
	old = open (sys.argv[1])
	top = open (sys.argv[2]+ '_05.bed', 'w')
	border = open (sys.argv[2]+ '_Border.bed', 'w')
	bottom = open (sys.argv[2]+ '_Bottom.bed', 'w')		
	count = 0
	less = True
	while less is True:
		oldLine = old.readline()
		if not oldLine: break
		listOfWords = oldLine.split('\t')
		if 'e' in listOfWords[-1] or (float(listOfWords[-1][:-2])<0.05):
			top.write(oldLine)
			count=count+1
		else:
			less = False
	print count
	lines=old.readlines()
	for i in range(30000):
		border.write(lines[i])
	for j in range(30000):
		bottom.write(lines[-(30000-j)])
	
	
	
if __name__ == '__main__':
  main()