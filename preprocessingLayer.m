clc
clear all
close all
tic
datapath = 'E:\Dataset3_recapture\LcdDataset\original_dataset3\original_3_1'; %%input folder
imageformat = 'jpg';
files = dir([datapath '/' '*.' imageformat]);
filecount = size({files.name},2); % Total no of jpg files in that folder
filenames = {files.name};% all file names taken into a variable
%blockFolder = fullfile('E:\texturefeature_research\test'); %output folder destination name
 blockFolder = fullfile('E:\texturefeature_research\horizontal_dwt\orig_dwt_h'); %output folder destination name
 blockFolder1 = fullfile('E:\texturefeature_research\vertical_dwt\orig_dwt_v'); %output folder destination name
 blockFolder2 = fullfile('E:\texturefeature_research\diagonal_dwt\orig_dwt_d'); %output folder destination name
%filecount = 110; %%input images count to process
for q = 1:filecount
    f = fullfile(datapath,char(filenames(q)));
    img_rgb = imread(f);
% img_rgb = readimage(imds1,i);
    [r,c,o] = size(img_rgb);
    if(r > 1024 && c > 1024)
    q1 = 1023; % size of the crop box
    i3_start = abs(floor((r-q1)/2)); % or round instead of floor; using neither gives warning
    i3_stop = i3_start + q1;

    i4_start = abs(floor((c-q1)/2));
    i4_stop = i4_start + q1;

img_rgb = img_rgb(i3_start:i3_stop, i4_start:i4_stop, :);
elseif (r >1024 && c < 1024)
     q1 = 1023; % size of the crop box
    i3_start = abs(floor((r-q1)/2)); % or round instead of floor; using neither gives warning
    i3_stop = i3_start + q1;
    
    q2 = 511;
    i4_start = abs(floor((c-q2)/2));
    i4_stop = i4_start + q2;

img_rgb = img_rgb(i3_start:i3_stop, i4_start:i4_stop, :);
elseif (r <1024 && c > 1024)
    q1 = 511; % size of the crop box
    i3_start = abs(floor((r-q1)/2)); % or round instead of floor; using neither gives warning
    i3_stop = i3_start + q1;
    
    q2 = 1023;
    i4_start = abs(floor((c-q2)/2));
    i4_stop = i4_start + q2;
    img_rgb = img_rgb(i3_start:i3_stop, i4_start:i4_stop, :);

elseif (r <1024 && c < 1024 && r > 512 && c >512)
    q1 = 511; % size of the crop box
    i3_start = abs(floor((r-q1)/2)); % or round instead of floor; using neither gives warning
    i3_stop = i3_start + q1;
    
    q2 = 511;
    i4_start = abs(floor((c-q2)/2));
    i4_stop = i4_start + q2;
    img_rgb = img_rgb(i3_start:i3_stop, i4_start:i4_stop, :); 
    
    elseif(r< 512 && c < 512)
        q = q+1;
    end

  img_gray = rgb2gray(img_rgb);
  [mm, nn, ~] = size(img_gray);

 if mm == nn
 [cA,cH,cV,cD] = haart2(img_gray,1); %cA size will be 256
% %[cA2,cH2,cV2,cD2] = haart2(cA,1); %cA2 size will be 128
% %[cA3,cH3,cV3,cD3] = haart2(cA2,1); %cA3 size will be 64
% 
 else
     q = q+1;
 end
% 
% 
 %normal = mat2tiles(img_rgb,[512 512]);
% 
 CH = mat2tiles(cH,[256 256]);
 CV = mat2tiles(cV,[256 256]);
 CD = mat2tiles(cD,[256 256]);
% 

% [m,n,~ ]= size(normal);
 [m,n,~ ]= size(CH);
 [m1,n1,~ ]= size(CV);
 [m2,n2,~ ]= size(CD);

for x = 1:m
   for y = 1:n
      
      baseFileName = sprintf('%d_%d%d.jpg',q,x,y); % e.g. "1.png"  
      fullFileName = fullfile(blockFolder, baseFileName); % No need to worry about slashes now!
       
      imwrite(cell2mat(CH(x,y)), fullFileName);
      
   end
end



for x1 = 1:m1
   for y1 = 1:n1
      
      baseFileName1 = sprintf('%d_%d%d.jpg',q,x1,y1); % e.g. "1.png"  
      fullFileName1 = fullfile(blockFolder1, baseFileName1); % No need to worry about slashes now!
       
      imwrite(cell2mat(CV(x1,y1)), fullFileName1);
      
   end
end
% 
for x2 = 1:m2
   for y2 = 1:n2
      
      baseFileName2 = sprintf('%d_%d%d.jpg',q,x2,y2); % e.g. "1.png"  
      fullFileName2 = fullfile(blockFolder2, baseFileName2); % No need to worry about slashes now!
       
      imwrite(cell2mat(CD(x2,y2)), fullFileName2);
      
   end
end
d=sprintf("the number of image is %d",q);
         disp(d);
         
end

toc

%% checking the output results...

orig = rgb2gray(imread('E:\combine_cao\007.jpg'));
recap = rgb2gray(imread('E:\combine_cao\recapture_cao\3008.jpg'));

[r,c,o] = size(orig);
    
    q1 = 1023; % size of the crop box
    i3_start = abs(floor((r-q1)/2)); % or round instead of floor; using neither gives warning
    i3_stop = i3_start + q1;

    i4_start = abs(floor((c-q1)/2));
    i4_stop = i4_start + q1;

orig = orig(i3_start:i3_stop, i4_start:i4_stop, :);

[r,c,o] = size(recap);
    
    q1 = 2047; % size of the crop box
    i3_start = abs(floor((r-q1)/2)); % or round instead of floor; using neither gives warning
    i3_stop = i3_start + q1;

    i4_start = abs(floor((c-q1)/2));
    i4_stop = i4_start + q1;

recap = recap(i3_start:i3_stop, i4_start:i4_stop, :);

orig = medfilt2(orig);
recap = medfilt2(recap);

[cA,cH,cV,cD] = haart2(orig,1); %cA size will be 256
[cAr,cHr,cVr,cDr] = haart2(recap,1); %cA size will be 256

figure, imshow(orig);
figure, imshow(recap);
figure, imshow(cH);
figure, imshow(cV);
figure, imshow(cD);
figure, imshow(cHr);
figure, imshow(cVr);
figure, imshow(cDr);








