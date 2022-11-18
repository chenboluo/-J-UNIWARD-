clear all;clc;
addpath(genpath(pwd));
%--------------------------------------------------------------------------
tic;
n=1;%��n��ͼ����д
payload=0.5;
QF=75;
msg = '2.txt';
frr=fopen(msg,'r');
[msg,count]=fread(frr,'ubit1');

image_name = 'mytest.jpg';%��ȡ���ļ���������jpg��ʽ��ͼ��
% matlabpool local 4
for i=1:n
    COVER=image_name;
    STEGO=['stego_',image_name];
    [S_STRUCT,a] = J_UNIWARD(COVER,payload,msg');
    C_STRUCT = jpeg_read(image_name);
    C_STRUCT.coef_arrays{1} = S_STRUCT.coef_arrays{1};
    jpeg_write(C_STRUCT,STEGO);
    fprintf(['�� ',num2str(i),' ��ͼ��-------- ok','\n']);
    C_test = jpeg_read(STEGO);
    stego = reshape(C_test.coef_arrays{1},[1,600*800]);
    extr_msg = stc_ml_extract(int32(stego), uint32(a),10);%��Ϣ��ȡ
    error=sum(msg'~=extr_msg);%��֤��Ϣ�Ƿ���ȷǶ��
end
% matlabpool close;
toc;
%--------------------------------------------------------------------------