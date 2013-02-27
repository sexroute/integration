function [ output_args ] = resultVerify( input_args )

G_Param = input_args;
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

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%һ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs=2560;    %
QP=1;       %���ز�����ֱ�ӻ���
FsQP=Fs/QP;
SamTime=0.8; %�ɼ�������ʱ�䳤�ȣ���λ:s
% ���ٶȻ���Ϊ�ٶȵĵ�·����   /   QP=8ʱ���� ת�۵�Լ��10Hz
% �������ڱ��뱣֤R2=R3����C1��C2��C3ͬ�����仯��ԽС��ת�۵�Խ���Ƶ�ƶ���
R1=G_Param(1);   % �� ŷķ
R2=G_Param(2);   % �� ŷķ
R3=G_Param(3);      % �� ŷķ
C123Factor=G_Param(4);
C1=G_Param(5);  %F ���� 
C2=G_Param(6);  %F ����
C3=G_Param(7);   %F ����
fXmin=G_Param(8);
ReCorrFactor=G_Param(9);
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
clc
figure('Units','centimeters','PaperPosition',[5, 5, 15, 15],'Position',[5, 5, 15, 12.5]);
h= bodeplot(HzSys,{0.1 10e4});
% setoptions(h,'FreqUnits','Hz')
setoptions(h,'MagScale','linear')
setoptions(h,'MagUnits','abs')

ResponsesData=h.Responses.data;
FrequencyX=ResponsesData.Frequency/2/pi;
subplot(211)


semilogx(FrequencyX,ResponsesData.Magnitude,'LineWidth',2.5);    % ʵ�ʽ�� ResponsesData.Magnitude
grid minor
xlim([fXmin FsQP/2.56])
ylim([0 max(ResponsesData.Magnitude)*1.5])
hold on
k = load('ideal.txt');
semilogx(FrequencyX,k,'r--');    % ����Ŀ�� 1./(ResponsesData.Frequency)  10Hz������Ч��

legend('��Ƶ���ƻ�������Ӧ','�����������Ӧ(1/2\pif)');
xlabel('Frequency/Hz');
ylabel('Magnitude/abs');
subplot(212)
k = load('idealp.txt');
semilogx(FrequencyX,k,'r--');
xlabel('Frequency/Hz');
ylabel('Phase/deg');
semilogx(FrequencyX,ResponsesData.Phase*180/pi,'LineWidth',2.5);
hold on

% % ���·��������� ������Customizing Response Plots from the Command Line

grid minor
xlim([fXmin FsQP/2.56])
output_args = G_Param
