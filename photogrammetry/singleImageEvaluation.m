%   dh - terrain elevation , [150], etc.
%   mr - scale
%   type - camera type , 'Genis', 'Normal', 'Cok Genis'
%   s - camera size, 18x18, 23x23 etc, [18],
%   c - camera canstant
%   h - flight height
%   image - image coordinates. [52, -35; ...]mm
function [out] = singleImageEvaluation(varargin)
input.dh = [] ; 
input.mr = [] ;
input.type = [] ;
input.s = [] ;
input.c = [] ;
input.h = []; 
input.image = []; 
for count = 1 : 2 : length(varargin)
    if mod(length(varargin), 2)
        varargin(end) = [] ;
    end
    input.(lower(varargin{count})) = varargin{count + 1} ;
end

if isempty(input.c)
    if input.s == 23
        if strcmpi(input.type, 'Çok Geniş')
            input.c = 9 ;
        elseif strcmpi(input.type, 'Geniş')
            input.c = 15 ;
        elseif strcmpi(input.type, 'Normal')
            input.c = 30 ;
        end
    elseif input.s == 18
        if strcmpi(input.type, 'Geniş')
            input.c = 11.5 ;
        elseif strcmpi(input.type, 'Normal')
            input.c = 21 ;
        end
    end
end

out.Type = input.type ;
out.s = input.s ;
out.c = input.c ;

input.h = input.mr * (input.c/1e2) ;
input.r = sqrt(input.image(:, 1).^2 + input.image(:, 2).^2) ;
out.h = input.h ; % meter
out.r = round((input.dh / input.h).*input.r, 2) ;

end