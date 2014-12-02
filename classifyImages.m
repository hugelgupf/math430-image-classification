%% Classify images from a specific data set
% David H.
% Math 415 Project 4
% Christopher K., Darrel B.

img = imread('1a.jpg');
[m,n] = size(img);
nimg = 200;
allImgs = zeros(m*n,nimg);
allSmile = zeros(m*n,nimg);
load gender.txt
nTrain = 50;
trainSet = randperm(200,nTrain);
for i = 1:nimg
  filename = sprintf('%da.jpg',i);
  img = imread(filename);
  allImgs(:,i) = img(:);
  filename = sprintf('%db.jpg',i);
  img = imread(filename);
  allSmile(:,i) = img(:);
end
meanImg = mean(allImgs,2);
meanFemale = mean(allImgs(:,gender==-1),2);
meanMale = mean(allImgs(:,gender==1),2);
figure(1);
subplot(1,3,1);
imagesc(reshape(meanImg,m,n));colormap gray;axis image;
subplot(1,3,2);
imagesc(reshape(meanMale,m,n));colormap gray;axis image;
subplot(1,3,3);
imagesc(reshape(meanFemale,m,n));colormap gray;axis image;

%% Training dataset info
trainGend = gender(trainSet);
trainImgs = allImgs(:,trainSet);
trainMean = mean(trainImgs,2);
[U,S,V] = svd(trainImgs,'econ');
nmale = sum(trainGend==1);
nfem = sum(trainGend==-1);
mfRat = nmale/nfem

figure(2)
for i = 1:5
  subplot(1,5,i);
  imagesc(reshape(U(:,i),m,n));colormap gray; axis image;
end
figure(3)
hold all
plot(V(trainGend==-1,1:15)','+k');
plot(V(trainGend==1,1:15)','.r');
hold off
allV = S\(U\allImgs);
smileV = S\(U\allSmile);

%% Nonsmiling to nonsmiling
[allCl,clERR,clPOSTERIOR,clLOGP,clCOEF] = classify(allV(1:15,:)',V(:,1:15),trainGend,'diaglinear');
diff = allCl - gender;
MasM = sum(diff(gender==1)==0);
MasF = sum(diff(gender==1)~=0);
FasM = sum(diff(gender==-1)~=0);
FasF = sum(diff(gender==-1)==0);
table = [MasM, FasM;MasF, FasF];
TM = MasM;
TF = FasF;
FM = MasF;
FF = FasM;
ACC = (TM + TF)/nimg;
FDR = (FM)/(TM+FM);
FOR = (FF)/(TF+FF);
TMR = (TM)/(TM+FF);
FMR = (FM)/(FF+FM);
FFR = (FF)/(TM+FF);
TFR = (TF)/(TF+FM);
MPV = (TM)/(TM+FM);
FPV = (TF)/(TF+FF);
LRp = TMR/FMR;
LRn = FFR/TFR;
DOR = LRp/LRn;
table
ACC
DOR


%% Nonsmiling to smiling
[smileCl] = classify(smileV(1:15,:)',V(:,1:15),trainGend,'diaglinear');
diff = smileCl - gender;
MasM = sum(diff(gender==1)==0);
MasF = sum(diff(gender==1)~=0);
FasM = sum(diff(gender==-1)~=0);
FasF = sum(diff(gender==-1)==0);
table = [MasM, FasM;MasF, FasF];
TM = MasM;
TF = FasF;
FM = MasF;
FF = FasM;
ACC = (TM + TF)/nimg;
FDR = (FM)/(TM+FM);
FOR = (FF)/(TF+FF);
TMR = (TM)/(TM+FF);
FMR = (FM)/(FF+FM);
FFR = (FF)/(TM+FF);
TFR = (TF)/(TF+FM);
MPV = (TM)/(TM+FM);
FPV = (TF)/(TF+FF);
LRp = TMR/FMR;
LRn = FFR/TFR;
DOR = LRp/LRn;
table
ACC
DOR

% tmp = U*S*V(15,:)';
% figure(4)
% imagesc(reshape(tmp,m,n));colormap gray; axis image;
