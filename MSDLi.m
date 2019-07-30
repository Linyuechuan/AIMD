%% Load the result from previous run. If this is the first run, this segment should be referenced.
%load('TMSD.mat')
filename = 'XDATCAR';
delimiter = ' ';
startRow = 7;
endRow = 7;
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n')
fclose(fileID);
m = dataArray{:, 1};
n=sum(cell2mat(dataArray(1,1:end-1)))+2;
clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;

%% Get fractional coordinates 
filename = 'XDATCAR_fract.xyz';
delimiter = ' ';
formatSpec = '%*s%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
x = dataArray{:, 1};
y = dataArray{:, 2};
z = dataArray{:, 3};
clearvars filename delimiter formatSpec fileID dataArray ans;
%% Get the size of lattice
filename ='lattice.vectors';
delimiter = ' ';
formatSpec = '%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3]
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
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
lattice = cell2mat(raw);
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp;
%% Get the coordinate of Lithum ions' coordinates
Li=zeros(size(x,1)/n,3,m);
for i=1:m
Li(:,1,i)=x(2+i:n:end)';
Li(:,2,i)=y(2+i:n:end)';
Li(:,3,i)=z(2+i:n:end)';
end
% plot3(Li1(1,:),Li1(2,:),Li1(3,:),'.')
% xlim([0 1])
% ylim([0 1])
% zlim([0 1])
% xlabel('x')
% ylabel('y')
% zlabel('z')
for k=1:15
    for i=1:size(Li,1)-1
        for j=1:3
            if Li(i+1,j,k)-Li(i,j,k)>0.8
                Li(i+1:end,j,k)=Li(i+1:end,j,k)-1;
            end
            if Li(i,j,k)-Li(i+1,j,k)>0.8
                Li(i+1:end,j,k)=Li(i+1:end,j,k)+1;
            end
        end
    end
end
Li(:,1,:)=Li(:,1,:)*lattice(1,1);
Li(:,2,:)=Li(:,2,:)*lattice(2,2);
Li(:,3,:)=Li(:,3,:)*lattice(3,3);

%% Plot the trajectory of one Lithium ion, you can choose the ions by changing the third parameter of Li(*,*,*)
% figure
% plot3(Li(:,1,1),Li(:,2,1),Li(:,3,1))
% axis equal
% xlabel('x')
% ylabel('y')
% zlabel('z')
% hold on
% xlim([-5 5])
% ylim([-5 5])
% zlim([-5 5])
% %
% figure
% axis equal
% for i=1:size(Li1x,2)-1
% plot3(Li1(1,i),Li1(2,i),Li1(3,i),'b.');
% hold on
% % xlim([0 20])
% % ylim([-16 5])
% % zlim([3 20])
% pause(0.0001)
% end

%% Total MSD 
TMSD=zeros(size(Li,1)-1,1);
for t=1:size(Li,1)-1
    S=zeros(size(Li,1)-t+1,size(Li,3));
    for i=1:size(Li,1)-t+1
        for k=1:15
          S(i,k)=(Li(i,1,k)-Li(i+t-1,1,k))^2+(Li(i,2,k)-Li(i+t-1,2,k))^2+(Li(i,3,k)-Li(i+t-1,3,k))^2;
        end
    end
    MSD=mean(S,1);
    TMSD(t,1)=sum(MSD,2);
    if mod(t,1000)==0
        t
    end
end
%% A slower version of code to calculate the TMSD
% TMSD=zeros(size(Li,1)-1,1);
% for t=1:size(Li,1)-1
%     S=0;
%     for i=1:t-1
%     SD=(Li(i:t:size(Li,1)-t,:,:)-Li(i+t:t:size(Li,1),:,:)).^2;
%     MSD=mean(SD,1);
%     S=S+sum(sum(MSD));
%     end
%     TMSD(t,1)=S/(t-1);
%     if mod(t,1000)==0
%         t
%     end
% end
%% MSD from origin
OMSD=zeros(size(Li,1),1);
for t=1:size(Li,1)
    S=zeros(size(Li,3),1);
    for k=1:15
    S(k)=(Li(1,1,k)-Li(t,1,k))^2+(Li(1,2,k)-Li(t,2,k))^2+(Li(1,3,k)-Li(t,3,k))^2;
    end
    OMSD(t)=mean(S);
end
t=(1:size(OMSD,1))*2;
plot(t,OMSD)
hold on
%% Plot the result of TMSD
t=(1:size(TMSD,1))*2;
%plot(log(t),log(TMSD/15))
plot(t,TMSD/m)
hold off
xlabel('t(fs)')
ylabel('MSD(A^2)')
saveas(gcf,'MSDplot.jpg')
%%
% t=(1:size(TMSD,1))*2;
% plot(log(t(1:end)),log(TMSD/15))
% hold on
%%
% t=(1:size(TMSD,1))*2;
% plot(log(t(403:end-50)),diff(log(TMSD(403:end-49)/15))/2)
% plot(t(403:end-5000-200),diff(TMSD(403:end-4999-200)/15)/2)
% hold on
% line([8 12],[0 0],'Color','red','LineStyle','--')

%% Save the TMSD result
save 'TMSD.mat' TMSD
