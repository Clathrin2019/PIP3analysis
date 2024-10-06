% Plot intensity profile heatmap for a folder of images
% The heatmap colormap uses 'GreenFireBlue' from Fiji, make sure the
% colormap file exist in the current folder (line 12 and 25).
% 
% Zhengyang An 20241006
%

%% plot heatmap

clc
clear
folder = uigetdir();
[~,GreenFireBlue] = imread(GreenFireBlue.tif); % colormap from FIJI

channel = 'Ch2'; % channel for intensity profile
n = 1000; % divide cell boundary to 1000 parts/values

% calculate intensity profile
IP = IntensityProfile(folder,channel, n);
disp('All done.')

% plot heatmap
f = figure('Position',[1341 579 600 540]);
imagesc(IP(:,1:60),[0,4]); % 60 cells
colormap(GreenFireBlue)

title('Individual Cells','FontWeight','normal','FontName','Arial')
ylabel('Relative Position','FontName','Arial');
yticklabels([])
xticklabels([])
set(gca,'FontSize',24)

% save image
filename = [folder filesep 'Intensity Profile ' channel];
exportgraphics(gcf,[filename '.pdf'],...
    'ContentType','vector',...
    'BackgroundColor','none')
saveas(gcf,[filename '.fig'])

%% pattern std quantification
for i = 1:width(IP)
    STD(i) = std(IP(:,i)); 
end
writematrix(STD(1:end),fullfile(folder, 'std.csv'));


%% colorbar
figure('Position',[1400 200 80 550])
data = 4.5:-0.005:0;
imagesc(data',[0,4.5]);
colormap(GreenFireBlue)
ax = gca;

set(gca,'YAxisLocation','right')
set(ax,'TickLength',[0 0])
set(gca,'LineWidth',0.1)
set(ax,'XColor','k')
yticks([1 301 601 901])
xticks([])
box on

yticklabels({'4.5' '3.0' '1.5' '0'});
set(gca,'FontSize',30)

%%
function IP = IntensityProfile(folder,channel, npoints)
% Calculate intensity profile for all images in a given 'folder';
% Divide cell boundary to 'npoints';
% Perform intensity normalization by dividing the mean intensity of
% boundary region.
% 
% Zhengyang An 20210909
%
    
    Contents = dir(fullfile(folder,'*'));
    subFolders = setdiff({Contents([Contents.isdir]).name},{'.','..'});
    subFolders = natsortfiles(subFolders);
    
    % read .csv files that contain intensity profile values
    count = 0;
    c = [];
    for i = 1:numel(subFolders)
        csv = dir(fullfile(folder,subFolders{i},'IntensityProfile','*.csv'));
        if ~isempty(csv)
            number = 1; % number of cells
            csvFile = {csv.name};
            path = csv.folder;
            for k = 1:numel(csvFile)
                if contains(csvFile{k}, ['IntensityProfile_' channel])
                    count = count+1;
                    csvPath = [path filesep csvFile{k}];
                    T = readmatrix(csvPath,'NumHeaderLines',1);
                    c{count} = T(:,2);
                    % Normalization
                    meanInt(count) = mean(c{count});
                    c{count} = c{count}./meanInt(count);
                    number = number+1;
                end
            end
        else
            message = ['...No intensity profile found in [' subFolders{i} '].'];
            disp(message);
        end
    end

    % interpolation
    c1 = zeros(npoints, count);
    for i = 1:count
        x = 1:length(c{i});
        xx = linspace(1,length(c{i}),npoints);
        c1(:,i) = interp1(x,c{i},xx);
    end
    
    IP = c1;
end
