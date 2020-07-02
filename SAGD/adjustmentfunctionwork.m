clc;clear all;

direct = [1 0.5; 2 2.5; 3 2; 4 4; 5 3.5; 6 6; 7 5.5] ;
curve = [0 2.1; 1 7.7; 2 13.6; 3 27.2; 4 40.09; 5 61.1] ;
fitting = [2 5.1; 2.3 7.5; 2.6 10.6; 2.9 14.4; 3.2 19.0];

out = adjustmentFunctions(fitting) ;