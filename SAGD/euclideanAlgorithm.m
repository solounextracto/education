%{
a(0) = q(1)*b(0) + r(1) , b(0) = a(1), r(1) = b(1)
a(1) = q(2)*b(1) + r(2) , b(1) = a(2), r(2) = b(2)
a(2) = q(3)*b(2) + r(3) , ...

a(n-1) = q(n)*b(n-1) + r(n) ,
a(n) = q(n+1)*b(n) + 0
r(n), (a , b) - GCD
%}
function [gcd] = euclideanAlgorithm(a, b)
qn = [a, floor(a/b), b, mod(a, b)] ;
qo = qn ; qo(4) = min([a, b]) ;
while qn(4) ~= 0
    qo = [qn(1), qn(2), qn(3), qn(4)] ;
    qn = [qo(3), floor(qo(3)/qo(4)), qo(4), mod(qo(3), qo(4))] ;
end
gcd = qo(4) ;
end