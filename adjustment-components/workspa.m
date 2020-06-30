clc;clear all

silsile1 = [0.0000
                107.4125
                158.9374
                256.7728];

silsile2 = [0.0000
                107.4130
                158.9368
                256.7736];
            
silsile3 = [0.0000
                107.4120
                158.9385
                256.7748] ;
            
C = [silsile1, silsile2, silsile3] ;

[out] = spa(C)