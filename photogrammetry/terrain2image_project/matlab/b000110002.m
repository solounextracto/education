clearvars; clc

terrain = Terr2im.read('points.txt') ;
%%
work = Terr2im() ;
%%
work.improp = [14430, 9420, 7.2] ;
work.primepoint = [-0.144, 0, 100.5] ;
work.projectionpoint = [427116.06061, 4206076.87177, 1725.71198] ;
work.rotation = [-0.02242, 1.1115, -0.9816] ;
%%
M = work.M ;
%%
image = work.imagepoint(terrain) ;
%%
pixel = work.im2pix(image) ;
%%
im = imread('resim1.tif') ;

work.plot(pixel, im)