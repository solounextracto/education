function out = kaestner(C, alpha, beta)
ro = (pi/200) ;
a = semt(C(2,:), C(1, :)) ;
b = semt(C(2,:), C(3, :)) ;
teta = a.Semt - b.Semt ;
fiSumSimfi = 400 - (alpha + beta + teta) ;
mu = atan((((a.Distance)*sin(beta*ro)) / ((b.Distance)*(sin(alpha*ro)))))*ro^-1;
fiDiffSimfi = (atan(tan((fiSumSimfi/2)*ro)*cot((50+mu)*ro))*ro^-1)*2 ;
fi = (fiSumSimfi+fiDiffSimfi)/2 ;
simfi = (fiSumSimfi-fiDiffSimfi)/2 ;
a_semt = (a.Semt - 200) + fi  ;
b_semt = (b.Semt - 200) - simfi ;
approx = [a_semt, b_semt] ; 
for count = 1 : length(approx)
    if approx(count) < 0
        approx(count) = approx(count) + 400 ;
    else
        approx(count) = approx(count) ;
    end
end
middle_semt = 200 - (beta + simfi) ;
middle_semt = b.Semt + middle_semt ;
approx(3) = approx(2) ;
approx(2) = middle_semt ;
% sinüs theorem
dist_A  = (a.Distance * sin((alpha + fi)*ro)) / sin(alpha*ro) ;
dist_B  = (b.Distance * sin((beta + simfi)*ro)) / sin(beta*ro) ;
% first basic exam
outY1 = C(1,1) + dist_A*sin(approx(1)*ro) ;
outX1 = C(1,2) + dist_A*cos(approx(1)*ro) ;
outY2 = C(3,1) + dist_B*sin(approx(3)*ro) ;
outX2 = C(3,2) + dist_B*cos(approx(3)*ro) ;
outY = (outY1 + outY2)/2;
outX = (outX1 + outX2)/2;

out = [round(outY,3), round(outX,3)] ;
end