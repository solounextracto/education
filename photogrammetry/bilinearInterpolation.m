%   pixel - input pixel coordinates, [2.4, 2.7] etc.
%   imageCoordinate - input image coordinates, [2,2; 3,2; 2,3; 3,3] etc.
%   iamgeGraysacel - input image gray value, [9; 6; 15; 18] etc.
function [out] = bilinearInterpolation(pixel, imageGrayscale, imageCoordinate)
if nargin < 3
    imageCoordinate = [floor(pixel(1)), floor(pixel(2)); ceil(pixel(1)), floor(pixel(2)); ...
        floor(pixel(1)), ceil(pixel(2)); ceil(pixel(1)), ceil(pixel(2))] ;
end
x = imageCoordinate(:, 1) - pixel(:, 1) ;
y = imageCoordinate(:, 2) - pixel(:, 2) ;
distance = round(sqrt(x.^2 + y.^2),3) ;
D_upper = round(distance.^2, 2) ;
numerator = round(imageGrayscale ./ D_upper, 2) ;
denominator = round(1 ./ D_upper, 3) ;
g = sum(numerator) / sum(denominator);
out.new = round(g) ;
out.float = round(g, 2) ;
disp('------------------------------------------------------')
disp(['Coordinate : x = ', num2str(pixel(1)), ', y = ', num2str(pixel(2))])
fprintf('\nx, y\tGray\tD\tD^2\tZ/D^2\t1/D^2\n');
fprintf('%d, %d\t%d\t%.3f\t%.2f\t%.2f\t%.3f\n', [imageCoordinate(:, 1), imageCoordinate(:, 2), ...
    imageGrayscale, distance, D_upper, numerator, denominator]');
fprintf("\n\tNew gray level, g' : %d\n", out.new) ;
disp('------------------------------------------------------')
end