classdef EqualWeight < Adjustment.DirectAdjustment.Direct
    properties (Hidden = true)
        l % �telemeler vekt�r�
        dx % dengeleme bilinmeyenleri
        x % bilinmeyenlerin kesin de�eri
    end
    properties (Dependent, Hidden = true)
        e % birim vekt�r
        x0 % yakla��k de�er
    end

    methods
        function self = EqualWeight(Data)
            % constructor
            self.Data = Data ;
        end
        
        function buildAdjust(self)
            % dengelemenin kurulmas�
            self.stochasticModel()
            self.shiftedMeasure()
            self.adjustmentUnknown()
            self.definiteValue()
            self.revisions()
            self.accuracy()
        end
        
        function stochasticModel(self)
            % stokastik model
            self.Qll = eye(length(self.Data)) ;
            self.Pll = self.Qll ;
        end
        
        function shiftedMeasure(self)
            % �telenmi� �l��ler
            n = self.checkData() ;
            if n < 1e3; n = 1e3 ; end
            self.l = round((self.Data - self.x0)* n ) ;
        end
        
        function adjustmentUnknown(self)
            % dengeleme bilinmeyenleri
            self.dx = ( self.e'*self.l )/( self.e'*self.e );
        end
        
        function definiteValue(self)
            % Bilinmeyenlerin kesin de�eri
            n = self.checkData() ;
            if n < 1e3
                n = 1e3 ; idx = 3;
            else
                idx = 5 ;
            end
            self.x = round((self.x0 + (self.dx)/n), idx); 
        end
        
        function revisions(self)
            % D�zeltmeler
            self.V = round((self.e*self.dx - self.l), 2) ;
        end
        
        function accuracy(self)
            % duyarl�l�k hesaplar�
            self.M.m0 = sqrt(self.V' * self.V / (length(self.Data) - 1)); %--> �l��lerin ortalama hatas�
            self.M.mx = self.M.m0 / sqrt(length(self.Data)); % --> kesin de�erin ortalama hatas�
            self.Qvv = self.Qll - ( ( self.e * self.e' ) / ( self.e' * self.e ) );% --> dengeli �l��lerin ters a��rl�k matrisi
            self.M.mvi = self.M.m0 * sqrt(diag(self.Qvv)); % --> d�zeltmelerin ortalama hatas�
        end
        
        
        function check(self)
            % denetimler
            check1 = round(self.e'*self.V) == 0; % --> denetim 1
            check2 = round(self.V' * self.V) == round(-self.V' * self.l);  % --> denetim 2
            check3 = round(self.V' * self.V) == round(self.l' * self.l - self.l' * self.e* self.dx); % --> denetim 3
            check4 = round(self.V' * self.V) == round( self.l' * self.l - ((self.e' * self.l)^2  / (self.e'*self.e))); % -- denetim 4
            if check1 && check2 && check3 && check4; disp('Denetimler ba�ar�l�...');end
        end
        
        function resultCheck(self)
            % sonu� denetimi
            n = self.checkData() ;
            if n < 1e3 
                n = 1e3  ;idx = 3 ;
            else
                idx = 5 ;
            end
            left = round(self.Data + ( self.V / n ), idx) ; 
            right = self.x ;
            result = all(left == right) ;
            if result ; disp('Sonu� Denetimi ba�ar�l�...') ; end
        end
        
        function approxValue = get.x0(self)
            % yakla��k de�er
            n = self.checkData() ;
            approxValue = (fix(min(self.Data) * n)) / n ;
        end
        function vector = get.e(self)
            % birim vekt�r
            vector = ones(length(self.Data),1) ;
        end
    end
    
    methods (Access = private)
        function out = checkData(self)
            % uzunluk, a�� �l��s� se�imi
            str = num2str(self.Data(1)) ;
            expression = '\.' ;
            splitStr = regexp(str,expression,'split') ;
            check = length(splitStr{ 2 }) ;
            if check > 1 && check < 4
                n  = 1e2 ;
            elseif  check > 3 && check < 6
                n = 1e4 ;
            else
                error('Girilen de�erler e�le�miyor...')
            end
            out = n ;
        end
    end
end