clc ; clear;
% Göresellerin okunmasý
images = imageDatastore(uigetdir(cd,'Select folder...'));
imageFilename = images.Files;
figure, imshow(imageFilename{1}) % 1. görseli görüntüleme
% figure, imshow(imageFilename{2})
%% kalibrasyon levhasýndaki noktalarýn tespit edilmesi.
[imagePoint, boardSize] = detectCheckerboardPoints(imageFilename);
% image point ölçülen deðerler.
hold on
plot(imagePoint(:, 1, 1), imagePoint(:, 2, 1), 'go') % Birinci görüntü için
%% % Seçilen noktalarý görüntüleme
selectimage = input('Görüntü numarasý : ') ; 
I2 = readimage(images, selectimage);
figure, imshow(I2),hold on
title(['Image ',num2str(selectimage)])
plot(imagePoint(:, 1, selectimage), imagePoint(:, 2, selectimage), 'go');
hold off

%% kamera parametrelerinin belirlenmesi
squareSize = 23; % mm, 
% denklemi sað tarafý için gerekli olan obje uzayýnýn sað tarafýný oluþturmada kullanýlýr.
% karelaj aðý, bir lokal koordinat sistemi oluþturuyor.
worldPoints = generateCheckerboardPoints(boardSize, squareSize); 
% eþitliðin sað tarafýndaki obje uzayýný tanýmlýyor.
% iç yöneltme ve dýþ yöneltme elemanlarý ve diðer parametrelerin hesabý.
cameraParameter = estimateCameraParameters(imagePoint, worldPoints, ...
    'EstimateSkew', true); % kalibrasyon iþlemini gerçekleþtirmek.
figure, showReprojectionErrors(cameraParameter); % hesaplanan deðerler ile ölçülen deðerler arasýndaki farký gösterir.
% reProjeksiyon matrisi kullanarak, oluþturulan obje uzayý ile ,
% görüntü uzayýna sanal izdüþüm gerçekleþtirilir. Her bir kalibrasyon
% noktalarý için tekrar görüntü kordinatlarýnýn izdüþüm ile
% hesaplanýr(reprojecsiyon), hesaplanan deðerler.

%% Tespit edilen görüntü ile reprojected  noktalarýn görüntülenmesi
selectimage = input('Görüntü numarasý : ') ;
figure, imshow(imageFilename{selectimage})
hold on
plot(imagePoint(:, 1, selectimage), imagePoint(:, 2, selectimage), 'go') % 1. görüntü için
plot(cameraParameter.ReprojectedPoints(:, 1, selectimage), ...
    cameraParameter.ReprojectedPoints(:, 2, selectimage), 'r+', 'LineWidth', 1.5)
title(['Image ',num2str(selectimage)])
hold off

%% Dönüklük matrisi, öteleme vektörü , Projeksiyon matrisinin bulunmasý
R = []; t = []; M = [] ;
K = cameraParameter.IntrinsicMatrix; % kamera matrisi, kameranýn iç yöneltme elemanlarýný içerir
for i = 1 : length(imageFilename)
[Rone, tone] = extrinsics(imagePoint(:, :, i), worldPoints, cameraParameter); % dýþ yöneltme elemanlarý
Mone = cameraMatrix(cameraParameter, Rone, tone); % projeksiyon matrisi(izdüþüm)
R(:,:,i) = Rone' ; % dönüklük matrisi
t(:,:,i) = tone' ; % öteleme vektörü
M(:,:,i) = Mone' ; % projeksiyon matrisi
end
% obje uzayýndan her noktayý görüntü uzayýna iz düþürülebilir.

%% Görüntülerin gösterilmesi
exIFolder = imageSet(uigetdir(cd,'Select folder...'));
exI = exIFolder.read(1);
exJI = undistortImage(exI, cameraParameter); % distorsiyon etkilerini giderilmesi.
figure, imshowpair(exI, exJI, 'montage');
title('Orjinal Görüntü(Sol), (Sað)Distorsiyon Etkileri Giderilmiþ Görüntü')
%% JPEG kaydetme
[file, path] = uiputfile('*.jpeg','jpeg kaydet');
print('-djpeg', fullfile(path, file), '-r600');
%% Distorsiyon etkisi giderilmiþ obje görüntüsü
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




