function [out] = mannWald(data, k, mn, sd, check)
if check(2) == 3
    df = [1 1];
elseif check(2) == 5
    df = [2 10] ;
end
p = round(1 / k, 1) ;
i = 0 : k+1 ;
fiz = round(i .* p, 1);
z = norminv(fiz) ;
xmean = num2str(mn*check(1)) ;
xmean = str2double(xmean(end-df(1):end)) ;
x = round(z.*sd + xmean, 2) ;

out.fiz = fiz ;
out.z = round(z, 2) ;

for i = 1 : numel(x) - 1
    ncount = 0;
    for j = 1 : numel(data)
        measure = num2str(data(j)*check(1) * df(2) ) ;
        n = str2double(measure(end-df(1) : end)) ;
        if x(i)*df(2) <= n && n < x(i+1)*df(2)
            ncount = ncount + 1 ;
        end
    end
    out.ni(i) = ncount ;
end

np = round(numel(data) * p,1) ;
ni_np = out.ni - np ;

out.x = x ;
out.ni_np = ni_np ;
out.mannwald = sum((ni_np).^2) / np ;

end