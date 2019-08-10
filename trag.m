filename = 'XDATCAR';
delimiter = ' ';
startRow = 7;
endRow = 7;
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n')
fclose(fileID);
nLi = dataArray{1, 1};
nMg=dataArray{1,2};
nS=dataArray{1,3};
n=nLi+nMg+nS+2;
clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;
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
Li=zeros(size(x,1)/n,3,nLi);
for i=1:nLi
Li(:,1,i)=x(2+i:n:end)';
Li(:,2,i)=y(2+i:n:end)';
Li(:,3,i)=z(2+i:n:end)';
end
Mg=zeros(size(x,1)/n,3,nMg);
for i=1:nMg
Mg(:,1,i)=x(nLi+i:n:end)';
Mg(:,2,i)=y(nLi+i:n:end)';
Mg(:,3,i)=z(nLi+i:n:end)';
end
S=zeros(size(x,1)/n,3,nS);
for i=1:nS
S(:,1,i)=x(nLi+nMg+i:n:end)';
S(:,2,i)=y(nLi+nMg+i:n:end)';
S(:,3,i)=z(nLi+nMg+i:n:end)';
end
figure 
for i=1:nLi
plot3(Li(:,1,i)*lattice(1,1),Li(:,2,i)*lattice(2,2),Li(:,3,i)*lattice(3,3),'r.','MarkerSize',2)
hold on
xlabel('x')
ylabel('y')
zlabel('z')
end
% for i=1:nMg
% plot3(Mg(:,1,i)*lattice(1,1),Mg(:,2,i)*lattice(2,2),Mg(:,3,i)*lattice(3,3),'b.','MarkerSize',2)
% hold on
% xlabel('x')
% ylabel('y')
% zlabel('z')
% end
% startpoint=1;
% for i=1:nS
% plot3(S(startpoint:end,1,i)*lattice(1,1),S(startpoint:end,2,i)*lattice(2,2),S(startpoint:end,3,i)*lattice(3,3),'g.','MarkerSize',2)
% hold on
% xlabel('x')
% ylabel('y')
% zlabel('z')
% end
axis equal
saveas(gcf,'trag.fig')
hold off