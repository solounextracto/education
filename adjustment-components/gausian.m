% clc;clear all;
A = [-2 0.5 ;0.3 1 ; 1 0;-1 2 ; 0 -0.2] ;
l = [-5;2;-1;3;2] ;
p = [0.5;1;1.5;0.8;1.3] ;

self = GausianResult('A',A, 'l', l,'p',p);
disp(self.reduction)

%%
% clc;clear all
% 
% A = [-2.65449 -1.60873 ;-0.40247 -5.01475 ; -2.911446 1.45117; 2.96799 1.38813] ;
% l = [84.5;68.0;50.3;-64.8] ;
% p = [2/3;2/3;2/3;2/3] ;
% 
% self = GausianResult('A',A, 'l', l,'p',p);
% disp(self.reduction)
