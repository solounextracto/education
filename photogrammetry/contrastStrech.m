%   image - image (60, 60) etc.
%   class - 'uint8' , 'uint16', [0 255], etc.
%   count - image(5,5), image(20,30) , x:5 y:5 , etc. (pixel coordinate)
%   count - image(1), image(20), vector form. etc. 
function [out] = contrastStrech(image, class, count)
if ischar(class)
    outmin = double(intmin(class)) ; 
    outmax = double(intmax(class)) ;
else
    outmin = class(1) ;
    outmax = class(2) ;
end
ing = image(:) ;
inmin = min(ing) ;
inmax = max(ing) ;
t1 = outmin - inmin ;
t2 = (outmax - outmin) / (inmax - inmin) ;
out.g = round((ing + t1) .* t2) ;
if nargin > 2
    if isvector(image)
        for i = 1 : numel(count)
            out.selection(i) = round(out.g(count(i))) ;
        end
    else
        for i = 1 : length(count)
            out.selection(i) = round(out.g(count(i, 1) + ((count(i, 2) - 1) * length(image)))) ;
        end
    end
end
end