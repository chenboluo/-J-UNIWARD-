%读取一张图片，并显示
original_picture=imread('mytest.jpg');
original_picture1=imread('stego_mytest.jpg'); % 我们的 +20
original_picture2=imread('对比实验\J-uniward实验.jpg');%他的

x1 = psnr(original_picture,original_picture1);
x2 = psnr(original_picture,original_picture2);
%x3 = psnr(original_picture,original_picture3);

u1 = ssim(original_picture,original_picture1);
u2 = ssim(original_picture,original_picture2);
%u3 = ssim(original_picture,original_picture3);


return

Pic2=im2bw(original_picture,0.5);
figure(1)
subplot(2,2,1);
imshow(original_picture);
title('原始RGB图像')
subplot(222)
imshow(Pic2)
title('二值化图像')

%用edge算法对二值化图像进行边缘提取
PicEdge1=edge(Pic2,'log');
subplot(223);
imshow(PicEdge1);
title('log算子')

PicEdge2 = edge(Pic2,'canny');
subplot(224);
imshow(PicEdge2);
title('canny算子');

PicEdge3=edge(Pic2,'sobel');
figure(2)
subplot(221)
imshow(PicEdge3);
title('sobel算子')

PicEdge4=edge(Pic2,'prewitt');
subplot(222)
imshow(PicEdge4);
title('sprewitt算子')

PicEdge5=edge(Pic2,'zerocross');
subplot(223)
imshow(PicEdge5);
title('zerocross算子')

PicEdge6=edge(Pic2,'roberts');
subplot(224)
imshow(PicEdge6);
title('roberts算子')


function [PSNR, MSE] = psnr(X, Y) % 计算峰值信噪比PSNR
% 将RGB转成YCbCr格式进行计算，不同的计算可能会不同

 if size(X,3)~=1   %判断图像时不是彩色图，如果是，结果为3，否则为1
   org=rgb2ycbcr(X);
   test=rgb2ycbcr(Y);
   Y1=org(:,:,1);
   Y2=test(:,:,1);
   Y1=double(Y1);  %计算平方时候需要转成double类型，否则uchar类型会丢失数据
   Y2=double(Y2);
 else              %灰度图像，不用转换
     Y1=double(X);
     Y2=double(Y);
 end
 
if nargin<2    
   D = Y1;
else
  if any(size(Y1)~=size(Y2))
    error('The input size is not equal，please check');
  end
 D = Y1 - Y2; 
end
MSE = sum(D(:).*D(:)) / numel(Y1); 
PSNR = 10*log10(255^2 / MSE);
end




