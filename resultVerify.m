function [ output_args ] = resultVerify( input_args )

G_Param = input_args;
% x=load('N205(1)BOF150(A)_n1800Fs20KNs80K.txt');
% Ns = 16384;
% x=10*x(1:Ns);   %单位 m/s^2
% 
% %%%%为适应5120采样率设计的积分器、滤波器，先降采样%%%%
% 
% x=resample(x,1,3);
% x=x(1:4096);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load ('Tian_Vib_acc_data_5120.txt')
x=Tian_Vib_acc_data_5120;

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%一般需求%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs=load('freq.txt');    %
QP=1;       %不重采样，直接积分
FsQP=Fs/QP;
SamTime=0.8; %采集的数据时间长度，单位:s
% 加速度积分为速度的电路参数   /   QP=8时采用 转折点约在10Hz
% 参数调节必须保证R2=R3，且C1、C2、C3同比例变化（越小则转折点越向高频移动）
R1=G_Param(1);   % Ω 欧姆
R2=G_Param(2);   % Ω 欧姆
R3=G_Param(3);      % Ω 欧姆
%C123Factor=G_Param(4);
C1=G_Param(4);  %F 法拉 
C2=G_Param(5);  %F 法拉
C3=G_Param(6);   %F 法拉
%fXmin=G_Param(8);
ReCorrFactor=G_Param(7);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%一般需求%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% % 加速度积分为速度的电路参数   /   QP=8时采用 转折点约在10Hz
% 参数调节必须保证R2=R3，且C1、C2、C3同比例 变化（越小则转折点越向高频移动）
% R1=150e3; % Ω 欧姆
% R2=4e6;     %Ω 欧姆
% R3=4e6;     %Ω 欧姆
% C1=0.425*120e-9;  %F 法拉 
% C2=0.425*6.8e-9; %法拉
% C3=0.425*18e-9; %法拉
% fXmin=1;


G=R1/(R2+R3);


HsNumerator     = G*[C1*C3*R2*R3  C1*(R2+R3)  0];   %1.0889是保证f0=159.159Hz处响应=1e-3的修正系数
HsNumerator     = ReCorrFactor*HsNumerator;
HsDenominator   = conv( [C2*C3*R2*R3 C2*(R2+R3) 1] ,[C1*R1 1] );

HsSys=tf(HsNumerator,HsDenominator);
% % 以下风格操作参数 见帮助Customizing Response Plots from the Command Line
% h= bodeplot(HsSys,{0.1 10e4});
% setoptions(h,'FreqUnits','Hz')
% setoptions(h,'MagScale','linear')
% setoptions(h,'MagUnits','abs')

% 转为离散时间系统，采样率用FsQP
HzSys=c2d(HsSys,1/FsQP,'tustin');    %使用双线性变换法转换为离散时间系统
tfIntb=get(HzSys,'num');
tfIntb=cell2mat(tfIntb);
tfInta=get(HzSys,'den');
tfInta=cell2mat(tfInta);

Ns=FsQP*SamTime;    %现场预定采样时间计算采样点数



% n = (0:(Ns-1))';
% ht_Int = filter(tfIntb,tfInta,double(n==0));   %计算单位脉冲响应,即用滤波器对一个单位脉冲信号进行滤波
% ht_Int_TOL = ht_Int(end);  %理论上无限冲击响应不可能为0，最后一个越接近零，就越接近有限冲击响应。


%
f0=159.159;
frsp = abs( evalfr(HzSys,exp(1i*2*pi*f0/FsQP)) );   
ReCorrFactor=(2*pi*f0)^(-1)/frsp;
%
%绘制积分器频率响应
clc
figure('Units','centimeters','PaperPosition',[5, 5, 15, 15],'Position',[5, 5, 15, 12.5]);
h= bodeplot(HzSys,{0.1 10e4});
% setoptions(h,'FreqUnits','Hz')
setoptions(h,'MagScale','linear')
setoptions(h,'MagUnits','abs')

ResponsesData=h.Responses.data;
FrequencyX=ResponsesData.Frequency/2/pi;
subplot(211)


semilogx(FrequencyX,ResponsesData.Magnitude,'LineWidth',1.5);    % 实际结果 ResponsesData.Magnitude
grid minor
xlim([0 FsQP/2.56])
ylim([0 max(ResponsesData.Magnitude)*1.5])
hold on
k = load('ideal.txt');
lnIdeal = length(k);
lnFreq = length(FrequencyX);
if lnIdeal>lnFreq
    lnIdeal = lnFreq;
end
semilogx(FrequencyX(1:lnIdeal),k(1:lnIdeal),'r--');    % 理想目标 1./(ResponsesData.Frequency)  10Hz以上有效！

legend('低频抑制积分器响应','理想积分器响应(1/2\pif)');
xlabel('Frequency/Hz');
ylabel('Magnitude/abs');
subplot(212)
k = load('idealp.txt');
lnIdeal = length(k);
lnFreq = length(FrequencyX);
if lnIdeal>lnFreq
    lnIdeal = lnFreq;
end
semilogx(FrequencyX(1:lnIdeal),k(1:lnIdeal),'r--');
xlabel('Frequency/Hz');
ylabel('Phase/deg');
semilogx(FrequencyX,ResponsesData.Phase*180/pi,'LineWidth',1.5);
hold on

% % 以下风格操作参数 见帮助Customizing Response Plots from the Command Line

grid minor
xlim([0 FsQP/2.56])
output_args = G_Param
