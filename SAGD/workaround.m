% 
clc; clear all;

% load edge.mat
pdfname = '';
start = '';
finish = '';
originaldata = [];

S = readpdfdata(pdfname,start,finish,originaldata);
% check = [10000, 5] ;
% out = chiSquare(S, check, 7, 1, 98.06067, 1.94);

out = NDAT(S);

% out.kolmogorov_smirnov(5) ;

% out.chisquare(5)

% out.kurtosis(5) ;

% out.mannwald(5) ;
