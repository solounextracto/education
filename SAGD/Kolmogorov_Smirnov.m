function [out] = Kolmogorov_Smirnov(data, d, ort, std, check)
if check(2) == 3
    df = [1 1];
elseif check(2) == 5
    df = [2 10] ;
end
s = num2str(min(data)*check(1)) ;
x = floor(str2double(s(end-df(1):end))) ;
xup = num2str(ort* check(1)) ;
xup = str2double(xup(end-df(1):end)) ;
smax = num2str(max(data)*check(1)) ;
xmax = floor(str2double(smax(end-df(1):end))) ;
input.x = x ;

input.x = counter(input.x) ;

function [outx] = counter(x)
count = 1 ;
while true
    count = count + 1;
    x(count) = x(count - 1) + d ;
    if max(x) > xmax
        break ;
    end
end
mx = num2str(max(data)*check(1)) ;
mx = str2double(mx(end-df(1):end))*10 ;
if mx > max(x) * 10
    d = d + .1 ;
    outx = counter(input.x) ;
else
    outx = x ;
end
end

out.x = input.x ;
out.z = round((input.x - xup) ./ std, 2) ;

for i = 1 : numel(input.x) - 1
    ncount = 0;
    for j = 1 : numel(data)
        measure = num2str(data(j)*check(1) * df(2) ) ;
        n = str2double(measure(end-df(1) : end)) ;
        if input.x(i)*df(2) <= n && n < input.x(i+1)*df(2)
            ncount = ncount + 1 ;
        end
    end
    out.ni(i) = ncount ;
end


out.ni = [0, out.ni] ;
out.Kx = cumsum(out.ni) ;
out.Hx = round(out.Kx ./ numel(data), 2) ;
out.fiz = round(normcdf(out.z), 4) ;
out.D0 = round(out.Hx - out.fiz, 4) ;

out.ksvalue = round(max(abs(out.D0)), 4) ;
out.d = d ;

end
