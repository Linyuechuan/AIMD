%   N is the number of mobile ion
%   q(C) is the charge of ions
%   d is the degree of freedom
%   dt(fs) is the distance
%   varargin '700',700,'1000',1000,......
%   Any output is in SI units.
function [D_0,E_a,Conductivity,D_300]=ResultMSD(N,q,d,dt,varargin)
n=nargin-4;
T=cell2mat(varargin(1,2:2:n));
D=ones(1,n/2);
RSD=ones(1,n/2);
%%
filename = ['.\' varargin{1,1} '\lattice.vectors']
delimiter = ' ';

%% ����������Ϊ�ı���ȡ:
% �й���ϸ��Ϣ������� TEXTSCAN �ĵ���
formatSpec = '%s%s%s%[^\n\r]';

%% ���ı��ļ���
fileID = fopen(filename,'r');

%% ���ݸ�ʽ��ȡ�����С�
% �õ��û������ɴ˴������õ��ļ��Ľṹ����������ļ����ִ����볢��ͨ�����빤���������ɴ��롣
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string',  'ReturnOnError', false);

%% �ر��ı��ļ���
fclose(fileID);

%% ��������ֵ�ı���������ת��Ϊ��ֵ��
% ������ֵ�ı��滻Ϊ NaN��
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3]
    % ������Ԫ�������е��ı�ת��Ϊ��ֵ���ѽ�����ֵ�ı��滻Ϊ NaN��
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % ����������ʽ�Լ�Ⲣɾ������ֵǰ׺�ͺ�׺��
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % �ڷ�ǧλλ���м�⵽���š�
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % ����ֵ�ı�ת��Ϊ��ֵ��
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% �����������
lattice = cell2mat(raw);
%% �����ʱ����
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp;
%%
V=lattice(1,1)*lattice(2,2)*lattice(3,3)*10^(-30);
for i=1:n/2
    [D(1,i),RSD(1,i)]=AnalysisMSD(varargin{2*i-1},d,dt,N);
end
x=1000./T;
y=log10(D);
y_upper=log10(D.*(1+RSD));
%y_lower=log10(D.*(1-RSD));
u=(y_upper-y);
f=fit(x',y','poly1','weights',1./u./u)
%f=fit(x',y','poly1')
plot(f,x,y,'.');
hold on
errorbar(x,y,u,u,'.')
xlabel('1000/T (1/K)')
ylabel('log10(D (m^2/s))')
saveas(gcf,'result.jpg')
H=[sum(u.^-2),sum(u.^-2.*x);sum(u.^-2.*x),sum(u.^-2.*x.^2)];
b=[sum(u.^-2.*y);sum(u.^-2.*x.*y)];
InvH=H^-1;
u_inter=InvH(1,1);
u_slope=InvH(2,2);
Kb=1.380649*10^(-23);
E_a=-f.p1*1000*Kb/log10(exp(1));
u_E_a=-u_slope*1000*Kb/log10(exp(1));
D_0=10^(f.p2);
u_D_0=10^(f.p2)*log(10);
D_300=D_0*exp(-E_a/Kb/300);
u_D_300=sqrt((exp(-E_a/300/Kb)*u_D_0)^2+(D_0/300/Kb*exp(-E_a/300/Kb)*u_E_a)^2);
Conductivity=N*q^2*D_300/V/Kb/300;
u_Conductivity=N*q^2*u_D_300/V/Kb/300;
disp(['E_a(eV)  ',num2str(E_a/(1.602*10^(-19))),'+-',num2str(u_E_a/(1.602*10^(-19))),'  D_0(cm^2/s)  ',num2str(D_0*10^4),'+-',num2str(u_D_0*10^4),'  D_300(cm^2/s)  ',num2str(D_300*10^4),'+-',num2str(u_D_300*10^4),'  Conductivity(mS/cm)  ',num2str(Conductivity*10),'+-',num2str(u_Conductivity*10)])
ID=fopen('result.txt','w');
fprintf(ID,'E_a(eV)=%f��%.1G\r\nD_0(cm^2/s)=%f��%.1G\r\nD_300(cm^2/s)=%f��%.1G\r\nConductivity(mS/cm)=%f��%.1G',E_a/(1.602*10^(-19)),u_E_a/(1.602*10^(-19)),D_0*10^4,u_D_0*10^4,D_300*10^4,u_D_300*10^4,Conductivity*10,u_Conductivity*10);
fclose(ID);
% H=[sum(u.^-2),sum(u.^-2.*x);sum(u.^-2.*x),sum(u.^-2.*x.^2)];
% b=[sum(u.^-2.*y);sum(u.^-2.*x.*y)];
% C=H^-1*b
% InvH=H^-1;
% u_inter=InvH(1,1)
% u_slope=InvH(2,2)
% syms x
% ezplot(C(2)*x+C(1))
end
