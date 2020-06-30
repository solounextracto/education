% histogram equalization workaround

clc ; clear all;

rep = [50 250 800 110 800 150 900 50 190 300] ; 
out = histogramEqualization('repeater', rep, 'grayscale', [0 9]);