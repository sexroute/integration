function [ output_args ] = computeIntRMS( input_args )
% TransFunGen_AccFs2560.m
% ����TransFunGen_AccFs5120.m
% һ�������ֻ�����
% 
% ֱ�Ӷ�2560Hz�źŻ��֣���������
% �÷���ȱ�㡪�������࣬�ŵ㣺���㲽���١�

 

% DataDir  = 'D:\FengKun\MATLABWORK\MyGeneralFunctions\ExamplesAndTests\IntegralCalculus\IFFTCoefs\';
% DataName = 'IFFTIntWithHPCoefs_5120Hz_Re.txt';
% load([DataDir,DataName])
% DataName = 'IFFTIntWithHPCoefs_5120Hz_Im.txt';
% load([DataDir,DataName])



%

%��ȡ����


% x=load('N205(1)BOF150(A)_n1800Fs20KNs80K.txt');
% Ns = 16384;
% x=10*x(1:Ns);   %��λ m/s^2
% 
% %%%%Ϊ��Ӧ5120��������ƵĻ��������˲������Ƚ�����%%%%
% 
% x=resample(x,1,3);
% x=x(1:4096);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load ('Tian_Vib_acc_data_5120.txt')
x=Tian_Vib_acc_data_5120;
close all;
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%һ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs=2560;    %
QP=1;       %���ز�����ֱ�ӻ���
FsQP=Fs/QP;
SamTime=0.8; %�ɼ�������ʱ�䳤�ȣ���λ:s
% ���ٶȻ���Ϊ�ٶȵĵ�·����   /   QP=8ʱ���� ת�۵�Լ��10Hz
% �������ڱ��뱣֤R2=R3����C1��C2��C3ͬ�����仯��ԽС��ת�۵�Խ���Ƶ�ƶ���
R1=input_args(1);   % �� ŷķ
R2=input_args(2);   % �� ŷķ
R3=input_args(3);      % �� ŷķ
C123Factor=input_args(4);
C1=input_args(5);  %F ���� 
C2=input_args(6);  %F ����
C3=input_args(7);   %F ����
fXmin=input_args(8);
ReCorrFactor=input_args(9);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%һ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% % ���ٶȻ���Ϊ�ٶȵĵ�·����   /   QP=8ʱ���� ת�۵�Լ��10Hz
% �������ڱ��뱣֤R2=R3����C1��C2��C3ͬ���� �仯��ԽС��ת�۵�Խ���Ƶ�ƶ���
% R1=150e3; % �� ŷķ
% R2=4e6;     %�� ŷķ
% R3=4e6;     %�� ŷķ
% C1=0.425*120e-9;  %F ���� 
% C2=0.425*6.8e-9; %����
% C3=0.425*18e-9; %����
% fXmin=1;


G=R1/(R2+R3);


HsNumerator     = G*[C1*C3*R2*R3  C1*(R2+R3)  0];   %1.0889�Ǳ�֤f0=159.159Hz����Ӧ=1e-3������ϵ��
HsNumerator     = ReCorrFactor*HsNumerator;
HsDenominator   = conv( [C2*C3*R2*R3 C2*(R2+R3) 1] ,[C1*R1 1] );

HsSys=tf(HsNumerator,HsDenominator);
% % ���·��������� ������Customizing Response Plots from the Command Line
% h= bodeplot(HsSys,{0.1 10e4});
% setoptions(h,'FreqUnits','Hz')
% setoptions(h,'MagScale','linear')
% setoptions(h,'MagUnits','abs')

% תΪ��ɢʱ��ϵͳ����������FsQP
HzSys=c2d(HsSys,1/FsQP,'tustin');    %ʹ��˫���Ա任��ת��Ϊ��ɢʱ��ϵͳ
tfIntb=get(HzSys,'num');
tfIntb=cell2mat(tfIntb);
tfInta=get(HzSys,'den');
tfInta=cell2mat(tfInta);

Ns=FsQP*SamTime;    %�ֳ�Ԥ������ʱ������������



% n = (0:(Ns-1))';
% ht_Int = filter(tfIntb,tfInta,double(n==0));   %���㵥λ������Ӧ,�����˲�����һ����λ�����źŽ����˲�
% ht_Int_TOL = ht_Int(end);  %���������޳����Ӧ������Ϊ0�����һ��Խ�ӽ��㣬��Խ�ӽ����޳����Ӧ��


%
f0=159.159;
frsp = abs( evalfr(HzSys,exp(1i*2*pi*f0/FsQP)) );   
ReCorrFactor=(2*pi*f0)^(-1)/frsp;
%
%���ƻ�����Ƶ����Ӧ
%clc
%figure('Units','centimeters','PaperPosition',[5, 5, 15, 15],'Position',[5, 5, 15, 12.5]);
%h2=bode(HzSys,{0.1 10e4});
[mag,phase,wout]= bode(HzSys,{0.1 10e4});
% setoptions(h,'FreqUnits','Hz')
%setoptions(h,'MagScale','linear')
%setoptions(h,'MagUnits','abs')

%ResponsesData=h.Responses.data;
FrequencyX=wout/2/pi;


% ��ֵ��
loZ1 = mag(1,1:end)';

loZ2 = load('ideal.txt');


lnZ1 = length(loZ1);
lnZ2 = length(loZ2);

if lnZ1>lnZ2
    
    lnZ1 = lnZ2;
end
    

loZ1 = loZ1(26:lnZ1);
loZ2 = loZ2(26:lnZ1);

lnZ1Max = max(loZ1);
lnZ2Max = max(loZ2);

if lnZ1Max<lnZ2Max
lnZ1Max = lnZ2Max;
end

lnZ1Min = min(loZ1);
lnZ2Min = min(loZ2);

if lnZ1Min>lnZ2Min
lnZ1Min = lnZ2Min;
end

loZ1 = (loZ1-lnZ1Min)/(lnZ1Max-lnZ1Min);
loZ2 = (loZ2-lnZ1Min)/(lnZ1Max-lnZ1Min);

loZ3 = mean((loZ1 - loZ2).^2);


% ��λ��
loZ2 = load('idealp.txt');


loZ1 = phase*180/pi;

lnZ1 = length(loZ1);
lnZ2 = length(loZ2);

if lnZ1>lnZ2
    
    lnZ1 = lnZ2;
end
    

loZ1 = loZ1(26:lnZ1);
loZ2 = loZ2(26:lnZ1);

lnZ1Max = max(loZ1);
lnZ2Max = max(loZ2);

if lnZ1Max<lnZ2Max
lnZ1Max = lnZ2Max;
end

lnZ1Min = min(loZ1);
lnZ2Min = min(loZ2);

if lnZ1Min>lnZ2Min
lnZ1Min = lnZ2Min;
end

loZ1 = (loZ1-lnZ1Min)/(lnZ1Max-lnZ1Min);
loZ2 = (loZ2-lnZ1Min)/(lnZ1Max-lnZ1Min);

%loZ33 = mean((loZ1 - loZ2).^2);

output_args = loZ3
data = output_args;







end

