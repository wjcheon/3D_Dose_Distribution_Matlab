clc
clear
close all
% Author : Wonjoong Jason Cheon,
% Date: 2017-04-11
% Purpose : Load dicom files such as RTDose, CT image ..and Show as 3D
%          distribution
% Version: 1.1
%%
[FileName,PathName] = uigetfile({'*.dcm';'*.mat'},'Select the MATLAB code file');
filetype = FileName(end-2:end);
filelist = dir(fullfile(PathName,['*.' filetype]));

%%
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
end

%%
option_colormap = {'rampup','rampdown','vup','vdown','increase','decrease','spin'};
h = vol3d('cdata',DataSet3D,'texture','3D');
view(3);
axis tight;  daspect([1 1 0.3]) , colormap('jet')
alphamap('rampup'); grid on, title('3D DOSE DISTRIBUTION')
% alphamap(.6 .* alphamap);

%%

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

%%

