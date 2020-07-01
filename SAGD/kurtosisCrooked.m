function [out] = kurtosisCrooked(data, check, mn, sd, degrees)
vi = round((mn - data) * check(1), 1) ;
c1 = round((-1 / (numel(data) * (sd)^3)) * sum(vi.^3), 3)  ; % crooked
c2 = round((( 1 / (numel(data) * (sd)^4)) * sum(vi.^4)) - 3, 3)  ; % kurtosis

crookedkurtosis = (c1^2 * (numel(data)/6)) + (c2^2 * numel(data)/24) ;
out.Kurtosis = round(crookedkurtosis, 3) ;

z1 = c1 * sqrt(numel(data) / 6) ;
z2 = c2 * sqrt(numel(data) / 24) ;

z = @(p) -sqrt(2) * erfcinv(p*2);
zscore = z(1 - ((degrees/100) / 4)) ;

if abs(z1) < zscore % çarpýklýk
    fprintf('|z1|=%.3f < z=%.2f , since there is no distortion in the distribution of the measurements\n', abs(z1), zscore) ;
else
    fprintf('|z1|=%.3f > z=%.2f , since there is distortion in the distribution of the measurements\n', abs(z1), zscore) ;
end
if abs(z2) < zscore % basýklýk
    fprintf('|z1|=%.3f < z=%.2f , since there is no distortion in the kurtosis of the measurements\n', abs(z2), zscore) ;
else
    fprintf('|z1|=%.3f > z=%.2f , since there is distortion in the distribution of the measurements\n', abs(z2), zscore) ;
end

out.c1 = c1 ;
out.c2 = c2 ;
out.vi = vi ;
end