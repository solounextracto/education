%  point correlation 
clc ; clear all;

left = [48 167 32;180 120 173; 29 165 46];
right = [53 165 29;168 191 155; 46 172 27] ;
limit = 0.95 ;

correlation = pointCorrelation(left,right,limit)