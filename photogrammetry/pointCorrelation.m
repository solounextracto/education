function [out] = pointCorrelation(L, R, limit)
gL = round(sum(L(:)) / numel(L)) ;
gR = round(sum(R(:)) / numel(R)) ;

% (L - gL) .* (R - gR)
% sum(sum((L - gL).^2)) 
% sum(sum((R - gR).^2))
numerator = sum(sum((L - gL) .* (R - gR))) ;
denominator = sqrt(sum(sum((L - gL).^2)) * sum(sum((R - gR).^2))) ;

g = numerator / denominator ;

out.g = g ;
if g > limit
    fprintf('Bu iki g�r�nt� par�as� g = %.2f > %.2f oldu�u i�in nokta kolerasyon y�ntemine g�re e�lenir.', g, limit)
else
    fprintf('Bu iki g�r�nt� par�as� g = %.2f < %.2f oldu�u i�in nokta kolerasyon y�ntemine g�re e�lenmez.', g, limit)
end
end