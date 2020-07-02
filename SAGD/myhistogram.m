% histogram bar graph, 
% data - 
% out = myhistogram(data) 
% output, histgram graph, class, range, frequency, classnumber.
function [out] = myhistogram(data)
input.veriables = [];
for i = 1 : numel(data)
    strdata = num2str(data(i)*1000) ;
    input.veriables(i) = str2double(strdata(end-2 : end)) ;
end
range = max(input.veriables) - min(input.veriables) ;
class = [30:10:180; 5:20] ;
for count = 1 : size(class, 2) - 1
    if class(1, count) <= numel(data) && class(1, count+1) >= numel(data)
        out.classnumber = class(2, count) ;
    end
end
sumclass = (min(sort(input.veriables))) ;
width =  range / out.classnumber ;
for s = 1 : out.classnumber
    sumclass(s+1) = sumclass(s) + (width) ;
    out.frequency(s) = sum(nonzeros(input.veriables.*10 >= sumclass(s)*10 & ...
        input.veriables.*10 <= sumclass(s+1)*10+.001)) ;
end


out.data = input.veriables ;
out.class = sumclass ;
out.range = range ;

h = histogram(out.data) ;
h.NumBins = out.classnumber ;
% h.BinEdges = out.class
end