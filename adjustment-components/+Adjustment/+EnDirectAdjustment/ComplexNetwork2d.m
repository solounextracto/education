classdef ComplexNetwork2d < Adjustment.EnDirectAdjustment.EnDirect
    properties
        Ri % dengeli doðrultu ölçüleri
        Si % dengeli kenar ölçüleri
    end
    properties (Hidden = true)
        Direction
        Edge
        Definite % Kesin Koordinatlar
        Approx % Yaklaþýk Koordinatlar
    end
    methods
        function self = ComplexNetwork2d(varargin)
            self = self@Adjustment.EnDirectAdjustment.EnDirect(varargin) ;
        end
        
        function definiteValue(self)
            % bilinmeyenlerin kesin deðeri
            if ~isempty(self.Approx)
                X0 = [self.Approx{3}, self.Approx{2}]' ;
                X0 = X0(:);
                self.X = X0 + (self.x / 1000) ;
            end
        end
        
        function adjustmeasure(self)
            % dengeli ölçüler
            if ~isempty(self.Definite{3}) && ~isempty(self.Edge{3})
                definite = self.Definite{3} + (self.V(1 : length(self.Definite{3}))./10000) ;
                margin = self.Edge{3} + (self.V(length(self.Definite{3})+1:end)./1000) ;
                self.Ri = definite ;
                self.Si = margin ;
            end
        end
        
        function degreeOfFreedom(self)
            measure = length(self.Direction{2}) ;
            margin = length(self.Edge{1}) ;
            n = measure + margin ;
            approx = length(self.Approx{1}) * 2 ;
            direction = self.Direction{1} ;
            count = 0 ;
            for i = 1 :  length(direction)
                if isempty(direction{i})
                    continue
                end
                count = count + 1 ;
            end
            u = approx + count ;
            self.f = n - u ;
        end
    end
end