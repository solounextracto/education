% Station Point Adjustment
% r -> dogrultular.[1.silsile, 2.silsile, 3.silsile, etc.]
function [out] = spa(r)
[row, col] = size(r);
meanr = sum(r, 2) ./ col ;
di = (meanr - r ) ;
sumdi = (sum(di, 1)) ;
z = sumdi ./ row ;
upperdi = (sumdi.*10000).^2 ;
vi = di - z ;
vv = sum(sum((vi.*10000).^2)) ;
m0 = sqrt((vv)/((row-1)*(col-1)));
md = m0 / sqrt(col);
mA = md*sqrt(2);

out.mean = round(meanr,5);
out.di = round(di.*10000,1);
out.sumdi = round(sumdi.*10000,1);
out.z = round(z.*10000,1);
out.vi = round(vi.*10000,1);
out.upperdi = round(upperdi,2);
out.vv = round(vv,2) ;
out.m0 = round(m0,1);
out.md = round(md,1);
out.mA = round(mA,1);
end