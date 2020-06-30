function [out] = chiSquare(data, k, d, ort, std, check)
s = num2str(min(data)*check(1)) ;
x = floor(str2double(s(end-2:end))) ;
xup = num2str(ort* check(1)) ;
xup = str2double(xup(end-2:end)) ;
input.x = x ;
count = 1 ;
while true
    count = count + 1;
    input.x(count) = input.x(count - 1) + d ;
    if count == k + 1
        break ;
    end
end

out.x = input.x ;
out.z = round((input.x - xup) ./ std, 2) ;
out.fiz = [0, round(normcdf(out.z), 3), 1] ;

for i = 1 : numel(input.x) - 1
    ncount = 0;
    for j = 1 : numel(data)
        measure = num2str(data(j)*check(1) * 10 ) ;
        n = str2double(measure(end-2 : end)) 
        if input.x(i)*10 <= n && n < input.x(i+1)*10
            ncount = ncount + 1 ;
        end
    end
    out.ni(i) = ncount ;
end

pi = diff(out.fiz) ;
out.pi = pi(2:end-1) ;
out.npi = numel(data) .* out.pi ;
out.ni_npi = round(out.ni - out.npi, 2) ;
out.chivalue = round(sum(((out.ni_npi).^2) ./ out.npi), 3) ;

end