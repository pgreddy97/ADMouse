#!/usr/bin/python -tt

#include<stdio.h>
#include<string.h>
import os

def main():
    narrowPeakFiles = '/srv/gsfs0/projects/kundaje/users/summerStudents/2014/pgreddy/data/UpdADMouse/mouse/DHS/NarrowPeakFiles'
    os.chdir('/srv/gsfs0/projects/kundaje/users/summerStudents/2014/pgreddy/data/UpdADMouse/mouse/DHS')
    os.mkdir('BedFiles')

    for peakFile in os.listdir('/srv/gsfs0/projects/kundaje/users/summerStudents/2014/pgreddy/data/UpdADMouse/mouse/DHS/NarrowPeakFiles'):
        os.chdir('/srv/gsfs0/projects/kundaje/users/summerStudents/2014/pgreddy/data/UpdADMouse/mouse/DHS/NarrowPeakFiles')
        narrowP = open (peakFile)
        os.chdir('/srv/gsfs0/projects/kundaje/users/summerStudents/2014/pgreddy/data/UpdADMouse/mouse/DHS/BedFiles')
        
        header = peakFile.split('.narrowPeak')
        bedF = open (header[0]+'.bed', 'w')
        
        while True:
            oldLine = narrowP.readline()
            if not oldLine: break
            
            sections = oldLine.split('\t')
            if (len(sections)>2):
                bedF.write(sections[0]+'\t'+sections[1]+'\t'+sections[2]+'\n')
        
        narrowP.close()
        bedF.close()

if __name__ == '__main__':
    main()
