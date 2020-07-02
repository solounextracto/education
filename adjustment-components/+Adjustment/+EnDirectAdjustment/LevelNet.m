classdef LevelNet < Adjustment.EnDirectAdjustment.EnDirect
    properties
        X
        H
    end
    properties (Hidden = true)
        x0
        dH
    end
    methods
        function self = LevelNet(varargin)
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
            if ~isempty(self.dH)
                self.H = self.dH + (self.V / 1000)  ;
            end
        end
        
        function degreeOfFreedom(self)
            n = size(self.A, 1) ;
            u = size(self.A, 2) ;
            if strcmpi(self.Type, 'Zorlamalý Dengeleme')
                self.f = n - u ;
            else
                self.f = n - u + 1 ; % 1 - levelNet datum parameters (d)
            end
        end
    end
    
end