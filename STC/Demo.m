clear all;clc;
addpath(fullfile('E:\VictorWei\ResearchCode\JPEG Steganography\STC'));
addpath(fullfile('E:\VictorWei\ResearchCode\JPEG Steganography\Jpeg_toolbox'));
tic;

n=10;%��n��ͼ����д
payload=0.1;
QF=75;
file_path='E:\VictorWei\ResearchCode\JPEG Steganography\cover(QF75)\';% ͼ���ļ���·��
img_path_list = dir(strcat(file_path,'*.jpg'));%��ȡ���ļ���������jpg��ʽ��ͼ��
for i=1:n
    image_name = img_path_list(i).name;%ͼ����
    COVER=strcat(file_path,image_name);
    STEGO=['E:\VictorWei\ResearchCode\JPEG Steganography\J_Spatial_2\Code\stegos01\',image_name];
    S_STRUCT = Residual_Block_JS(COVER,payload);
    temp = load(strcat('default_gray_jpeg_obj_', num2str(QF), '.mat'));
    default_gray_jpeg_obj = temp.default_gray_jpeg_obj;
    C_STRUCT = default_gray_jpeg_obj;
    C_STRUCT.coef_arrays{1} = S_STRUCT.coef_arrays{1};
    jpeg_write(C_STRUCT,STEGO);
    fprintf(['�� ',num2str(i),' ��ͼ��-------- ok','\n']);
end
% matlabpool close
toc;
% -------------------------------------------------------------------------