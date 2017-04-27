clc
clear
close all
% Author : Wonjoong Jason Cheon,
% Date: 2017-04-24
% Purpose : Load dicom files such as RTDose, CT image ..and Show as 3D
%          distribution
% Version: 1.2
% CTDI Ouput Date type : 32 bit (float) 
% 
%%
% [FileName,PathName] = uigetfile({'*.dcm';'*.mat';'*.raw'},'Select the MATLAB code file');
% filetype = FileName(end-2:end);
% filelist = dir(fullfile(PathName,['*.' filetype]));

%%
clc
clear 
close all 
filetype= 'raw';
if strcmp(filetype, 'dcm')
    dicom_information = dicominfo(fullfile(PathName,filelist(1).name));
    DataSet3D = zeros(dicom_information.Rows,dicom_information.Columns,size(filelist,1));
    %
    names = {filelist.name}; %// get file names. Cell array of strings
    numbers = regexp(names, '\d+(?=\.dcm)', 'match'); %// strings with numeric part of name
    numbers = str2double([numbers{:}]); %// convert from strings to numbers
    [~, ind] = sort(numbers); %// sort those numbers
    names_sorted = names(ind); %// apply that order to file names
    %
    for iter1 = 1: size(filelist,1)
        eval(sprintf('dicom_data.dicom%d = dicomread(fullfile(PathName,names_sorted{%d}));',iter1,iter1))
        eval(sprintf('DataSet3D(:,:,%d) = dicomread(fullfile(PathName,names_sorted{%d}));',iter1,iter1))
    end
    %
    sprintf('%d files were loaded !!!',iter1)
    
elseif strcmp(filetype,'mat')
    StrucrueData = load(fullfile(PathName,FileName));
    names = fieldnames(StrucrueData);
    DataSet3D = getfield(StrucrueData, names{1});
    DataSet3D = abs(DataSet3D - max(DataSet3D(:)));
    DataSet3D = DataSet3D(size(DataSet3D,1)/2,:,:);
elseif strcmp(filetype,'raw')
    addpath('LB_ReadData3D')
    addpath('LB_ReadData3D\raw')
    ReadData3D
    DataSet3D = data.volume;
end

%%
option_colormap = {'rampup','rampdown','vup','vdown','increase','decrease','spin'};
h = vol3d('cdata',DataSet3D,'texture','3D');
view(3);
axis tight;  daspect([1 1 1]) , colormap('jet')
alphamap('rampup'); grid on, title('3D DOSE DISTRIBUTION')
% alphamap(.6 .* alphamap);

%%
close all 
[sx,sy,sz] = size(DataSet3D);
figure(10)
for iter2 = 1: sz
   figure(10), imshow(squeeze(DataSet3D(:,:,iter2)),[])
   title(num2str(iter2))
%    pause(1.0)    % 1.0 √  
   drawnow
end
%%
selected_slice_number = 10;
 figure(10), subplot(1,3,1), imshow(squeeze(DataSet3D(:,:,selected_slice_number)),[])
 figure(10), subplot(1,3,2), imshow(squeeze(DataSet3D(:,selected_slice_number,:)),[])
 figure(10), subplot(1,3,3), imshow(squeeze(DataSet3D(selected_slice_number,:,:)),[])

%%
% for iter2 = 1: size(option_colormap,2)
%     figure(10+iter2),
%     vol3d('cdata',Dicom3D,'texture','3D');
%     view(3);
%     axis tight;  daspect([1 1 0.15])
%     alphamap(option_colormap{iter2}); grid on
%     title(option_colormap{iter2})
% %     disp(option_colormap{iter2})
% end

%% CTDI
imageSize = size(DataSet3D);
ci = [imageSize(1)/2, imageSize(2)/2, 80];     % center and radius of circle ([c_row, c_col, r])
[xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
mask = double((xx.^2 + yy.^2)<ci(3)^2);
croppedImage= DataSet3D(:,:,50).*mask;
imshow(croppedImage,[]), colormap(jet);

%
CTDI_Matrix = DataSet3D.*0;
figure(11), hold on, 
for iter_ctdi =  1: imageSize(3)
    CTDI_Matrix(:,:,iter_ctdi) = DataSet3D(:,:,iter_ctdi).*mask;
    imshow(CTDI_Matrix(:,:,iter_ctdi),[])
    title(num2str(iter_ctdi)), colormap(jet), drawnow
end
CTDI_Matrix_backup = CTDI_Matrix;
CTDI_Matrix(CTDI_Matrix==0) = [];
sum_CTDI_Matrix = sum(CTDI_Matrix);
NumberOfSlice = 100;     % [slice]
SliceThinkness = 1;      % [mm]
mean_CTDI_Matrix_perSlice = sum_CTDI_Matrix/(NumberOfSlice*SliceThinkness)

%%
close all
option_colormap = {'rampup','rampdown','vup','vdown','increase','decrease','spin'};
h = vol3d('cdata',CTDI_Matrix_backup,'texture','3D');
view(3);
axis tight;  daspect([1 1 1]) , colormap('jet')
alphamap('rampup'); grid on, title('3D DOSE DISTRIBUTION')
% alphamap(.6 .* alphamap);

