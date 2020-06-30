%   analytical test methods for normal distribution
%   mean - 
%   sd - standart deviation
classdef NDAT < handle
    properties
        data    % measured data
        mn  % mean
        sd  % standart deviation
    end
    properties
%         classnumber
%         classwidth
        f   % degrees of freedom
        k   % class number
        d   % class width
        type    % degrees or edge measured.
        check
    end
    methods
        function self = NDAT(data, type)
            self.data = data ;
            self.type = type ;
        end
        
        function init(self)
            self.typecheck() ;
            self.createMean() ;
            self.createSd() ;
            self.classNumber() ;
            self.classWidth() ;
            self.degreesofFreedom() ;
        end
        
        function classNumber(self)
            self.k = ceil(sqrt(numel(self.data)) + 1) ;
        end
        
        function classWidth(self)
            self.d = round(((max(self.data) - min(self.data)) / self.k)*(self.check(1))) ;
        end
        
        function createMean(self)
            self.mn = round(mean(self.data), self.check(2)) ;
        end
        
        function createSd(self)
            self.sd = round(std(self.data)*self.check(1), 2) ;
        end
        
        function typecheck(self)
            if strcmpi(self.type, 'degrees')
                self.check = [10000, 5] ;
            elseif strcmpi(self.type, 'edge')
                self.check = [100, 3] ;
            end
        end
        
        function degreesofFreedom(self)
            if isempty(self.mn) && isempty(self.sd)
                self.f = self.k - 3 ;
            else
                self.f = self.k - 1 ;
            end
        end
    end
end