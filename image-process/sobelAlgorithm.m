%--------------------------------------------------------------------------
%#  Title  : Sobel Algorithm
%#  Date   : 04.08.2020
%#  Author : @sue
%#
%
% sobelAlgorithm ->
% Edge removal using the sobel algorithm.
%
% inputImage = imread('office_5.jpg') ;
% ConvolutionMatrixSize = 5 ;
% 
% outputImage = sobelAlgorithm(inputImage, ConvolutionMatrixSize) ;
% 
% figure, imshowpair(inputImage,outputImage,'montage')
% 
%--------------------------------------------------------------------------
function output = sobelAlgorithm(im, element)

if element <= 0
   element = 3;
   disp(['Since the size entered is inconsistent, the default value is entered as ',num2str(element),'.']);
end

if mod(element,2) == 0
   element = element + 1 ; 
end

image.Band = size(im, 3);

if image.Band < 3 
    error('matrix sizes are inconsistent...')
else
    
image.Width = size(im, 2);
image.Height = size(im, 1);

setElement =  (element - 1) / 2 ;
P = [];

for i = setElement + 1 : ( image.Height - setElement )
    for j = setElement + 1 : ( image.Width - setElement )
        P1 = sum(im(i - 1, j - 1, :)) / image.Band;
        P2 = sum(im(i    , j - 1, :)) / image.Band;
        P3 = sum(im(i + 1, j - 1, :)) / image.Band;
        P4 = sum(im(i - 1, j    , :)) / image.Band;
        P5 = sum(im(i    , j    , :)) / image.Band;
        P6 = sum(im(i + 1, j    , :)) / image.Band;
        P7 = sum(im(i - 1, j + 1, :)) / image.Band;
        P8 = sum(im(i    , j + 1, :)) / image.Band;
        P9 = sum(im(i + 1, j + 1, :)) / image.Band;
        
        gX = abs( -P1 + P3 - 2 * P4 + 2 * P6 - P7 + P9 );
        gY = abs( P1 + 2 * P2 + P3 - P7 - 2 * P8 - P9);
        
        sobel = int16(sqrt( gX ^ 2 + gY ^ 2 ));
        if sobel > 255 
            sobel = 255 ;
        end
        sobelValue = [sobel, sobel, sobel];
        P(i, j, 1:3) = sobelValue; 
    end
end
output = uint8(P);
end


