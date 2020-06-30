classdef Im2Terrain < handle
    properties
        Pixel
        Image
        Terrain
    end
    properties (Hidden = true)
        Interior
        Exterior
        Pix
        imageSize
    end
    methods (Abstract)
        selectPoint(self)
    end
    methods 
        function disp(self)
            NN = 1:length(self.Terrain) ;
            title = {'NN', ' X ', ' Y ', ' Z '};
            fprintf('%s\t      %s\t \t        %s\t \t       %s     \n', title{1}, title{2}, title{3}, title{4})
            fprintf('  %d         %.3f          %.3f          %.3f\n', ...
                [NN', self.Terrain(:,1), self.Terrain(:,2), self.Terrain(:,3)]')
        end
    end
    methods (Hidden = true)
        function transformImage(self)
            self.Image.Left = self.pix2im(self.Pixel.Left, self.imageSize.Left);
            self.Image.Right = self.pix2im(self.Pixel.Right, self.imageSize.Right);
        end
    end  
    
    methods (Access = private)
        function output = pix2im(self, px, size)
            x0 = self.Interior(1); y0 = self.Interior(2);
            row = size(1); column = size(2);
            x = (px(:,1) - column / 2)*(self.Pix/1000)-x0;
            y = (row / 2 - px(:,2))*(self.Pix/1000)-y0;
            output = [x, y];
        end
    end
    methods (Static)
        function saveFile(data)
            [filename] = uiputfile( ...
                {'*.txt','Text Files (*.txt)';'*ncn','Netcad Files (*.ncn)'});
            data = [(1:length(data))', data] ;
            if size(data, 2) > 3
                str = '%d\t%.3f\t%.3f\t%.3f\n' ;
            else
                str = '%d\t%.3f\t%.3f\n' ;
            end
            myFile = fopen(filename, 'w');
            fprintf(myFile, str , data' );
            fclose(myFile);
        end
    end
end
