% decimal to Binary , etc.
clc ; clear all

% example 23x23 aerial image, 8bit panchromatic.
image = [23, 23] ;
pixel = [7.5, 7.5] ;
storage = geometricResolution('image', image, 'pixelsize', pixel, 'depth', 8) ;

size = [1500 1200] ;
ccd = [9, 7.2];
% depth = 12 ;
area = geometricResolution('size', size, 'ccd', ccd) ;
pix = [950 600] ;
image = transformImagePixel('pixel', pix, 'pixelsize', area.PixelSize,'size',size) ;

%%
clc ; clear all
mr = 4000;
dpi = 200;
out = geometricResolution('mr', 4000, 'dpi', dpi) ;
%%
clc ; clear all;
size = [24000 7000] ;
ccd = [100/2]; % inc
out = geometricResolution('size', size, 'ccd', ccd) ;


%%
% transform image , pixel
load x.mat
load y.mat
im = [x, y];
size = [14430 9420 3];
pixsize = 7.2;

pixel = transformImagePixel('image', im, 'size', size, 'pixelsize', pixsize) ;
image = transformImagePixel('pixel', [pixel.x, pixel.y], 'size', size, 'pixelsize', pixsize) ;

%%
clc;clear all;
h = 1000 ; %metre
cameraparams = [-0.072, 0.036, 100] ; % mm
imagesize = [103.896, 67.824] ; % mm
gsd = 7.2 ; % cm
imagecoord = [-13.284 4.982; 21.016 0.750] ; % mm


pixel = transformImagePixel('h', h, 'imagesize', imagesize, 'gsd', gsd, 'image', imagecoord, 'cameraparameters', cameraparams) ;

image = transformImagePixel('h', h, 'imagesize', imagesize, 'gsd', gsd, 'pixel', [pixel.x, pixel.y], 'cameraparameters', cameraparams) ;

%Histogram equ
% a = floor(rand(50,50)*10);
% sum(a(:) == 10) % 1 ,2 ,3 ,4 etc.

%% Kayma Miktari
clc;clear all;

image = [52, -35]; % mm
mr = 15000;
dh = 150; % m
s = 18; % cm
type = 'Geniþ' ;

kayma = singleImageEvaluation('image',image, 'mr', mr, 'dh', dh, 's', s, 'type', type) ;
