%   pdf, start, fnish - str
%   extend - float.
%   output - [.811 .812 .813 .814 .815] etc.
function [outdata] = readpdfdata(pdf, start, finish, extend)
str = extractFileText(pdf);
i = strfind(str,start);
ii = strfind(str,finish);
start = i(1);
fin = ii(1);
output = extractBetween(str,start,fin-1) ;
output = output{1} ;
count = 1 ;
for s = 1 : length(output)
    if output(s) == '.'
        out.data(count, 1) = str2double(output(s+1:s+3)) ; % output(s+1:s+3)
        count = count + 1 ;
    end
end
outdata.data = out.data ;
if nargin > 3
outdata.veriables = extend + (out.data/1000) ;
end
end