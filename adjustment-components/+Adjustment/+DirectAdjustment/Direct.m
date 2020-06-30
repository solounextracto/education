classdef Direct < handle
    properties
        Data % veriler
        Qll % ters aðýrlýk matrisi
        Pll % aðýrlýk matrisi
        V % düzeltmeler vektörü
        M % duyarlýlýk -> struct
    end
    properties (Hidden = true)
        Qvv % dengeli ölçülerin ters aðýrlýk matrisi
    end
    properties (Dependent, Hidden = true)
        f % serbestlik derecesi
    end
    
    methods
        function plot(self)
            % ölçülerin ve ortalamasýnýn grafiði
            len = 1 : length(self.Data) ;
            plot(len ,self.Data,'o-r') ;
            hold on
            xL = get(gca,'XLim') ;
            line(xL,[mean(self.Data) mean(self.Data)],'Color','r','lineStyle','--') ;
            ax = gca;
            ax.XLabel.String = 'Ölçü sayýsý' ;
            ax.XLabel.FontSize = 20 ;
            ax.YLabel.String = 'Ölçüler' ;
            ax.YLabel.FontSize = 20 ;
            ytickformat('%g')
            ax.Title.String = ['Büyüklüðün ', num2str(length(self.Data)), ...
                ' kez ölçülmesi ile elde edilen ölçüler'] ;
            ax.Title.FontSize = 12;
            legend(ax,{'Ölçüler','Ortalama'}, 'Location', 'northwest', 'FontSize', 12)
            hold off
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
            s0i = sqrt((1 / (self.f-1)) * ((self.V' * self.V) - (((self.V).^2) ./ (diag(self.Qvv))))); % her bir ölçü için si s0i deðeri
            ti = abs(self.V) ./ (s0i .* sqrt(diag(self.Qvv))); % test büyüklüðü
            idx = find(max(ti)) ;
            alph = 1-sqrt(1-((alpha/100)/2));
            if max(ti) >= tinv(1-alph, self.f - 1) % alph = ((alpha/100) / 2)
                import Adjustment.DirectAdjustment.EqualWeight
                fprintf('%.5f ölçüsü uyuþumsuzdur \n', self.Data(idx))
                fprintf('T=%.3f > t=%.3f , Hs hipotezi geçerlidir.\n', max(ti), tinv(1-alph, self.f - 1))
                % ölçü uyuþumsuzdur. Bu ölçü çýkarýlarak dengeleme yeniden
                % yapýlýp ayný iþlemler uyuþumsuz ölçü kalmayana kadar
                % devam eder.
                self.Data(idx) = [] ;
                self.buildAdjust() ;
                self.t_Test(alpha)
%                 clear import
            else
                disp('ölçüler uyuþumsuz deðildir')
                fprintf('T=%.3f < t=%.3f , Ho hipotezi geçerlidir.\n', max(ti), tinv(1-alph, self.f - 1))
            end
        end
        
        function DegreeOfFreedom = get.f(self)
            % serbestlik derecesi
            DegreeOfFreedom = length(self.Data) - 1 ;
        end
    end
end