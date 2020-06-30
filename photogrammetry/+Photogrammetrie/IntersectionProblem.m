classdef IntersectionProblem < Photogrammetrie.Im2Terrain
    properties (Hidden = true)
        Left
        Right
        meanTerrain
        P1
        P2
        partials = zeros(2,14);
        File
    end
    properties (Constant, Hidden = true)
        dp = ones(14,1) * 1.0e-08;
    end
    methods
        function self = IntersectionProblem(varargin)
            if ~mod(nargin,2)
                len = length(varargin);
            else
                len = length(varargin) - 1;
            end
            if ~isempty(varargin)
                for input = 1:2:len
                    idx = regexp([' ' varargin{ input }],'(?<=\s+)\S','start')-1;
                    varargin{ input }( idx ) = upper(varargin{ input }( idx ));
                    self.(varargin{ input }) = varargin{ input+1 };
                end
            else
                import Photogrammetrie.UIFile
                self.File = UIFile ;
                waitfor(gcf) ;
            end
        end
        function selectPoint(self, varargin)
            if nargin > 1
                self.Pixel.Left = varargin{1};
                self.Pixel.Right = varargin{2};
            end
            if nargin > 3
                self.imageSize.Left = varargin{3};
                self.imageSize.Right = varargin{4};
            else
                if ischar(self.Left) && ischar(self.Right)
                    self.checkImage()
                else
                    self.imageSize.Left = size(self.Left) ;
                    self.imageSize.Right = size(self.Right) ;
                end
                if isempty(self.Pixel)
                    self.Left = self.File.Left.Image ;
                    self.Right = self.File.Right.Image ;
                    self.Exterior = self.File.DYE ;
                    self.Interior = self.File.IYE ;
                    self.Pix = self.File.Pixel ;
                    if ~isempty(self.Left) && ~isempty(self.Right)
                        [self.Pixel.Left, self.Pixel.Right] = cpselect(self.Left, self.Right, 'Wait', true);
                    else
                        error('resim yüklenmedi...')
                    end
                end
            end
            self.transformImage()
        end
        
        function buildApprox(self, z)
            if ~isempty(self.P1) && ~isempty(self.P2)
                self.P1 = [];
                self.P2 = [];
            end
            self.buildMeanCoordinate(z)
            self.P1 = self.buildSubApprox('Left');
            self.P2 = self.buildSubApprox('Right');
        end
        
        function buildCoordinate(self, z)
            self.buildApprox(z) ;
            if ~isempty(self.Terrain)
                self.Terrain = [];
            end
            for  len = 1 : length(self.Image.Right)
                p1 = self.P1(:, len);
                p2 = self.P2(:, len);
                terrain = self.createIteration(p1, p2);
                self.Terrain(len, :) = terrain;
            end
        end  
    end
    
    methods (Access = private)
        function checkImage(self)
            opts = struct('WindowStyle','modal',... 
                          'Interpreter','tex');
            f = warndlg('\color{red} Lütfen bekleyiniz...',...
                         'Waiting Process', opts);
            self.checkSubImage('Left')
            self.checkSubImage('Right')
            close(f)
        end

        function checkSubImage(self,input)
            if ischar(self.(input))
                self.(input) = imread(self.(input));
                self.imageSize.(input) = size(self.(input));
            end
        end
        
        function out = buildSubApprox(self,input)
            degree = 180 / pi;
            if ischar(input)
                if strcmpi(input,'Left')
                    idx = 1;
                else
                    idx = 2;
                end
                self.Exterior(idx, end-2:end) = self.Exterior(idx, end-2:end) / degree;
                p = [0, 0, self.Interior(1), self.Interior(2), self.Interior(3),...
                    self.Exterior(idx, end-2:end), self.Exterior(idx, 2:4),...
                    self.meanTerrain(1), self.meanTerrain(2), self.meanTerrain(3)]';
                p = repmat(p,1,length(self.Image.(input)));
                p(1:2,:) = (self.Image.(input))';
            end
            out = p ;
        end
        
        function buildMeanCoordinate(self, z)
            X = (self.Exterior(1, 2) + self.Exterior(2, 2)) / 2;
            Y = (self.Exterior(1, 3) + self.Exterior(2, 3)) / 2;
            Z = z;
            self.meanTerrain = [X, Y, Z];
        end
        
        function terrain = createIteration(self, p1, p2)
            X = self.meanTerrain(1);
            Y = self.meanTerrain(2);
            Z = self.meanTerrain(3);
            iter = 0;
            while true
                B = zeros(4,3);
                f = zeros( 4,1);
                F0 = col( p1 );
                self.createPartials(p1, F0)
                B(1:2,:) = self.partials(:,12:14);
                f(1:2) = -F0;
                % ---
                F0 = col( p2 );
                self.createPartials(p2, F0);
                B(3:4,:) = self.partials(:,12:14);
                f(3:4) = -F0;
                %---
                del =(B'*B)^-1*B'*f;
                X = X + del(1);
                Y = Y + del(2);
                Z = Z + del(3);
                p1(12:14)=[X; Y; Z];
                p2(12:14)=[X; Y; Z];
                if 0.0001 > abs(del); break; end
                if  iter == 20; break; end
                iter = iter + 1;
            end
            terrain = [X, Y, Z];
        end
        function createPartials(self, p, F0)
            for i = 1: 14
            pp = p;
            pp(i) = pp(i) + self.dp(i);
            F1 = col(pp);
            self.partials(:, i) = ( F1-F0 )*(1/ self.dp(i));
            end
        end
    end
end

function result=col(p)
x=p(1);
y=p(2);
x0=p(3);
y0=p(4);
f=p(5);
om=p(6);
ph=p(7);
kp=p(8);
XL=p(9);
YL=p(10);
ZL=p(11);
X=p(12);
Y=p(13);
Z=p(14);
m1=[1 0 0;0 cos(om) sin(om);0 -sin(om) cos(om)];
m2=[cos(ph) 0 -sin(ph);0 1 0;sin(ph) 0 cos(ph)];
m3=[cos(kp) sin(kp) 0;-sin(kp) cos(kp) 0;0 0 1];
M=m3*m2*m1;
UVW=M*[X-XL;Y-YL;Z-ZL];
U=UVW(1);
V=UVW(2);
W=UVW(3);
Fx=x-x0+f*(U/W);
Fy=y-y0+f*(V/W);
result=[Fx;Fy];
end