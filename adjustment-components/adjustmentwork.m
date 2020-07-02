clc ; clear ;

import Adjustment.EnDirectAdjustment.*

yaklas = [123.829 ;104.635 ; 138.113 ; 80.673] ;
dh = [43.156 ;19.219; 33.524 ; 57.440 ;23.962; 14.267] ;
p = [1.54;1.25;1.00;0.71;0.67;0.51];
P = diag(p) ;
A = [1 0 0 -1; 1 -1 0 0; 0 -1 1 0; 0 0 1 -1; 0 1 0 -1; -1 0 1 0] ;
l = [0;24;46;0;0;-17];

out = LevelNet('A', A,'P', P, 'l', l, 'x0', yaklas, 'dH', dh, 'Data',dh);
out.stochasticsModel();
out.functionalModel();
out.accuracy() ;

