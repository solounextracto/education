classdef adjustmentFunctions < handle
    properties
        data
    end
    properties
        A
        l
        x
    end
    
    methods
        function self = adjustmentFunctions(data)
            self.data = data ;
        end
        
        function init(self)
%             self.checkCondition() ;
            self.createl();
            self.functionalModel();
        end
        
        function direct(self)
            self.A = [ones(length(self.data(:, 1)), 1), self.data(:, 1)] ;
            self.init() ;
            fprintf('yi = %.3f + %.3fxi\n', self.x(1), self.x(2)) ;
        end
        
        function curve(self)
            self.A = [ones(length(self.data(:, 1)), 1), self.data(:, 1), self.data(:, 1).^2] ;
            self.init() ;
            fprintf('yi = %.3f + %.3fxi + %.3fxi^2\n', self.x(1), self.x(2), self.x(3)) ;
        end
        
        function curvefitting(self)
            self.A = [ones(length(self.data(:, 1)), 1), self.data(:, 1)] ;
            self.init() ;
            fprintf('y = %.2fx^%.2f\n', exp(self.x(1)), self.x(2)) ;
        end
        
        function surface(self)
            % ...
        end
        
        function createl(self)
            self.l = self.data(:, 2) ;
        end
        
        function functionalModel(self)
            N = self.A'*self.A ;
            n = self.A'*self.l ;
            Qxx = N^-1 ;
            self.x = Qxx*n ;
        end
        
        function checkCondition(self)
            if isempty(self.l)
                condition = cond(self.A) ;
                if condition > 20
                    xmean = mean(self.data(:, 1)) ;
                    transit = xmean - self.A(:, 1) ;
                    norm = transit ./ sqrt(sum(transit.^2)) ;
                    self.A = [ones(length(self.data(:, 1)),1), norm] ;
                end
            end
        end
    end
end