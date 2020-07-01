clc ; clear;
% G�resellerin okunmas�
images = imageDatastore(uigetdir(cd,'Select folder...'));
imageFilename = images.Files;
figure, imshow(imageFilename{1}) % 1. g�rseli g�r�nt�leme
% figure, imshow(imageFilename{2})
%% kalibrasyon levhas�ndaki noktalar�n tespit edilmesi.
[imagePoint, boardSize] = detectCheckerboardPoints(imageFilename);
% image point �l��len de�erler.
hold on
plot(imagePoint(:, 1, 1), imagePoint(:, 2, 1), 'go') % Birinci g�r�nt� i�in
%% % Se�ilen noktalar� g�r�nt�leme
selectimage = input('G�r�nt� numaras� : ') ; 
I2 = readimage(images, selectimage);
figure, imshow(I2),hold on
title(['Image ',num2str(selectimage)])
plot(imagePoint(:, 1, selectimage), imagePoint(:, 2, selectimage), 'go');
hold off

%% kamera parametrelerinin belirlenmesi
squareSize = 23; % mm, 
% denklemi sa� taraf� i�in gerekli olan obje uzay�n�n sa� taraf�n� olu�turmada kullan�l�r.
% karelaj a��, bir lokal koordinat sistemi olu�turuyor.
worldPoints = generateCheckerboardPoints(boardSize, squareSize); 
% e�itli�in sa� taraf�ndaki obje uzay�n� tan�ml�yor.
% i� y�neltme ve d�� y�neltme elemanlar� ve di�er parametrelerin hesab�.
cameraParameter = estimateCameraParameters(imagePoint, worldPoints, ...
    'EstimateSkew', true); % kalibrasyon i�lemini ger�ekle�tirmek.
figure, showReprojectionErrors(cameraParameter); % hesaplanan de�erler ile �l��len de�erler aras�ndaki fark� g�sterir.
% reProjeksiyon matrisi kullanarak, olu�turulan obje uzay� ile ,
% g�r�nt� uzay�na sanal izd���m ger�ekle�tirilir. Her bir kalibrasyon
% noktalar� i�in tekrar g�r�nt� kordinatlar�n�n izd���m ile
% hesaplan�r(reprojecsiyon), hesaplanan de�erler.

%% Tespit edilen g�r�nt� ile reprojected  noktalar�n g�r�nt�lenmesi
selectimage = input('G�r�nt� numaras� : ') ;
figure, imshow(imageFilename{selectimage})
hold on
plot(imagePoint(:, 1, selectimage), imagePoint(:, 2, selectimage), 'go') % 1. g�r�nt� i�in
plot(cameraParameter.ReprojectedPoints(:, 1, selectimage), ...
    cameraParameter.ReprojectedPoints(:, 2, selectimage), 'r+', 'LineWidth', 1.5)
title(['Image ',num2str(selectimage)])
hold off

%% D�n�kl�k matrisi, �teleme vekt�r� , Projeksiyon matrisinin bulunmas�
R = []; t = []; M = [] ;
K = cameraParameter.IntrinsicMatrix; % kamera matrisi, kameran�n i� y�neltme elemanlar�n� i�erir
for i = 1 : length(imageFilename)
[Rone, tone] = extrinsics(imagePoint(:, :, i), worldPoints, cameraParameter); % d�� y�neltme elemanlar�
Mone = cameraMatrix(cameraParameter, Rone, tone); % projeksiyon matrisi(izd���m)
R(:,:,i) = Rone' ; % d�n�kl�k matrisi
t(:,:,i) = tone' ; % �teleme vekt�r�
M(:,:,i) = Mone' ; % projeksiyon matrisi
end
% obje uzay�ndan her noktay� g�r�nt� uzay�na iz d���r�lebilir.

%% G�r�nt�lerin g�sterilmesi
exIFolder = imageSet(uigetdir(cd,'Select folder...'));
exI = exIFolder.read(1);
exJI = undistortImage(exI, cameraParameter); % distorsiyon etkilerini giderilmesi.
figure, imshowpair(exI, exJI, 'montage');
title('Orjinal G�r�nt�(Sol), (Sa�)Distorsiyon Etkileri Giderilmi� G�r�nt�')
%% JPEG kaydetme
[file, path] = uiputfile('*.jpeg','jpeg kaydet');
print('-djpeg', fullfile(path, file), '-r600');
%% Distorsiyon etkisi giderilmi� obje g�r�nt�s�
exJI2 = undistortImage(exI, cameraParameter,'outputview', 'full');
figure, imshow(exJI2);

%% save
A = M ; % kaydedilecek parametre
[file, ~] = uiputfile('*.txt','txt kaydet');
fid = fopen(file,'wt');
for i = 1 : size(A,3)
    fprintf(fid,'\t Image %d \n',i) ;
    for ii = 1 : size(A(:,:,i),1)
        fprintf(fid,'%g  ',A(ii,:,i));
        fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
end
fclose(fid) ;

%% save 2
[file, path] = uiputfile('*.txt','txt kaydet');
% cameraParameter.RadialDistortion
% K'
B = K' ;
fid2 = fopen(file,'wt');
for j = 1:size(B,1)
    fprintf(fid2,'%g\t',B(j,:));
    fprintf(fid2,'\n');
end
fclose(fid2) ;




