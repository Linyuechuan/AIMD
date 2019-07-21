%% 导入文本文件中的数据。
%load('TMSD.mat')
% %% 初始化变量。
% filename = '.\XDATCAR_fract.xyz';
% delimiter = ' ';
% 
% %% 每个文本行的格式:
% %   列2: 双精度值 (%f)
% %	列3: 双精度值 (%f)
% %   列4: 双精度值 (%f)
% % 有关详细信息，请参阅 TEXTSCAN 文档。
% formatSpec = '%*s%f%f%f%[^\n\r]';
% 
% %% 打开文本文件。
% fileID = fopen(filename,'r');
% 
% %% 根据格式读取数据列。
% % 该调用基于生成此代码所用的文件的结构。如果其他文件出现错误，请尝试通过导入工具重新生成代码。
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
% 
% %% 关闭文本文件。
% fclose(fileID);
% 
% %% 对无法导入的数据进行的后处理。
% % 在导入过程中未应用无法导入的数据的规则，因此不包括后处理代码。要生成适用于无法导入的数据的代码，请在文件中选择无法导入的元胞，然后重新生成脚本。
% 
% %% 将导入的数组分配给列变量名称
% x = dataArray{:, 1};
% y = dataArray{:, 2};
% z = dataArray{:, 3};
% 
% 
% %% 清除临时变量
% clearvars filename delimiter formatSpec fileID dataArray ans;
% %%
% filename = '.\lattice.vectors';
% delimiter = ' ';
% 
% %% 将数据列作为文本读取:
% % 有关详细信息，请参阅 TEXTSCAN 文档。
% formatSpec = '%s%s%s%[^\n\r]';
% 
% %% 打开文本文件。
% fileID = fopen(filename,'r');
% 
% %% 根据格式读取数据列。
% % 该调用基于生成此代码所用的文件的结构。如果其他文件出现错误，请尝试通过导入工具重新生成代码。
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string',  'ReturnOnError', false);
% 
% %% 关闭文本文件。
% fclose(fileID);
% 
% %% 将包含数值文本的列内容转换为数值。
% % 将非数值文本替换为 NaN。
% raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
% for col=1:length(dataArray)-1
%     raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
% end
% numericData = NaN(size(dataArray{1},1),size(dataArray,2));
% 
% for col=[1,2,3]
%     % 将输入元胞数组中的文本转换为数值。已将非数值文本替换为 NaN。
%     rawData = dataArray{col};
%     for row=1:size(rawData, 1)
%         % 创建正则表达式以检测并删除非数值前缀和后缀。
%         regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
%         try
%             result = regexp(rawData(row), regexstr, 'names');
%             numbers = result.numbers;
%             
%             % 在非千位位置中检测到逗号。
%             invalidThousandsSeparator = false;
%             if numbers.contains(',')
%                 thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
%                 if isempty(regexp(numbers, thousandsRegExp, 'once'))
%                     numbers = NaN;
%                     invalidThousandsSeparator = true;
%                 end
%             end
%             % 将数值文本转换为数值。
%             if ~invalidThousandsSeparator
%                 numbers = textscan(char(strrep(numbers, ',', '')), '%f');
%                 numericData(row, col) = numbers{1};
%                 raw{row, col} = numbers{1};
%             end
%         catch
%             raw{row, col} = rawData{row};
%         end
%     end
% end
% 
% 
% %% 创建输出变量
% lattice = cell2mat(raw);
% %% 清除临时变量
% clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp;
%% Data process

%%
Li=zeros(size(x,1)/33,3,15);
for i=1:15
Li(:,1,i)=x(2+i:33:end)';
Li(:,2,i)=y(2+i:33:end)';
Li(:,3,i)=z(2+i:33:end)';
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

%%

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

%%
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
%%
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
%%
t=(1:size(TMSD,1))*2;
%plot(log(t),log(TMSD/15))
plot(t,TMSD/15)
hold off
xlabel('t(fs)')
ylabel('MSD(A^2)')
%saveas(gcf,'MSDplot.jpg')
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

%%
%save 'TMSD.mat' TMSD
