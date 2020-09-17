classdef Terr2im
    properties %(Hidden = true)
        improp(1,3) double {mustBeReal, mustBeFinite, mustBeNonnegative} % row, column, pixelsize
        primepoint(1,3) double {mustBeReal, mustBeFinite} % x_0, y_0, c
        projectionpoint(1,3) double {mustBeReal, mustBeFinite, mustBeNonnegative} % X, Y, Z
        rotation(1,3) double {mustBeReal, mustBeFinite} % omega, phi, kappa 
    end
    properties
        M(3,3) double {mustBeReal, mustBeFinite}
    end
    methods
        function self = Terr2im()
            %construct
        end
        function self = set.improp(self, prop)
            self.improp = prop ;
            disp(char(['Row: ', num2str(prop(1))], ...
                ['Column: ' num2str(prop(2))], ...
                ['Pixel Size: ', num2str(prop(3))]))
        end
        function self = set.primepoint(self, pp)
            self.primepoint = pp ;
            disp(char(['x0: ', num2str(pp(1))], ...
                ['y0: ' num2str(pp(2))], ...
                ['c: ', num2str(pp(3))]))
        end
        function self = set.projectionpoint(self, pp)
            self.projectionpoint = pp ;
            disp(char(['X: ', num2str(pp(1))], ...
                ['Y: ' num2str(pp(2))], ...
                ['Z: ', num2str(pp(3))]))
        end
        function self = set.rotation(self, rotate)
            self.rotation = rotate ;
            disp(char(['Omega: ', num2str(rotate(1))], ...
                ['Phi: ' num2str(rotate(2))], ...
                ['Kappa: ', num2str(rotate(3))]))
        end
        function rotate = get.M(self)
            rotate = self.rotateMatrix ;
        end
    end
    
    methods (Access = public)
        function image = imagepoint(self, points)
            image = self.terr2im(points) ;
        end
        function pixel = im2pix(self, points)
            pixel = self.image2pix(points) ;
        end
        function out = plot(~, points, im)
            x = [points.x] ;
            y = [points.y] ;
            if nargin > 1 ; imshow(im) ; end
            hold on
            axis on
            out.plot = scatter(x, y, 'Marker', points(1).Marker, ...
                       'LineWidth', 2, ...
                       'MarkerEdgeColor', 'k') ;
            out.text = text(x, y, cellfun(@num2str,{points(:).nn},'un',0))
            hold off
        end
    end
    
    methods (Access = private)
        function rotationMatrix = rotateMatrix(self)
            om = self.rotation(1) ;% omega
            ph = self.rotation(2) ;% phi
            kp = self.rotation(3) ;% kappa
            
            rotationMatrix = ...
                [cosd(ph)*cosd(kp), cosd(om)*sind(kp)+sind(om)*sind(ph)*cosd(kp), sind(om)*sind(kp)-cosd(om)*sind(ph)*cosd(kp);
                -cosd(ph)*sind(kp), cosd(om)*cosd(kp)-sind(om)*sind(ph)*sind(kp), sind(om)*cosd(kp)+cosd(om)*sind(ph)*sind(kp);
                sind(ph), -sind(om)*cosd(ph), cosd(om)*cosd(ph)] ;
        end
        
        function imagepoints = terr2im(self, points)
            x0 = self.primepoint(1) ;
            y0 = self.primepoint(2) ;
            f  = self.primepoint(3) ;
            Xc = self.projectionpoint(1) ;
            Yc = self.projectionpoint(2) ;
            Zc = self.projectionpoint(3) ;
            X = [points.x] ;
            Y = [points.y] ;
            Z = [points.z] ;
            m = self.M ;
            
            image.nn = [points(:).nn] ;
            image.x = (-f*(((m(1,1)*(X-Xc))+(m(1,2)*(Y-Yc))+(m(1,3)*(Z-Zc)))./ ...
                ((m(3,1)*(X-Xc))+(m(3,2)*(Y-Yc))+(m(3,3)*(Z-Zc))))) + x0 ;
            image.y = (-f*(((m(2,1)*(X-Xc))+(m(2,2)*(Y-Yc))+(m(2,3)*(Z-Zc)))./ ...
                ((m(3,1)*(X-Xc))+(m(3,2)*(Y-Yc))+(m(3,3)*(Z-Zc))))) + y0 ;
            image.z = false(1,length(image.nn)) ;
            
            imagepoints = setPoint(image) ;
        end
        function pixel = image2pix(self, points)
            pixel.nn = [points.nn] ;
            x  = [points.x] ;
            y  = [points.y] ;
            pixel.x = round(( x ./(self.improp(3)/1e3)) + ...
                (self.improp(2) / 2) + self.primepoint(1)) ;
            pixel.y = round((-y ./(self.improp(3)/1e3)) + ...
                (self.improp(1) / 2) + self.primepoint(2)) ;
            pixel.z = -true(1, length([points(:).z])) ;
            pixel = setPoint(pixel) ;
        end
    end
        
    methods (Static)
       function obj = read(file)
           fileID = fopen(file) ;
           count = 0 ;
           while ~feof(fileID)
               count = count + 1 ;
               content = fgetl(fileID) ;
               parseContent = regexp(content, ' ', 'split');
               if count == 1
                   points.(lower(parseContent{1})) = [] ;
                   points.(lower(parseContent{2})) = [] ;
                   points.(lower(parseContent{3})) = [] ;
                   points.(lower(parseContent{4})) = [] ;
                   fields = fieldnames(points) ;
                   continue
               end
               points.(fields{1})(count - 1) = str2double(parseContent{1}) ;
               points.(fields{2})(count - 1) = str2double(parseContent{2}) ;
               points.(fields{3})(count - 1) = str2double(parseContent{3}) ;
               points.(fields{4})(count - 1) = str2double(parseContent{4}) ;
%                disp(content)
           end
           fclose(fileID) ;
           obj = setPoint(points) ;
       end
    end
end
function output = setPoint(vec)
counter = 1 ;
while true
    p.points(counter) = Point(vec.nn(counter), ...
                         vec.x(counter) , ...
                         vec.y(counter) , ...
                         vec.z(counter)) ;
    counter = counter + 1 ;
    if counter  > length(vec.nn) ; break ; end
end
output = struct2cell(p) ;
output = [output{:}] ;
end