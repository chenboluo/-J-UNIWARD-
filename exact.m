clc;clear;
msg = '2.txt';
frr=fopen(msg,'r');
[msg,count]=fread(frr,'ubit1');
C_test = jpeg_read('stego_resutl.jpg');
stego = reshape(C_test.coef_arrays{1},[1,600*800]);
a = [19868	20508];
extr_msg = stc_ml_extract(int32(stego), uint32(a),10);%信息提取
error=sum(msg'~=double(extr_msg));
