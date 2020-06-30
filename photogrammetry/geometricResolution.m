%   imageWidth -> Resim geniþligi , 23x23 etc. (cm) , [23, 23]
%   pixelSize      ->  Pixel boyutu 60, 30, 7.5 etc. (mikron),  [606 60]
%   CCD            ->  CCD boutlarý, [19, 15]mm, 19x15 , etc.
%   depth           ->  Renk Derinligi 8bit, 12bit etc.
%   mr               ->  map scale , 1000, 4000, 15000 etc.
%   DPI             ->  map scan, 200, 100 etc.
%   PixelArea   -> the area that a pixel covers on earth , m^2 ;
function [out] = geometricResolution(varargin)
input.image = [] ;
input.size = [] ;
input.pixelsize = [] ;
input.ccd = [] ;
input.depth = [] ;
input.mr = [] ;
input.dpi = [] ;

for count = 1 : 2 : length(varargin)
    if mod(length(varargin), 2)
        varargin(end) = [] ;
    end
    input.(lower(varargin{count})) = varargin{count + 1} ;
end

if isempty(input.pixelsize) && isempty(input.mr) && isempty(input.dpi) && numel(input.ccd) == 2
    px = input.ccd(1) / input.size(1) ;
    py = input.ccd(2) / input.size(2) ;
    input.pixelsize = [px, py] ;
elseif isempty(input.pixelsize) && isempty(input.mr) && isempty(input.dpi) && numel(input.ccd) == 1
    diagonal = sqrt(sum((input.size).^2)) ;
    input.pixelsize = (((input.ccd * (1 / sqrt(2))) / diagonal)* 2.54)*10 ; % inch to cm , cm to mm ; 
    input.pixelsize = [input.pixelsize, input.pixelsize] ;
end

if ~isempty(input.mr) && ~isempty(input.dpi)
    input.pixelsize = (25400 / input.dpi)/1e3 ; % 1inch = 2.54 cm = 25400 micron to mm;
    input.pixelsize = [input.pixelsize, input.pixelsize] ;
end

if isempty(input.size) && isempty(input.mr) && isempty(input.dpi)
    row = input.image(1) ./ (input.pixelsize(1)/1e4) ;
    column  = input.image(2) ./ (input.pixelsize(2)/1e4) ;
    input.size = [row, column] ;
end

input.byte = input.depth / 8 ;
out.Area = (prod(input.size) * input.byte) / 1024.^2 ;
out.PixelSize = round((input.pixelsize).*1e3) ; % mikron
if ~isempty(input.mr)
    gsd = input.mr * input.pixelsize(1) ; % mm
    out.PixelArea = (gsd/1e3)^2 ; % the area that a pixel covers on earth - mm^2 to m^2 ;
end