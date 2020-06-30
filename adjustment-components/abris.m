%   PoS, PoV -> point of stop and viewed.
%   SoS, SoV -> Style of stop and viewed.
function [out] = abris(PoS, PoV, SoS, SoV, r, z0)
 % string DN = SoS
 % string BN = SoV

if nargin >2
    SoS = strtrim(SoS) ;
    SoV = strtrim(SoV) ;
    if SoS == '+'
        out.DN = 'Sabit' ;
    else
        out.DN = 'Yaklaþýk' ;
    end
    if SoV == '+'
        out.BN = 'Sabit' ;
    else
        out.BN = 'Yaklaþýk' ;
    end
end


dY = PoV(1) - PoS(1) ;
dX = PoV(2) - PoS(2) ;

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
a_ik = -round((sin(degrees*(pi / 200)) / (dist*100)) * ((200/pi)*10000),5) ;
b_ik = round((cos(degrees*(pi / 200)) / (dist*100)) * ((200/pi)*10000),5) ;


if nargin > 4
    if (SoS == '+' && SoV == '+') || (SoS == '-')
        TdiffR = degrees - r ;
    end
end
if nargin > 5
    if (SoS == '+' && SoV == '-') || (SoS == '-')
        alpha = r + z0 ;    % 
        if alpha > 400
            alpha = alpha - 400 ;
        end
        l = degrees - alpha ;  % -l
    else
        l_us = (degrees - r) - z0 ;    % -l
    end
end

out.Semt = round(degrees,5) ;
out.Distance = round(dist,3) ;

if nargin > 4
    if SoS == '+' 
        if SoV == '+'
            out.z = round(TdiffR, 5) ;
        end
    elseif SoS == '-'
        out.z = round(TdiffR, 5) ;
    end
end
if nargin > 5
    if SoS == '+' && SoV == '+'
        out.l_us = round((l_us)*10000,1) ;
    else
        out.a = a_ik ;
        out.b = b_ik ;
        out.alpha = round(alpha,5) ;
        out.l = round(((l)*10000),1) ;
    end
end

end