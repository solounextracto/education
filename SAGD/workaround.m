% 
clc; clear all;

load edge.mat
% check = [10000, 5] ;
% out = chiSquare(S, check, 7, 1, 98.06067, 1.94);

out = NDAT(S, 'edge');
out.chisquare(5) ;