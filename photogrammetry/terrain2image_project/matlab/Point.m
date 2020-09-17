classdef Point
    properties
        Units = 'None'
        nn
        x double
        y double
        z double
    end
    properties
        Style = 'none'
        Marker = '+'
    end
    methods
        function self = Point(nn, x, y, z)
            self.nn = nn;
            self.x = x;
            self.y = y;
            if nargin > 3
                self.z = z;
                self.Units = 'Terrain Coordinate' ;
                if z == 0 ; self.Units = 'Ýmage Coordinate'; end
                if z == -1 ; self.Units = 'Pixel Coordinate'; self.z = 0; end
            end
        end
        function distance = minus(self, other)
            distance = sqrt(([self.x] - [other.x]).^2 + ([self.y] - [other.y]).^2 + ([self.z] - [other.z]).^2) ;
        end
    end
end