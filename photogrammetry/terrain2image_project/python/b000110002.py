from terrain2image import Point, Terr2Im

terr = Terr2Im.read('points.txt')

work = Terr2Im()

work.imageproperties = [14430, 9420, 7.2] # row, column, pixel size
work.primepoint = [-0.144, 0, 100.5] # x_0, y_0, f(c)
work.projectionpoint = [427116.06061, 4206076.87177, 1725.71198] # Xc, Yc, Zc
work.rotate = [-0.02242, 1.1115, -0.9816] # omega, phi, kappa

image = work.tr2im(terr)

pixel = work.im2px(image)

print('Terrain Coordinate')
print(terr)
print('İmage Coordinate')
print(image)
print('Pixel Coordinate')
print(pixel)
