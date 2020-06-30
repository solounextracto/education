classdef Weight < Adjustment.EnDirectAdjustment.EnDirect
    properties
        X
        li
    end
    properties (Hidden = true)
        x0
    end
    methods
        function self = Weight(varargin)
            self = self@Adjustment.EnDirectAdjustment.EnDirect(varargin) ;
        end

        function definiteValue(self)
            % bilinmeyenlerin kesin deðeri
            if ~isempty(self.x0)
                self.X = self.x0 + (self.x / 1000) ;
            end
        end
        
        function adjustmeasure(self)
            % dengeli ölçüler
            self.li = self.l + self.V ;
        end
        
        function degreeOfFreedom(self)
            % serbestlik derecesi
            n = size(self.A, 1) ;
            u = size(self.A, 2) ;
            self.f = n - u ;
        end
    end
end