clear;clc;close all;
G_Param = [];
G_Param(1) =150e3;   % Ω 欧姆
G_Param(2)=1.5e6;   % Ω 欧姆
G_Param(3)=1.5e6;      % Ω 欧姆
G_Param(4)=1;
G_Param(5)=120e-9;  %F 法拉 
G_Param(6)=6.8e-9;  %F 法拉
G_Param(7)=18e-9;   %F 法拉
G_Param(8)=1*1;
G_Param(9)=0.0204*1.00011*1.0108;

resultVerify(G_Param);
G_Param=[1.5832193e+05   1.5050302e+06   1.4253190e+06   8.0623090e-01   9.7772105e-08   7.4749861e-09   2.9858718e-08   7.4099484e-01   2.1808291e-02];


% z=[1.0e+06,0.1500e+06,  1.5000,    1.5000,    0.0000,    0.0000,   -0.0000 ,  -0.0000 ,   0.0000,    0.0000];
%val =computeIntRMS(G_Param);
resultVerify(G_Param);
%opt = optimset ( 'MaxIter' , 100);
%[x, fval, exitflag, output] = fminsearch(@computeIntRMS,G_Param,opt)
%save('opt_result.txt','x','-ascii');

%resultVerify(oem);
%resultVerify(x);
