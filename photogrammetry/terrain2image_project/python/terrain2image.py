from math import pi, sin, cos

class Point:
    def __init__(self, nn, x, y, z=0):
        self.nn = nn
        self.x  = x
        self.y  = y
        self.z  = z

    def __repr__(self):
        return "(NN:% s, X:% s, Y:% s, Z:% s)\n" % (self.nn, self.x, self.y, self.z)


class Terr2Im:
    def __init__(self):
        self._improp = []
        self._primep = []
        self._projectionp = []
        self._rotation = []
    # image properties
    @property
    def imageproperties(self):
        #print('getter of improp called')
        return self._improp

    @imageproperties.setter
    def imageproperties(self, ip):
        #print('improp setter called')
        self._improp = ip

    # prime point
    @property
    def primepoint(self):
        #print('getter of primepoint called')
        return self._primep

    @primepoint.setter
    def primepoint(self, pp):
        #print('primepoint setter called')
        self._primep = pp
        
    # projection point
    @property
    def projectionpoint(self):
        #print('getter of projectionpoint called')
        return self._projectionp

    @projectionpoint.setter
    def projectionpoint(self, pp):
        #print('projectionpoint setter called')
        self._projectionp = pp

    # rotation matrix
    @property
    def rotate(self):
        #print('getter of rotate called')
        return self._rotation
        
    @rotate.setter
    def rotate(self, rt):
        #print('rotate setter called')
        self._rotation = rt

    @property
    def M(self):
        return self.__rotationMatrix()

    def tr2im(self, points):
        return self.__terr2im(points)

    def im2px(self, points):
        return self.__im2pix(points)
    
    def __rotationMatrix(self):
        rad = lambda deg: deg*(pi/180)
        om, ph, kp = list(map(rad,self.rotate))
        rotateMatrix =[[cos(ph)*cos(kp), cos(om)*sin(kp)+sin(om)*sin(ph)*cos(kp), sin(om)*sin(kp)-cos(om)*sin(ph)*cos(kp)],
        [-cos(ph)*sin(kp), cos(om)*cos(kp)-sin(om)*sin(ph)*sin(kp), sin(om)*cos(kp)+cos(om)*sin(ph)*sin(kp)],
        [sin(ph), -sin(om)*cos(ph), cos(om)*cos(ph)]]
        return rotateMatrix

    def __terr2im(self, points):
        x0, y0, f  = self.primepoint
        Xc, Yc, Zc = self.projectionpoint
        m = self.__rotationMatrix()
        imagepoints = []
        for i in range(len(points)):
            pt = points[i]
            nn, X, Y, Z = pt.nn, pt.x, pt.y, pt.z
            imagex = (-f*(((m[0][0]*(X-Xc))+(m[0][1]*(Y-Yc))+(m[0][2]*(Z-Zc))) /
                ((m[2][0]*(X-Xc))+(m[2][1]*(Y-Yc))+(m[2][2]*(Z-Zc))))) + x0
            imagey = (-f*(((m[1][0]*(X-Xc))+(m[1][1]*(Y-Yc))+(m[1][2]*(Z-Zc))) /
                ((m[2][0]*(X-Xc))+(m[2][1]*(Y-Yc))+(m[2][2]*(Z-Zc))))) + y0
            imagepoints.append(Point(nn, imagex, imagey))
        return imagepoints

    def __im2pix(self, points):
        ip = self.imageproperties
        pp = self.primepoint
        pixelpoint = []
        for i in range(len(points)):
            pt = points[i]
            nn, x, y = pt.nn, pt.x, pt.y
            pixelx = round(( x /(ip[2]/1000)) + (ip[1] / 2) + pp[0])
            pixely = round((-y /(ip[2]/1000)) + (ip[0] / 2) + pp[1])
            pixelpoint.append(Point(nn, pixelx, pixely))
        return pixelpoint

    @staticmethod
    def read(doc):
        with open(doc, 'r', encoding='utf-8') as file:
            lst = []
            content = file.readlines()
            for pt in content:
                pt = pt.split(' ')
                lst.append(pt)
                #print(pt)

            nn, x, y, z = [], [], [], []
            lst = lst[1:]

            for ls in lst:
                nn.append(ls[0])
                x.append(ls[1])
                y.append(ls[2])
                if ls[3][-1] == '\n':
                    z.append(ls[3][:-1])
                else:
                    z.append(ls[3])

            nn = list(map(int, nn))
            x = list(map(float, x))
            y = list(map(float, y))
            z = list(map(float, z))

            points = []
            for i in range(len(nn)):
                points.append(Point(nn[i],x[i],y[i],z[i]))

            return points
