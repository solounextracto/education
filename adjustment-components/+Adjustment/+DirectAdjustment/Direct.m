classdef Direct < handle
    properties
        Data % veriler
        Qll % ters a��rl�k matrisi
        Pll % a��rl�k matrisi
        V % d�zeltmeler vekt�r�
        M % duyarl�l�k -> struct
    end
    properties (Hidden = true)
        Qvv % dengeli �l��lerin ters a��rl�k matrisi
    end
    properties (Dependent, Hidden = true)
        f % serbestlik derecesi
    end
    
    methods
        function plot(self)
            % �l��lerin ve ortalamas�n�n grafi�i
            len = 1 : length(self.Data) ;
            plot(len ,self.Data,'o-r') ;
            hold on
            xL = get(gca,'XLim') ;
            line(xL,[mean(self.Data) mean(self.Data)],'Color','r','lineStyle','--') ;
            ax = gca;
            ax.XLabel.String = '�l�� say�s�' ;
            ax.XLabel.FontSize = 20 ;
            ax.YLabel.String = '�l��ler' ;
            ax.YLabel.FontSize = 20 ;
            ytickformat('%g')
            ax.Title.String = ['B�y�kl���n ', num2str(length(self.Data)), ...
                ' kez �l��lmesi ile elde edilen �l��ler'] ;
            ax.Title.FontSize = 12;
            legend(ax,{'�l��ler','Ortalama'}, 'Location', 'northwest', 'FontSize', 12)
            hold off
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
            s0i = sqrt((1 / (self.f-1)) * ((self.V' * self.V) - (((self.V).^2) ./ (diag(self.Qvv))))); % her bir �l�� i�in si s0i de�eri
            ti = abs(self.V) ./ (s0i .* sqrt(diag(self.Qvv))); % test b�y�kl���
            idx = find(max(ti)) ;
            alph = 1-sqrt(1-((alpha/100)/2));
            if max(ti) >= tinv(1-alph, self.f - 1) % alph = ((alpha/100) / 2)
                import Adjustment.DirectAdjustment.EqualWeight
                fprintf('%.5f �l��s� uyu�umsuzdur \n', self.Data(idx))
                fprintf('T=%.3f > t=%.3f , Hs hipotezi ge�erlidir.\n', max(ti), tinv(1-alph, self.f - 1))
                % �l�� uyu�umsuzdur. Bu �l�� ��kar�larak dengeleme yeniden
                % yap�l�p ayn� i�lemler uyu�umsuz �l�� kalmayana kadar
                % devam eder.
                self.Data(idx) = [] ;
                self.buildAdjust() ;
                self.t_Test(alpha)
%                 clear import
            else
                disp('�l��ler uyu�umsuz de�ildir')
                fprintf('T=%.3f < t=%.3f , Ho hipotezi ge�erlidir.\n', max(ti), tinv(1-alph, self.f - 1))
            end
        end
        
        function DegreeOfFreedom = get.f(self)
            % serbestlik derecesi
            DegreeOfFreedom = length(self.Data) - 1 ;
        end
    end
end