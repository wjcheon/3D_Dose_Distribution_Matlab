clc
clear
close all
% Author : Wonjoong Jason Cheon, 
% Date: 2017-04-11 
% Purpose : Load dicom files such as RTDose, CT image ..and Show as 3D
%          distribution
%%
[FileName,PathName] = uigetfile('*.dcm','Select the MATLAB code file');
filelist_dcm = dir(fullfile(PathName,'*.dcm'));
%%
dicom_information = dicominfo(fullfile(PathName,filelist_dcm(1).name));
Dicom3D = zeros(dicom_information.Rows,dicom_information.Columns,size(filelist_dcm,1));
%
names = {filelist_dcm.name}; %// get file names. Cell array of strings
numbers = regexp(names, '\d+(?=\.dcm)', 'match'); %// strings with numeric part of name
numbers = str2double([numbers{:}]); %// convert from strings to numbers
[~, ind] = sort(numbers); %// sort those numbers
names_sorted = names(ind); %// apply that order to file names
%
for iter1 = 1: size(filelist_dcm,1)
    eval(sprintf('dicom_data.dicom%d = dicomread(fullfile(PathName,names_sorted{%d}));',iter1,iter1))
    eval(sprintf('Dicom3D(:,:,%d) = dicomread(fullfile(PathName,names_sorted{%d}));',iter1,iter1))
end
%
sprintf('%d files were loaded !!!',iter1)

%%
option_colormap = {'rampup','rampdown','vup','vdown','increase','decrease','spin'};
h = vol3d('cdata',Dicom3D,'texture','3D');
view(3);
axis tight;  daspect([1 1 0.15])
alphamap('rampup'); grid on, title('3D DOSE DISTRIBUTION')
% alphamap(.06 .* alphamap);

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
