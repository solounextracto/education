%   analytical test methods for normal distribution
%   mean - 
%   sd - standart deviation
classdef NDAT < handle
    properties
        TestName
        OUTPUT
        INPUT
    end
    properties (Hidden = true, Access = private)
        data    % measured data
        mn  % mean
        sd  % standart deviation
        f   % degrees of freedom
        k   % class number
        d   % class width
        type    % degrees or edge measured.
        check
    end
    methods
        function self = NDAT(data)
            self.data = data ;
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
            self.TestName = 'ChiSquare' ;
            self.init() ;
            chi = chiSquare(self.data, self.d, self.mn, self.sd, self.check) ;
            self.OUTPUT = chi ;
            self.d = chi.d ;
            self.test(chi.chivalue, degrees) ;
        end
        
        function mannwald(self, degrees)
            self.TestName = 'Mann-Wald' ;
            self.init() ;
            mw = mannWald(self.data, self.k, self.mn, self.sd, self.check) ;
            self.OUTPUT = mw ;
            self.test(mw.mannwald, degrees) ;
        end
        
        function kolmogorov_smirnov(self, degrees)
            self.TestName = 'Kolmogorov-Smirnov' ;
            self.init() ;
            kolmogorov_smirnov = Kolmogorov_Smirnov(self.data, self.d, self.mn, self.sd, self.check) ;
            self.OUTPUT = kolmogorov_smirnov ;
            self.d = kolmogorov_smirnov.d ;
            self.test(kolmogorov_smirnov.ksvalue, degrees) ;
        end
        
        function kurtosis(self, degrees)
            self.TestName = 'Crooked Kurtosis' ;
            self.init() ;
            crookedcurtosis = kurtosisCrooked(self.data, self.check, self.mn, self.sd, degrees) ;
            self.OUTPUT = crookedcurtosis ;
            self.f = 2 ;
            self.test(crookedcurtosis.Kurtosis, degrees) ;
        end
        
    end
    
    % Private methods
    methods (Access = private)
        function classNumber(self)
            if strcmp(self.TestName, 'ChiSquare')
                self.k = ceil(sqrt(numel(self.data)) + 1) ;
            elseif strcmp(self.TestName, 'Kolmogorov-Smirnov') || ...
                    strcmp(self.TestName, 'Mann-Wald')
                self.k = ceil(sqrt(numel(self.data)) + 3) ;
            elseif strcmp(self.TestName, 'Crooked Kurtosis')
                self.k = 0 ;
            end
            self.INPUT.k = self.k;
        end
        
        function classWidth(self)
            self.d = round(((max(self.data) - min(self.data)) / self.k)*(self.check(1)), 1) ;
            self.INPUT.d = self.d;
        end
        
        function createMean(self)
            self.mn = round(mean(self.data), self.check(2)) ;
            self.INPUT.mean = self.mn ;
        end
        
        function createSd(self)
            self.sd = round(std(self.data)*self.check(1), 2) ;
            self.INPUT.StandartDeviation = self.sd;
        end
        
        function typecheck(self)
            str =  regexp(num2str(self.data(1)), '\.', 'split') ;
            if numel(str{2}) >= 2 && numel(str{2}) <= 3
                self.type = 'edge' ;
            elseif numel(str{2}) >= 4 && numel(str{2}) <= 5
                self.type = 'degrees' ;
            end
            
            if strcmpi(self.type, 'degrees')
                self.check = [1e4, 5] ;
            elseif strcmpi(self.type, 'edge')
                self.check = [1e3, 3] ;
            end
        end
        
        function degreesofFreedom(self)
            if isempty(self.mn) && isempty(self.sd)
                self.f = self.k - 3 ;
            else
                self.f = self.k - 1 ;
            end
            self.INPUT.f  = self.f;
        end
           
        function test(self, testvalue, degrees)
            if strcmp(self.TestName, 'ChiSquare') || ...
                    strcmp(self.TestName, 'Mann-Wald') || ...
                    strcmp(self.TestName, 'Crooked Kurtosis')
                table = chi2inv(1 - degrees/100, self.f) ;
            elseif strcmp(self.TestName, 'Kolmogorov-Smirnov')
                if degrees == 5 
                    c = 1.36 ;
                else
                    c = input('Enter the c value : ') ; %%---- update.
                end
                table = c / sqrt(numel(self.data)) ;
            end
            if testvalue < table
                fprintf('Hypotesis, %s: %.4f < Table: %.2f , The data examined are normal distribution\n', ...
                    self.TestName, testvalue, table) ; 
            else
                fprintf('Hypotesis, %s: %.4f > Table: %.2f , The data examined are not normal distribution\n', ...
                    self.TestName, testvalue, table) ; 
            end
        end
    end
end