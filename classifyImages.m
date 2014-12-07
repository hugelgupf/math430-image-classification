%% Classify images from a specific data set
% David H.
% Math 415 Project 4
% Christopher K., Darrel B.
function [meanVals, stdVals, vals] = classifyImages(MCmax)
  img = rgb2gray(imread('1a.jpg'));
  [m,n] = size(img);
  gender=load('gender.txt');
  nimg = 200;
  gender = gender(1:nimg);
  if nargin<1,
    MCmax = 1;
  end
  tSizes = [50];%[5 10 15 25 50];% 100 200];
  nKs = [5 10 15 25 50];%[5 10 15 25 50];
  NTmax = length(tSizes);
  NKmax = length(nKs);
  allImgs = zeros(m*n,nimg);
  allSmile = zeros(m*n,nimg);
  for i = 1:nimg
    filename = sprintf('%da.jpg',i);
    img = rgb2gray(imread(filename));
    allImgs(:,i) = img(:);
    filename = sprintf('%db.jpg',i);
    img = rgb2gray(imread(filename));
    allSmile(:,i) = img(:);
  end
  meanImg = mean(allImgs,2);
  randImg = mean(meanImg(:))+std(meanImg(:))*randn(m*n,1);
  meanFemale = mean(allImgs(:,gender==-1),2);
  meanMale = mean(allImgs(:,gender==1),2);
  figure(1);
  subplot(1,3,1);
  imagesc(reshape(meanImg,m,n));colormap gray;axis image;
  subplot(1,3,2);
  imagesc(reshape(meanMale,m,n));colormap gray;axis image;
  subplot(1,3,3);
  imagesc(reshape(meanFemale,m,n));colormap gray;axis image;
  vals = zeros(MCmax*NTmax*NKmax,16);
  meanVals = zeros(NTmax*NKmax,16);
  stdVals = zeros(NTmax*NKmax,16);
  nMale = sum(gender==1);
  nFemale = sum(gender==-1);
  
  %% MC Loop
  k = 0;
  kt = 0;
  for nTrain = tSizes;
    for nK = nKs(nKs<=nTrain);
      kt = kt+1;
      for M = 1:MCmax
        doClassification();
      end
      if MCmax > 1,
        meanVals(kt,:) = nanmean(vals(MCmax*(kt-1)+1:MCmax*kt,:));
        stdVals(kt,:) = nanstd(vals(MCmax*(kt-1)+1:MCmax*kt,:));
      else
        meanVals(kt,:) = vals(MCmax*(kt-1)+1:MCmax*kt,:);
        stdVals(kt,:) = vals(MCmax*(kt-1)+1:MCmax*kt,:);
      end
    end
  end
  meanVals = meanVals(1:kt,:);
  stdVals = stdVals(1:kt,:);
  vals = vals(1:k,:);
  
  function doClassification()
    %% Training dataset info
    k = k+1;
    trainSet = randperm(nimg,nTrain);
    trainGend = gender(trainSet);
    trainImgs = allImgs(:,trainSet);
%     trainMean = mean(trainImgs,2);
    [U,S,V] = svd(trainImgs,'econ');
    nmale = sum(trainGend==1);
    nfem = sum(trainGend==-1);
    mfRat = nmale/nfem;
    vals(k,1:4) = [nTrain,nK,M,nmale];
    %     figure(2)
    %     for i = 1:5
    %       subplot(1,5,i);
    %       imagesc(reshape(U(:,i),m,n));colormap gray; axis image;
    %     end
    %     figure(3)
    %     hold all
    %     plot(V(trainGend==-1,1:15)','+k');
    %     plot(V(trainGend==1,1:15)','.r');
    %     hold off
    allV = S\(U\allImgs);
    smileV = S\(U\allSmile);
    randV = S\(U\randImg);
    %% Nonsmiling to nonsmiling
    [allCl] = classify(allV(1:nK,:)',[V(:,1:nK);randV(1:nK)'],[trainGend;0],'diaglinear');
    diff = allCl - gender;
    MasM = sum(diff(gender==1)==0);
    MasF = sum(diff(gender==1)~=0);
    FasM = sum(diff(gender==-1)~=0);
    FasF = sum(diff(gender==-1)==0);
    vals(k,5:8) = [MasM, FasM, MasF, FasF];
    disp('numTrainImg  numKValues');
    disp([nTrain,nK]);
    table_NoSmileRecogNoSmile = [MasM, FasM;MasF, FasF];
    disp(table_NoSmileRecogNoSmile);
    TM = MasM;
    TF = FasF;
    FM = MasF;
    FF = FasM;
    ACC = (TM + TF)/nimg;
%     FDR = (FM)/(TM+FM);
%     FOR = (FF)/(TF+FF);
    TMR = (TM)/(TM+FF);
    FMR = (FM)/(TF+FM);
    FFR = (FF)/(TM+FF);
    TFR = (TF)/(TF+FM);
    vals(k,5:8) = [TMR, FMR, FFR, TFR];
%     MPV = (TM)/(TM+FM);
%     FPV = (TF)/(TF+FF);
    LRp = TMR/FMR;
    LRn = FFR/TFR;
    DOR = LRp/LRn;
    vals(k,9:10) = [ACC,DOR];
    %% Nonsmiling to smiling
    [smileCl] = classify(smileV(1:nK,:)',V(:,1:nK),trainGend,'diaglinear');
    diff = smileCl - gender;
    MasM = sum(diff(gender==1)==0);
    MasF = sum(diff(gender==1)~=0);
    FasM = sum(diff(gender==-1)~=0);
    FasF = sum(diff(gender==-1)==0);
    vals(k,11:14) = [MasM, FasM, MasF, FasF]./nimg;
    table_NoSmileRecogSmile = [MasM, FasM;MasF, FasF];
    disp(table_NoSmileRecogSmile);
    TM = MasM;
    TF = FasF;
    FM = MasF;
    FF = FasM;
    ACC = (TM + TF)/nimg;
%     FDR = (FM)/(TM+FM);
%     FOR = (FF)/(TF+FF);
    TMR = (TM)/(TM+FF);
    FMR = (FM)/(TF+FM);
    FFR = (FF)/(TM+FF);
    TFR = (TF)/(TF+FM);
    vals(k,11:14) = [TMR, FMR, FFR, TFR];
%     MPV = (TM)/(TM+FM);
%     FPV = (TF)/(TF+FF);
    LRp = TMR/FMR;
    LRn = FFR/TFR;
    DOR = LRp/LRn;
    vals(k,15:16) = [ACC,DOR];
    
    % tmp = U*S*V(15,:)';
    % figure(4)
    % imagesc(reshape(tmp,m,n));colormap gray; axis image;
  end
end
