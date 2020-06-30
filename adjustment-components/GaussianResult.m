classdef GaussianResult < handle
    properties
        A
        l
        p
        reduction
        gaussMatrix
        Qxx
        Approx
    end
    methods
        function self = GausianResult(varargin)
            for count = 1 : 2 : nargin 
                self.(varargin{count}) = varargin{count + 1} ;
            end
            self.init()
        end
        function init(self)
            unk =  size(self.A) ;
            if isempty(self.p)
                self.p = ones(unk(1), 1) ;
            end
            s = sum([self.A , self.l],2) ;
            Gauss = [self.p, self.A, self.l, s] ;
            for set = 2 : size(Gauss, 2)
                for get = 2 : size(Gauss, 2)
                    self.gaussMatrix(set-1,get-1) =  sum(Gauss(:,1) .* Gauss(:,set) .*Gauss(:,get));
                end
            end
            self.gaussMatrix(end,:) = [] ;
            for i = 2 : size(self.gaussMatrix, 1)
                self.gaussMatrix(i , 1:i - 1) = nan ;
            end
            self.approxAdjust()
            self.approxValue()
        end
        
        function approxAdjust(self)
            first = [self.gaussMatrix(1,:)...
                ;self.gaussMatrix(1, :) ./ -self.gaussMatrix(1,1)] ;
            
            second = (first(1,2).*first(1,2:end))./first(1,1);
            second = self.gaussMatrix(2,2:end) - second ;
            second = [self.gaussMatrix(2,2:end) ;second; second ./ -second(1,1)];
            
            thirdleft = self.gaussMatrix(3,3) - (first(1,end-1)^2 ./ first(1,1)) - (second(2,end-1)^2./second(2,1));
            thirdright = self.gaussMatrix(3,4) - prod((first(1,end-1:end))) ./ first(1,1) - (prod(second(2,end-1:end))) ./second(2,1) ;
            third = [self.gaussMatrix(3,3:end); [thirdleft,thirdright] ] ;
            
            gaussResult = nan(7,4);
            
            gaussResult(1:2,:) = first;
            gaussResult(3:5,2:end) = second;
            gaussResult(6:end,3:end) = third ;
            self.reduction = gaussResult ;
        end
        
        function approxValue(self)
            dx = self.reduction(5,3);
            dy = self.reduction(2,2)*dx + self.reduction(2,3);
            self.Approx = [dx, dy];
            
            
            qyy = 1 / self.reduction(4,2);
            qxy = self.reduction(2,2)*qyy;
            qxx = 1 / self.reduction(1,1) + self.reduction(2,2)*qxy;
            self.Qxx = [qxx qxy;qxy qyy];
        end
        
    end
end