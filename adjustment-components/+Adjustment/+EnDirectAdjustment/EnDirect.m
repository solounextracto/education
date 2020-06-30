classdef EnDirect < handle
    properties
        Data % Veri seti
        A % katsay�lar matrisi
        l % �telenmi� �l��ler
        P % a��rl�k matrisi
        V % d�zeltmeler vekt�r�
        x % bilinmeyenler vekt�r�
        M % duyarl�l�klar
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
            % d�zeltmelerin hesab�
            self.V = self.A * self.x - self.l ;
        end
        function accuracy(self)
            % duyarl�l�k
            self.M.m0 = sqrt(self.V' * self.P * self.V / self.f); %--> birim �l��n�n ortalama hatas�
            self.M.mx = self.M.m0 * sqrt(diag(self.Qxx)); % --> bilinmeyenlerin ortalama hatas�
            self.M.mli = self.M.m0 * sqrt(diag(self.P^-1)); % --> �l��lerin ortalama hatas�
            QLL = self.A * self.Qxx * self.A' ; % dengeli �l��lerin kovaryans matrisi
            self.M.Li = self.M.m0 * sqrt(diag(QLL)); % dengeli �l��lerin ortalama hatalar�
            self.Qvv = self.P^-1 - QLL ; % --> d�zeltmelerin kovaryans matrisi
            % Qvv matrisi kaba hatal� ya da uyu�umsuz �l��lerin ara�t�r�lmas�nda kullan�l�r.
            self.M.mvi = self.M.m0 * sqrt(diag(self.Qvv)); % --> d�zeltmelerin ortalama hatas�
        end
        
        function hypothesisTest(self, s0, alpha)
            % s0 � biz se�eriz. se�ti�imiz de�ere g�re hipotez testinin sonucu de�i�ebilir.
            if s0 > self.M.m0
                T = (s0^2) / (self.M.m0^2);  % T --> Test b�y�kl���
            else
                T = (self.M.m0^2) / (s0^2) ;
            end
            % f1 -> pay�n serbestlik derecesi,  f2 -> paydan�n serbestlik derecesi.
            if T < finv(1-((alpha/100) / 2 ), self.f, self.f) % -- > f1 ve f2 , ayn� al�nabilir .
                disp([num2str(alpha),'% istatistik g�venle Dengeleme modeli GE�ERL�...']);
            else
                disp([num2str(alpha),'% istatistik g�venle Dengeleme modeli GE�ERS�Z...']);
            end
        end
        
        function t_Test(self, alpha)
            self.s0i = sqrt((1 / (self.f-1)) * ((self.V' * self.V) - (((self.V).^2) ./ (diag(self.Qvv))))); % her bir �l�� i�in si s0i de�eri
            self.ti = abs(self.V) ./ (self.s0i .* sqrt(diag(self.Qvv))); % test b�y�kl���
            self.re_t_Test(alpha)
        end
        
        function checkAdjust(self)
            if self.f == 0
                disp(['f : ',num2str(self.f),' = 0 oldu�undan, Tek anlaml� cebrik ��z�m yap�lmal�'])
                return
            elseif self.f < 0
                disp(['f : ',num2str(self.f),' < 0 oldu�undan, Varsay�mlara dayal� ��z�m yap�lmal�'])
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
                fprintf('%.5f �l��s� uyu�umsuzdur \n', self.Data(idx))
                fprintf('T=%.3f > t=%.3f , Hs hipotezi ge�erlidir.\n', max(self.ti), tinv(1-alph, self.f - 1))
                % �l�� uyu�umsuzdur. Bu �l�� ��kar�larak dengeleme yeniden
                % yap�l�p ayn� i�lemler uyu�umsuz �l�� kalmayana kadar
                % devam eder.
                self.Data(idx) = [] ;
                self.buildAdjust() ;
                self.t_Test(alpha)
%                 clear import
            else
                disp('�l��ler uyu�umsuz de�ildir')
                fprintf('T=%.3f < t=%.3f , Ho hipotezi ge�erlidir.\n', max(self.ti), tinv(1-alph, self.f - 1))
            end
        end
    end
end
