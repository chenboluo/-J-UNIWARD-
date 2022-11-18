function [S_STRUCT,a] = J_UNIWARD(coverPath, payload,hidden_message)

% -------------------------------------------------------------------------
% Copyright (c) 2013 DDE Lab, Binghamton University, NY.
% All Rights Reserved.
% -------------------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software for
% educational, research and non-profit purposes, without fee, and without a
% written agreement is hereby granted, provided that this copyright notice
% appears in all copies. The program is supplied "as is," without any
% accompanying services from DDE Lab. DDE Lab does not warrant the
% operation of the program will be uninterrupted or error-free. The
% end-user understands that the program was developed for research purposes
% and is advised not to rely exclusively on the program for any reason. In
% no event shall Binghamton University or DDE Lab be liable to any party
% for direct, indirect, special, incidental, or consequential damages,
% including lost profits, arising out of the use of this software. DDE Lab
% disclaims any warranties, and has no obligations to provide maintenance,
% support, updates, enhancements or modifications.
% -------------------------------------------------------------------------
% Contact: vojtech_holub@yahoo.com | fridrich@binghamton.edu | February
% 2013
%          http://dde.binghamton.edu/download/stego_algorithms/
% -------------------------------------------------------------------------
% This function simulates embedding using J-UNIWARD steganographic 
% algorithm.
% -------------------------------------------------------------------------
% Input:  coverPath ... path to the image
%         payload ..... payload in bits per non zero DCT coefficient
% Output: stego ....... resulting JPEG structure with embedded payload
% -------------------------------------------------------------------------

C_SPATIAL = double(imread(coverPath));

C_SPATIAL2 = imread(coverPath);

%imshow(uint8(C_SPATIAL));
C_STRUCT = jpeg_read(coverPath);
C_COEFFS = C_STRUCT.coef_arrays{1}; %量化系数 coef_arrays
C_QUANT = C_STRUCT.quant_tables{1}; %量化表
PicEdge = 0;
for tmp =0:9
pic2 = im2bw(C_SPATIAL2,0.1*(tmp));
%imwrite(uint8(pic2*255),['pic2_',num2str(tmp),'.png']);

%imshow(uint8(pic2*255));

PicEdge1=edge(pic2,'log');
%imwrite(PicEdge1*255,['log_',num2str(tmp),'.png']);
PicEdge1 = reshape(PicEdge1,[1,600*800]);
PicEdge2=edge(pic2,'canny');
%imwrite(PicEdge2*255,['canny_',num2str(tmp),'.png']);
PicEdge2 = reshape(PicEdge2,[1,600*800]);
PicEdge3=edge(pic2,'sobel');
%imwrite(PicEdge3*255,['sobel_',num2str(tmp),'.png']);
PicEdge3 = reshape(PicEdge3,[1,600*800]);
PicEdge4=edge(pic2,'prewitt');
%imwrite(PicEdge4*255,['prewitt_',num2str(tmp),'.png']);
PicEdge4 = reshape(PicEdge4,[1,600*800]);
PicEdge5=edge(pic2,'roberts');
%imwrite(PicEdge5*255,['roberts_',num2str(tmp),'.png']);
PicEdge5 = reshape(PicEdge5,[1,600*800]);
PicEdge6=edge(pic2,'zerocross');
%imwrite(PicEdge6*255,['zerocross_',num2str(tmp),'.png']);
PicEdge6 = reshape(PicEdge6,[1,600*800]);
zhongijan = (PicEdge1+PicEdge2+PicEdge3+PicEdge4+PicEdge5+PicEdge6)/6;
zhongijan = (PicEdge1+PicEdge2+PicEdge3)/6;
PicEdge = (1-zhongijan) + PicEdge;%1/((tmp-5)^2+1)%(300-abs(tmp-5)*20)

end

PicEdge = PicEdge/8;

%imwrite( reshape(uint8(PicEdge*255),[1,600*800]),'all.png');

wetConst = 10^13;
sgm = 2^(-6);

%% Get 2D wavelet filters - Daubechies 8
% 1D high pass decomposition filter
hpdf = [-0.0544158422, 0.3128715909, -0.6756307363, 0.5853546837, 0.0158291053, -0.2840155430, -0.0004724846, 0.1287474266, 0.0173693010, -0.0440882539, ...
        -0.0139810279, 0.0087460940, 0.0048703530, -0.0003917404, -0.0006754494, -0.0001174768];
