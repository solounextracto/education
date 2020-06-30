function [out] = transformImagePixel(varargin)
transform.image = [] ;
transform.pixel = [] ;
transform.size = [] ;
transform.pixelsize = [] ;
transform.h = [] ;
transform.cameraparameters = [] ;
transform.imagesize = [] ;
transform.gsd = [] ;
transform.x0 = [0];
transform.y0 = [0];
for count = 1 : 2 : length(varargin)
    if mod(length(varargin), 2)
        varargin(end) = [] ;
    end
    transform.(lower(varargin{count})) = varargin{count + 1} ;
end

if   ~isempty(transform.h) && ~isempty(transform.cameraparameters) && ...
      ~isempty(transform.imagesize) && ~isempty(transform.gsd)
    transform.mr = transform.h / (transform.cameraparameters(3)/1e3) ;
    transform.pixelsize = ( transform.gsd / transform.mr ) * 1e4 ;
    row = (transform.imagesize(1) / transform.pixelsize)*1e3 ;
    column = (transform.imagesize(2) / transform.pixelsize)*1e3 ;
    transform.size = [row, column] ;
end

if ~isempty(transform.cameraparameters)
    transform.x0 = (transform.cameraparameters(1)*1e3) / (transform.pixelsize) ;
    transform.y0 = (transform.cameraparameters(2)*1e3) / (transform.pixelsize) ;
end

if numel(transform.pixelsize) == 1
    transform.pixelsize = [transform.pixelsize, transform.pixelsize] ;
end

if isempty(transform.pixel)
    try
        out.x = ( transform.image(:, 1)./(transform.pixelsize(1)/1e3)) + (transform.size(2) / 2) + transform.x0;
        out.y = (-transform.image(:, 2)./(transform.pixelsize(2)/1e3)) + (transform.size(1) / 2) + transform.y0;
    catch
        error('Please define valid coordinates... ')
    end
elseif isempty(transform.image)
    try
        out.x =  (transform.pixel(:, 1) - (transform.size(2) / 2) - transform.x0).*(transform.pixelsize(1)/1e3) ;
        out.y = -(transform.pixel(:, 2) - (transform.size(1) / 2) - transform.y0).*(transform.pixelsize(2)/1e3) ;
    catch
        error('Please define valid coordinates... ')
    end
end
out.parameters = transform ;
end