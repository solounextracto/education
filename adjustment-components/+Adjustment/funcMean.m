function mf = funcMean(func, approx, m0, Qxx)

Kll = Qxx ;

symstr = func ;
aprxSplit = regexp(approx,'\,', 'split') ;
eq = str2sym(symstr);
Array = symvar(eq) ;
array_string = char(Array) ;
array_string([1:9, end-2:end]) = [] ;
array_string = array_string(find(~isspace(array_string))) ;
eval(['syms F(',array_string,')']) ;
eval(['F(',array_string,') = ',symstr]) ; clc
splitStr = regexp(array_string,'\,', 'split') ;
ismem = ismember(aprxSplit,splitStr) ;
A_ll = [] ;
kx = 1 ;
for count = 1 : length(aprxSplit)
    if count == length(aprxSplit) && length(splitStr) < length(aprxSplit)
%         break
        kx = kx - 1 ;
    end
    result = eval(['diff(F,', splitStr{kx} ,')']) ;
    if ismem(count)
        A_ll(count) = result ;
        kx = kx + 1;
    else
        A_ll(count) = 0 ;
    end
end
qff = A_ll*Kll*A_ll' ;
mf = m0*sqrt(qff) ;
end