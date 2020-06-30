function [A_matrix] = resultSchreiber(C, C2, yak, kesin)
dg = C{3}.*(pi/200);
koor = {kesin{:}; yak{:}};
ff = koor(:, 1);
x = [koor{:, 3}];
y = [koor{:, 2}];
tsemt = [];
Smesafe = [];
tort = [];
Lik = zeros(length(C{1}),1) ;
aik = [] ;
bik = [];
A_indir = zeros(length(C{2}), (length(yak{1})*2) +1);
chc = 1 ;
chcr = 1 ;
C{1}{end + 1} = {} ;
Vsum = [] ;
Vstar = [] ;
for dn = 1 : length(C{1})
    if ~isempty(C{1}{dn})
        for bn = chc : length(C{2})
                [C{1}{dn},C{2}{bn}];
                idxdn = find(strcmp([ff{:}], C{1}{dn}));
                idxbn = find(strcmp([ff{:}], C{2}{bn}));
                koordur = [y(idxdn) x(idxdn)];
                koorbak = [y(idxbn) x(idxbn)];
                dY = koorbak(1) - koordur(1);
                dX = koorbak(2) - koordur(2);
                if  dY > 0 && dX > 0
                    t = abs(atan(dY/dX)) ;
                elseif dY > 0 &&  dX < 0
                    t = pi - abs(atan(dY/dX)) ;
                elseif dY < 0 && dX < 0
                    t = pi + abs(atan(dY/dX)) ;
                elseif dY < 0 && dX > 0
                    t = (2*pi) - abs(atan(dY/dX)) ;
                end
                tsemt(end + 1) = t ;
                Smesafe(end + 1) = sqrt(dY^2 + dX^2);
                aik(end+1) = ((sin(t)) / sqrt(dY^2 + dX^2))*(((200/pi)*10000)/100);
                bik(end+1) = -((cos(t)) / sqrt(dY^2 + dX^2))*(((200/pi)*10000)/100) ;
                tfark = (tsemt.*(200/pi))' - C{3}(1:bn) ;
                oldchc = chc ; 
                findm = find(strcmp([yak{1}], C{1}{dn})) ;
                findn = find(strcmp([yak{1}], C{2}{bn})) ;
                if isempty(findm)
                    findm = findn ;
                    params = [-aik(bn), -bik(bn)];
                elseif isempty(findn)
                    findn = findm ;
                    params = [aik(bn), bik(bn)];
                else
                    params = [aik(bn), bik(bn), -aik(bn), -bik(bn)];
                end
                kxx = [(2*findm - 1), (2*findn)] ;
                A_indir(bn ,kxx(1):kxx(2)) = params;
                
            if isempty(C{1}{bn}) && ~isempty(C{1}{bn+1})
                chc = bn + 1 ;
                chcr = chcr + 1;
                break;
            end
        end
        if bn == length(tfark)
            chc = bn + 1 ;
        end
        tort(end + 1) = sum(tfark(dn:bn)) / (chc - oldchc);
        Lik(dn:bn) = (tfark(dn:bn) - tort(end)) .*10000;
        A_indir(dn:bn, end) = Lik(dn:bn);
        A_indirgeme = A_indir(dn:bn, :) ;
        A_indirgeme = sum(A_indirgeme);
        Vstar = [Vstar, dn];
        Vsum = [Vsum; A_indirgeme];
        A_indir(end + 1, :) = zeros(1,size(A_indir, 2)) ;
    end
end
Vcount  = size(Vsum,1) ;
for cnt = 1 : size(Vsum,1)
    if Vstar(1) == 1
        Vstar(1) = 0 ;
        continue
    end
    A_indir(Vstar(cnt)+1:end-(size(Vsum,1)+1-cnt), :) = A_indir(Vstar(cnt):end-Vcount, :);
    A_indir(Vstar(cnt), :) = Vsum(cnt-1, :) ;
    Vcount = Vcount - 1 ;
    if cnt ==  size(Vsum, 1)
        A_indir(end, :) = Vsum(end, :) ;
        break
    end
end
l_ik = [] ;
da_ik = [] ;
db_ik = [] ;
dist_A = zeros(length(C2{1}), (length(yak{1})*2) +1);
for  dist = 1 : length(C2{1})
    finddistm = find(strcmp([ff{:}], C2{1}{dist})) ;
    finddistn = find(strcmp([ff{:}], C2{2}{dist})) ;
    dnokta = [y(idxdn) x(idxdn)] ;
    bnokta = [y(idxbn) x(idxbn)] ;
    distX = bnokta(1) - dnokta(1) ;
    distY = bnokta(2) - dnokta(2) ;
    s0ik = sqrt(distY^2 + distX^2) ;
    Ss = C2{3}(dist) ;
    l_ik(end + 1) = (s0ik - Ss) * 1000 ;
    da_ik(end + 1) = -(distY / s0ik) ;
    db_ik(end + 1) = -(distX / (s0ik)) ;
    isdistm = ismember(C2{1}{dist},yak{1}) ;
    isdistn = ismember(C2{1}{dist},yak{1}) ;
    finddistm = find(strcmp([yak{1}], C2{1}{dist})) ;
    finddistn = find(strcmp([yak{1}], C2{2}{dist})) ;
    if isempty(finddistm)
        finddistm = finddistn ;
        distparams = [-da_ik(dist), -db_ik(dist)];
    elseif isempty(finddistn)
        finddistn = finddistm ;
        distparams = [da_ik(dist), db_ik(dist)];
    else
        distparams = [da_ik(dist), db_ik(dist), -da_ik(dist), -db_ik(dist)];
    end
        kxy = [(2*finddistm - 1), (2*finddistn)] ;
        dist_A(dist ,kxy(1):kxy(2)) = distparams ;
        dist_A(dist, end) = l_ik(dist) ;
end

A_matrix = [A_indir; dist_A] ;
A = A_matrix(:, 1 : length(yak{1})*2) ;
l = -A_matrix(:, end) ;
disp('             ------------------------------------------------------------------')
fprintf('\t%.5f    %.5f    %.5f    %.5f    %.1f \n', ...
    [A_matrix(:,1),A_matrix(:,2),A_matrix(:,3),A_matrix(:,4),A_matrix(:,5)]')
disp('             ------------------------------------------------------------------')
end