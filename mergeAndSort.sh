#!/usr/bin/env bash 

module load bedtools

cd /srv/gsfs0/projects/kundaje/users/summerStudents/2014/pgreddy/data/UpdADMouse/mouse/DHS/BedFiles

for i in $(ls wg*); do
    cat $i merged.bed > temp1.bed
    bedtools sort -i  temp1.bed > temp2.bed
    bedtools merge -i temp2.bed > merged.bed
    rm temp1.bed
    rm temp2.bed
done
