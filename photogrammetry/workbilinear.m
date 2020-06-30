% bilinear interpolation
clc; clear all;

pix = [2.4, 2.7];
im = [2,2; 3,2; 2,3; 3,3];
gray = [9; 6; 15; 18] ;

% outbilinear = bilinearInterpolation(pix, gray, im) ;
outbilinear2 = bilinearInterpolation(pix, gray) ;

%% contrast strech
clc;clear all;
im = [90, 50 100; 20 30 60; 50 210 44] ;
out = contrastStrech(im, [0 255]) ;
out2 = contrastStrech(im, 'uint8') ;
out3 = contrastStrech(im, 'uint8', [1,3; 2,2]) ;
vector = im(:) ;
out4 = contrastStrech(vector, [0 255], [3, 5, 1]) ;