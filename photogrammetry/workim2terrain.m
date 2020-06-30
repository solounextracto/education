% image to terrain workaround
clc ; clear all;

M = [0.99967 0.02548 -0.00403; -0.02554 0.99954 -0.01639; 0.00361 0.01649 0.999986];
cameraparams = [-0.072 -0.036 100.5] ;
imagepoint = [425482.254 4195036.580 1739.756];
% dxyz = [100 -200 -1900] ;

terraincoordinate = [425773.745 4194603.640 593.845];

out = terrain2im('M',M, 'cameraparameters', cameraparams, 'imagepoint', imagepoint, 'terrain', terraincoordinate) ;
% out2 = terrain2im('M',M, 'cameraparameters', cameraparams, 'dxyz', dxyz, 'terrain', terraincoordinate);

pixl = transformImagePixel('image', out.Image, 'size', [14430, 9420], 'pixelsize', 7.2, 'cameraparameters', cameraparams) ;