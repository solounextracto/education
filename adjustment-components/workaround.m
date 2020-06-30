% clc;clear all;
% 
% C = [927595.796, 69163.870;
%         929216.764, 69456.480;
%         930293.251, 69292.073];
%     
% semtetc = semt(C(2,:),C(3,:)) ;
% 
% alpha = 57.0290 ;
% beta = 31.3474 ;
% kestneretc = kaestner(C, alpha, beta);
%%
% clc;clear all
% C= [27320.564, 23312.482 % 27
%        28935.783, 23104.238 % 28
%        26812.204, 21811.763 % 33
%        28874.896, 21756.706 % 34
%        ] ;
% 
% dogrultu = 44.40010 ;
% z0 = 20.79287 ;
% DN = '  - '   ;  % + Sabit nokta
% BN = '  + '    ; % - Yaklaþýk koordinatlarý bilinen nokta, eðer verilmemiþ ise kaestner yöntemine göre geriden kestirme yap
% 
% abrisetc = abris(C(3,:),C(2,:), DN, BN, dogrultu, z0) 

%%
% clc; clear all
% 
% C = [24648.56 ,16457.52 % 1
%         26276.39, 16651.32 % 2
%         24651.12, 14521.50 % 3
%         28162.57, 14571.36 % 4
%         26402.60 15394.50 % P
%         ] ;
% 
% dogrultu = 28.7605 ;
% z0 = 299.09659 ;
% 
% d =   4      ; % durulon dokta numarasý
% b =   5      ; % bakýlan nokta numarasý
% 
% DN = '  + '   ; 
% BN = '  - '    ; 
%     
% abrisetc = abris(C(d,:),C(b,:), DN, BN, dogrultu, z0) ;


