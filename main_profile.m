clc
clear
close all
%%
[FileName,PathName] = uigetfile('*.dcm','Select the MATLAB code file');
filelist_dcm = dir(fullfile(PathName,'*.dcm'));
%%
dicom_information = dicominfo(fullfile(PathName,filelist_dcm(1).name));
Dicom3D = zeros(dicom_information.Rows,dicom_information.Columns,size(filelist_dcm,1));
%
names = {files.filelist_dcm}; %// get file names. Cell array of strings
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
alphamap('rampup'); grid on
% alphamap(.06 .* alphamap);

%% Profile Line 
imgs = dicom_data.dicom1;
figure(10), imshow(imgs,[])
h = imline;
pause
GetLinePosition = h.getPosition;
Coordi1 = GetLinePosition(2,:) - GetLinePosition(1,:);
Coordi2 = [1 0];
degree = CalRotationDegree(Coordi1,Coordi2);
imgs_align = imrotate(imgs, -1*degree);
figure(11), imshow(imgs_align,[]);

% [X,Y,I2,rect] = imcrop(dicom_data.dicom1)
figure(11)
[X,Y,I2,rect] = imcrop();
profile_linesum = sum(I2,1);
figure, plot(profile_linesum), grid on , title('Profile of user ROI')
xlswrite('ProfileLineSum.xlsx',profile_linesum)

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