% 1D low pass decomposition filter
lpdf = (-1).^(0:numel(hpdf)-1).*fliplr(hpdf);

F{1} = lpdf'*hpdf;
F{2} = hpdf'*lpdf;
F{3} = hpdf'*hpdf;

%% Pre-compute impact in spatial domain when a jpeg coefficient is changed by 1
spatialImpact = cell(8, 8);
for bcoord_i=1:8
    for bcoord_j=1:8
        testCoeffs = zeros(8, 8);
        testCoeffs(bcoord_i, bcoord_j) = 1;
        spatialImpact{bcoord_i, bcoord_j} = idct2(testCoeffs)*C_QUANT(bcoord_i, bcoord_j);
    end
end

%% Pre compute impact on wavelet coefficients when a jpeg coefficient is changed by 1
waveletImpact = cell(numel(F), 8, 8);
for Findex = 1:numel(F)
    for bcoord_i=1:8
        for bcoord_j=1:8
            waveletImpact{Findex, bcoord_i, bcoord_j} = imfilter(spatialImpact{bcoord_i, bcoord_j}, F{Findex}, 'full');
        end
    end
end

%% Create reference cover wavelet coefficients (LH, HL, HH)
% Embedding should minimize their relative change. Computation uses mirror-padding
padSize = max([size(F{1})'; size(F{2})']);
C_SPATIAL_PADDED = padarray(C_SPATIAL, [padSize padSize], 'symmetric'); % pad image

RC = cell(size(F));
for i=1:numel(F)
    RC{i} = imfilter(C_SPATIAL_PADDED, F{i});
end

[k, l] = size(C_COEFFS);

nzAC = nnz(C_COEFFS)-nnz(C_COEFFS(1:8:end,1:8:end));
%hidden_message=double(rand(1,round(payload * nzAC))<0.5);
rho = zeros(k, l);
tempXi = cell(3, 1);

%% Computation of costs
for row = 1:k
    for col = 1:l
        modRow = mod(row-1, 8)+1;
        modCol = mod(col-1, 8)+1;        
        
        subRows = row-modRow-6+padSize:row-modRow+16+padSize;
        subCols = col-modCol-6+padSize:col-modCol+16+padSize;
     
        for fIndex = 1:3
            % compute residual
            RC_sub = RC{fIndex}(subRows, subCols);            
            % get differences between cover and stego
            wavCoverStegoDiff = waveletImpact{fIndex, modRow, modCol};
            % compute suitability
            tempXi{fIndex} = abs(wavCoverStegoDiff) ./ (abs(RC_sub)+sgm);           
        end
        rhoTemp = tempXi{1} + tempXi{2} + tempXi{3};
        rho(row, col) = sum(rhoTemp(:));
    end
end

rhoM1 = rho;
rhoP1 = rho;

rhoP1(rhoP1 > wetConst) = wetConst;
rhoP1(isnan(rhoP1)) = wetConst;    
rhoP1(C_COEFFS > 1023) = wetConst;
    
rhoM1(rhoM1 > wetConst) = wetConst;
rhoM1(isnan(rhoM1)) = wetConst;
rhoM1(C_COEFFS < -1023) = wetConst;
        
cover=C_COEFFS(:);
costs=zeros(3,k*l,'single');
costs(1,:)=rhoM1(:);
costs(3,:)=rhoP1(:);
costs(1,:)=PicEdge*3000;
costs(3,:)=PicEdge;
%costs = costs.*PicEdge;
imagesc(reshape(costs(1,:),[600,800]))%画图

%% --------------------------- 信息嵌入 ------------------------------------
[~,stego,a,~] = stc_pm1_pls_embed(int32(cover)',costs,uint8(hidden_message),10);%信息嵌入
extr_msg = stc_ml_extract(int32(stego), a,10);%信息提取
error=sum(hidden_message~=double(extr_msg));%验证信息是否正确嵌入
S_STRUCT = C_STRUCT;
stego=reshape(stego,[k l]);
stego=double(stego);
S_STRUCT.coef_arrays{1} = stego;
end
