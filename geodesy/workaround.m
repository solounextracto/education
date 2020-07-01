clc; clear all;
koord=[41.125 27.75;41.25 27.75;41.25 27.875;41.125 27.875]; 
B=koord(:,1);
L=koord(:,2);

ex = GeodeticTransform('B',B,'L',L) ;
ex.BL2UTM('3',30)

h=[81;121;131;156];
ex.geocentric(h)

data = importdata('ed50itrf.txt');
ed50 = data(:,1:2);
itrf = data(:, 3:4);

ex.transform(ed50,itrf,'Helmert')