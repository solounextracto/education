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
        ChiSquare
    end
    methods
        function self = NDAT(data, type)
            self.data = data ;
            self.type = type ;
        end
        
        function init(self)
            self.typecheck() ;
            self.classNumber() ;
            self.classWidth() ;
            self.degreesofFreedom() ;
            self.createMean() ;
            self.createSd() ;
        end
        
        function chisquare(self, degrees)
            self.init() ;
            chi = chiSquare(self.data, self.k, self.d, self.mn, self.sd, self.check) ;
            self.ChiSquare = chi ;
            self.test(chi.chivalue, degrees) ;
        end
        
        function classNumber(self)
            self.k = ceil(sqrt(numel(self.data)) + 1) ;
        end
        
        function classWidth(self)
            self.d = round(((max(self.data) - min(self.data)) / self.k)*(self.check(1)), 1) ;
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
                self.check = [1000, 3] ;
            end
        end
        
        function degreesofFreedom(self)
            if isempty(self.mn) && isempty(self.sd)
                self.f = self.k - 3 ;
            else
                self.f = self.k - 1 ;
            end
        end
        
        function test(self, testvalue, degrees)
            if nargin < 3
                degrees = 5 ;
            end
            table = chi2inv(1 - degrees/100, self.f) ;
            if testvalue < table
                fprintf('ChiSquare: %.2f < Table: %.2f , The data examined are normal distribution\n', testvalue, table) ; 
            else
                fprintf('ChiSquare: %.2f > Table: %.2f , The data examined are not normal distribution\n', testvalue, table) ; 
            end
        end
    end
end