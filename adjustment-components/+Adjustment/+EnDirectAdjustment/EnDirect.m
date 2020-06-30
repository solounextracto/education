classdef EnDirect < handle
    properties
        Data % Veri seti
        A % katsayýlar matrisi
        l % ötelenmiþ ölçüler
        P % aðýrlýk matrisi
        V % düzeltmeler vektörü
        x % bilinmeyenler vektörü
        M % duyarlýlýklar
    end
    properties (Hidden = true)
        Qll
        Qxx
        Qvv
        f
        ti
        s0i
    end

    methods (Abstract)
        definiteValue(self)
        adjustmeasure(self)
        degreeOfFreedom(self)
    end
    
    methods
        function self = EnDirect(varargin)
            varargin = varargin{:} ;
            if ~mod(nargin,2)
                len = length(varargin);
            else
                len = length(varargin) - 1;
            end
            if ~isempty(nargin)
                for input = 1:2:len
                    self.(varargin{ input }) = varargin{ input+1 };
                end
            end
            self.degreeOfFreedom()
            self.checkAdjust()
        end
        
        function stochasticsModel(self)
            if isempty(self.P)
                self.P = self.Qll^-1 ;
            end
        end
        
        function functionalModel(self)
            self.normalEquation()
            self.definiteValue()
            self.adjustments()
            self.adjustmeasure()
        end
        
        function normalEquation(self)
            % normal denklemler (mm)
            N = self.A' * self.P * self.A;
            n = self.A' * self.P * self.l;
            self.Qxx = N^-1;
            self.x = self.Qxx * n ;
        end
        function adjustments(self)
            % düzeltmelerin hesabý
            self.V = self.A * self.x - self.l ;
        end
        function accuracy(self)
            % duyarlýlýk
            self.M.m0 = sqrt(self.V' * self.P * self.V / self.f); %--> birim ölçünün ortalama hatasý
            self.M.mx = self.M.m0 * sqrt(diag(self.Qxx)); % --> bilinmeyenlerin ortalama hatasý
            self.M.mli = self.M.m0 * sqrt(diag(self.P^-1)); % --> ölçülerin ortalama hatasý
            QLL = self.A * self.Qxx * self.A' ; % dengeli ölçülerin kovaryans matrisi
            self.M.Li = self.M.m0 * sqrt(diag(QLL)); % dengeli ölçülerin ortalama hatalarý
            self.Qvv = self.P^-1 - QLL ; % --> düzeltmelerin kovaryans matrisi
            % Qvv matrisi kaba hatalý ya da uyuþumsuz ölçülerin araþtýrýlmasýnda kullanýlýr.
            self.M.mvi = self.M.m0 * sqrt(diag(self.Qvv)); % --> düzeltmelerin ortalama hatasý
        end
        
        function hypothesisTest(self, s0, alpha)
            % s0 ý biz seçeriz. seçtiðimiz deðere göre hipotez testinin sonucu deðiþebilir.
            if s0 > self.M.m0
                T = (s0^2) / (self.M.m0^2);  % T --> Test büyüklüðü
            else
                T = (self.M.m0^2) / (s0^2) ;
            end
            % f1 -> payýn serbestlik derecesi,  f2 -> paydanýn serbestlik derecesi.
            if T < finv(1-((alpha/100) / 2 ), self.f, self.f) % -- > f1 ve f2 , ayný alýnabilir .
                disp([num2str(alpha),'% istatistik güvenle Dengeleme modeli GEÇERLÝ...']);
            else
                disp([num2str(alpha),'% istatistik güvenle Dengeleme modeli GEÇERSÝZ...']);
            end
        end
        
        function t_Test(self, alpha)
            self.s0i = sqrt((1 / (self.f-1)) * ((self.V' * self.V) - (((self.V).^2) ./ (diag(self.Qvv))))); % her bir ölçü için si s0i deðeri
            self.ti = abs(self.V) ./ (self.s0i .* sqrt(diag(self.Qvv))); % test büyüklüðü
            self.re_t_Test(alpha)
        end
        
        function checkAdjust(self)
            if self.f == 0
                disp(['f : ',num2str(self.f),' = 0 olduðundan, Tek anlamlý cebrik çözüm yapýlmalý'])
                return
            elseif self.f < 0
                disp(['f : ',num2str(self.f),' < 0 olduðundan, Varsayýmlara dayalý çözüm yapýlmalý'])
                return
            end
        end
    end
    
    methods
        function re_t_Test(self, alpha)
            idx = find(max(self.ti)) ;
            alph = 1-sqrt(1-((alpha/100)/2));
            if max(self.ti) >= tinv(1-alph, self.f - 1) % alph = ((alpha/100) / 2)
                import Adjustment.EnDirectAdjustment.EnDirect
                fprintf('%.5f ölçüsü uyuþumsuzdur \n', self.Data(idx))
                fprintf('T=%.3f > t=%.3f , Hs hipotezi geçerlidir.\n', max(self.ti), tinv(1-alph, self.f - 1))
                % ölçü uyuþumsuzdur. Bu ölçü çýkarýlarak dengeleme yeniden
                % yapýlýp ayný iþlemler uyuþumsuz ölçü kalmayana kadar
                % devam eder.
                self.Data(idx) = [] ;
                self.buildAdjust() ;
                self.t_Test(alpha)
%                 clear import
            else
                disp('ölçüler uyuþumsuz deðildir')
                fprintf('T=%.3f < t=%.3f , Ho hipotezi geçerlidir.\n', max(self.ti), tinv(1-alph, self.f - 1))
            end
        end
    end
end
