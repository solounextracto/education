classdef GPS < Adjustment.EnDirectAdjustment.EnDirect
    properties
        X
        H
    end
    properties (Hidden = true)
        x0
        dH
    end
    methods
        function self = GPS(varargin)
            self = self@Adjustment.EnDirectAdjustment.EnDirect(varargin) ;
        end
        
        function definiteValue(self)
            % bilinmeyenlerin kesin deðeri
            if ~isempty(self.x0)
                X0 = self.x0 ;
                X0 = X0(:);
                self.X = X0 + (self.x / 1000) ;
            end
        end
        
        function adjustmeasure(self)
            % dengeli ölçüler
            if ~isempty(self.dH)
                dHi = (self.dH)' ;
                dHi = dHi(:) ; 
                self.H = dHi + (self.V / 1000)  ;
            end
        end
        
        function degreeOfFreedom(self)
            n = size(self.A, 1) ;
            u = size(self.A, 2) ;
            self.f = n - u ;
        end
        
        function t_Test(self, alpha)
            for i = 1:length(self.V)
            e = zeros(length(self.V), 1);
            e(i) = 1;
            self.s0i(i, 1) = sqrt((1/ (self.f-1))*((self.V'*self.P*self.V)-(((e'*self.P*self.V)^2)/(e'*self.P*self.Qvv*self.P*e))));
            self.ti(i, 1) = abs(e'*self.P*self.V) / (self.s0i(i, 1)*sqrt(e'*self.P*self.Qvv*self.P*e));
            end
            self.re_t_Test(alpha) 
        end
    end
end