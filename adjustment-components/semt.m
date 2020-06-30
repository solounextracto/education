function [out] = semt(DN, BN)
dY = BN(1) - DN(1) ;
dX = BN(2) - DN(2) ;

dist = sqrt(dY^2 + dX^2) ;
semt = abs(atan((dY / dX))) * (200/pi) ;
if dY > 0 && dX > 0
    degrees = semt ;
elseif dY >  0 && dX < 0
    degrees = 200 - semt ;
elseif dY < 0 && dX < 0
    degrees = 200 + semt ;
else
    degrees = 400 - semt ;
end
a_ik = -(sin(degrees*(pi / 200)) / (dist*100)) * ((200/pi)*10000) ;
b_ik = (cos(degrees*(pi / 200)) / (dist*100)) * ((200/pi)*10000) ;

out.Semt = round(degrees,5) ;
out.Distance = round(dist,3) ;
out.a = a_ik ;
out.b = b_ik ;
end