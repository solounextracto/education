classdef EqualWeight < Adjustment.DirectAdjustment.Direct
    properties (Hidden = true)
        l % ötelemeler vektörü
        dx % dengeleme bilinmeyenleri
        x % bilinmeyenlerin kesin deðeri
    end
    properties (Dependent, Hidden = true)
        e % birim vektör
        x0 % yaklaþýk deðer
    end

    methods
        function self = EqualWeight(Data)
            % constructor
            self.Data = Data ;
        end
        
        function buildAdjust(self)
            % dengelemenin kurulmasý
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
            % ötelenmiþ ölçüler
            n = self.checkData() ;
            if n < 1e3; n = 1e3 ; end
            self.l = round((self.Data - self.x0)* n ) ;
        end
        
        function adjustmentUnknown(self)
            % dengeleme bilinmeyenleri
            self.dx = ( self.e'*self.l )/( self.e'*self.e );
        end
        
        function definiteValue(self)
            % Bilinmeyenlerin kesin deðeri
            n = self.checkData() ;
            if n < 1e3
                n = 1e3 ; idx = 3;
            else
                idx = 5 ;
            end
            self.x = round((self.x0 + (self.dx)/n), idx); 
        end
        
        function revisions(self)
            % Düzeltmeler
            self.V = round((self.e*self.dx - self.l), 2) ;
        end
        
        function accuracy(self)
            % duyarlýlýk hesaplarý
            self.M.m0 = sqrt(self.V' * self.V / (length(self.Data) - 1)); %--> ölçülerin ortalama hatasý
            self.M.mx = self.M.m0 / sqrt(length(self.Data)); % --> kesin deðerin ortalama hatasý
            self.Qvv = self.Qll - ( ( self.e * self.e' ) / ( self.e' * self.e ) );% --> dengeli ölçülerin ters aðýrlýk matrisi
            self.M.mvi = self.M.m0 * sqrt(diag(self.Qvv)); % --> düzeltmelerin ortalama hatasý
        end
        
        
        function check(self)
            % denetimler
            check1 = round(self.e'*self.V) == 0; % --> denetim 1
            check2 = round(self.V' * self.V) == round(-self.V' * self.l);  % --> denetim 2
            check3 = round(self.V' * self.V) == round(self.l' * self.l - self.l' * self.e* self.dx); % --> denetim 3
            check4 = round(self.V' * self.V) == round( self.l' * self.l - ((self.e' * self.l)^2  / (self.e'*self.e))); % -- denetim 4
            if check1 && check2 && check3 && check4; disp('Denetimler baþarýlý...');end
        end
        
        function resultCheck(self)
            % sonuç denetimi
            n = self.checkData() ;
            if n < 1e3 
                n = 1e3  ;idx = 3 ;
            else
                idx = 5 ;
            end
            left = round(self.Data + ( self.V / n ), idx) ; 
            right = self.x ;
            result = all(left == right) ;
            if result ; disp('Sonuç Denetimi baþarýlý...') ; end
        end
        
        function approxValue = get.x0(self)
            % yaklaþýk deðer
            n = self.checkData() ;
            approxValue = (fix(min(self.Data) * n)) / n ;
        end
        function vector = get.e(self)
            % birim vektör
            vector = ones(length(self.Data),1) ;
        end
    end
    
    methods (Access = private)
        function out = checkData(self)
            % uzunluk, açý ölçüsü seçimi
            str = num2str(self.Data(1)) ;
            expression = '\.' ;
            splitStr = regexp(str,expression,'split') ;
            check = length(splitStr{ 2 }) ;
            if check > 1 && check < 4
                n  = 1e2 ;
            elseif  check > 3 && check < 6
                n = 1e4 ;
            else
                error('Girilen deðerler eþleþmiyor...')
            end
            out = n ;
        end
    end
end