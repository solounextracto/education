%   M - rotation matrix
%   cameraparameters - interior parameters, [x0 y0 c(f)]mm , 
%   terrain - terrain coordinates , [X Y Z]m ,
%   imagepoint - picture shooting point , [X1 Y1 Z1; X2 Y2 Z2; ...] m ,
%   dXYZ - delta X Y Z Coordinates, [dX dY dZ]m ,
%   xr, yr - image coordinates, [x, y]mm ,
function [out] = terrain2im(varargin)
input.m = [] ;
input.cameraparameters = [];
input.terrain = [] ;
input.imagepoint = [] ;
input.dxyz = [] ;
for count = 1 : 2 : length(varargin)
    if mod(length(varargin), 2)
        varargin(end) = [] ;
    end
    input.(lower(varargin{count})) = varargin{count + 1} ;
end

if isempty(input.dxyz)
    input.dxyz = input.imagepoint - input.terrain ;
end

result.xr = [];
result.xy = [];
for i = 1 : size(input.dxyz, 1)
    result.xr(i) = (-input.cameraparameters(3) * ... 
            ((input.m(1,1)*input.dxyz(i, 1) + input.m(1,2)*input.dxyz(i, 2) + input.m(1,3)*input.dxyz(i, 3)) / ...
            (input.m(3,1)*input.dxyz(i, 1) + input.m(3,2)*input.dxyz(i, 2) + input.m(3,3)*input.dxyz(i, 3)))) + ...
            input.cameraparameters(1) ;

    result.yr(i) = (-input.cameraparameters(3) * ... 
            ((input.m(2,1)*input.dxyz(i, 1) + input.m(2,2)*input.dxyz(i, 2) + input.m(2,3)*input.dxyz(i, 3)) / ...
            (input.m(3,1)*input.dxyz(i, 1) + input.m(3,2)*input.dxyz(i, 2) + input.m(3,3)*input.dxyz(i, 3)))) + ... 
            input.cameraparameters(2) ;
end
out.Image = [result.xr; result.yr]' ;
end