clear all
clc
close all hidden                      %Close all windows if opened

for p=1:79
    img=imread(strcat(int2str(p),'.jpg'));          %Reading an image file
    [x y z]=size(img);                 %image size
    per=500/x;
    img=imresize(img,per);              %resizing image for better noise removal function
    [x y z]=size(img) ;                %x y z get oerwrite

    gray_img=rgb2gray(img);
    Edge=edge(gray_img,'sobel');


    %subplot(2,2,1)
    %imshow(img);
    % title('Original Resized Image');
 
     orig_img=img;
 
     img=double(img);                    %Converting image in double format
                                     %Calculating width,height and RGB components of the image
 
     %RGB cimponent of image
 
     R=img(:,:,1);                     
     G=img(:,:,2);
     B=img(:,:,3);
 
 
 
     %%%%%%%%%%%%%%%%%%%%LIGHTING COMPENSATION ALGO
 
     %converting image to YCbCr fort
     YCbCr=rgb2ycbcr(img);
     %subplot(2,2,2)
     %imshow(YCbCr);
     %title('YCbCr');
     Y=YCbCr(:,:,1);                 
 
     %normalize Y compponent
     minY=min(min(Y));
     maxY=max(max(Y));
     YEye=Y;
     Yavg=sum(sum(Y))/(x*y);
 
     if (Yavg<64)
         T=1.4;
     elseif (Yavg>192)
         T=0.6;
     else
         T=1;
     end
 
     RI=R.^T;
     GI=G.^T;
 
 
 
     img=zeros(x,y,3);
     img(:,:,1)=RI;
     img(:,:,2)=GI;
     img(:,:,3)=B;
 
 
     %subplot(2,2,3)
     %imshow(img/255);
     %title('After Light Compensation');

     %%%%%%%%%%%%%%%%%%%%%%%%%SKIN EXTRACTION ALGO
 
     Cr=YCbCr(:,:,3);
 
     bw=zeros(x,y);
     
 	I=img;
 	for i = 1:size(I,1)
 	for j = 1:size(I,2)
 	R = I(i,j,1);
 	G = I(i,j,2);
 	B = I(i,j,3);
 
 	if(R > 95 && G > 50 && B > 20)
 	v = [R,G,B];
 	if((max(v) - min(v)) > 15)
 	if(abs(R-G) > 15 && R > G && R > B)
 
 	%it is a skin
 	bw(i,j) = 1;
 	end
 	end
 	end
 	end
 	end
 
    % subplot(2,2,4)
    % imshow(bw);
    % title('Skin Region');
 
     % pause
     %%%%%%%%%%%%NOISE REMOVAL
    % figure, subplot(2,2,1)
    % imshow(bw)
    % title('Noisy Skin Region ');
 
 
     se=strel('disk',3);
     bwn=imerode(bw,se);
     subplot(2,2,2)
     imshow(bwn)
     title('Eroded Skin Region');
 
     bwn=~bwn;
     bwn=bwareaopen(bwn, 500);             %removing black areas of area<1000
     bwn=~bwn;
    % subplot(2,2,3)
    % imshow(bwn)
     %title('Removed Black Region(<500)');
 
 
     bwn = bwareaopen(bwn, 500);          %removing white areas of area<3000
     %subplot(2,2,4)
    % imshow(bwn)
    % title('Removed White Region(<500)');
 
     % pause
     
 
     %%%%%%%%%%%%%%%%%%%%%FINDING SKIN COLOR(Faces) WHITE AREAS
     label = bwlabel(bwn,8);                    %give number to all the white areas
      %figure, subplot(1,2,1);
      %imshow(label)
      impixelinfo;
     % title('bwlabel');
  
 
     rgb=label2rgb(label);                    %give diffrent colour th diffren area
     % subplot(1,2,2);
     % imshow(rgb)
     % title('colour');
 
 
     BB  = regionprops(label, 'BoundingBox');  %corners of the box
     bboxes= cat(1, BB.BoundingBox);
     lenRegions=size(bboxes,1);            %total ROI
 
     BA=regionprops(label,'Area');
     area=cat(1,BA.Area);
 
     Final=orig_img;
 
     % pause
     for i=1:lenRegions
 
         areacurr=area(i);
 
         % get current region's bounding box
         bwcurrent=zeros(x,y);
         for l=1:x
             for m=1:y
                 if (label(l,m)==i)
                     bwcurrent(l,m)=1;
                 end
             end
         end
         se=strel('disk',15);
         bwcurrent=imdilate(bwcurrent,se);
 
 
         BB  = regionprops(bwcurrent, 'BoundingBox','Eccentricity');  %corners of the box
         eccecntricity=BB.Eccentricity;
     %     disp(eccecntricity)
 
         bboxes= cat(1, BB.BoundingBox);
 
         CurBox=bboxes;
         XStart=CurBox(1);
         YStart=CurBox(2);
         XEnd=CurBox(3);
         YEnd=CurBox(4);
         X=XEnd-XStart;
         Y=YEnd-YStart;
         % crop current region
         rangeY=int32(YStart):int32(YStart+YEnd-1);
         rangeX= int32(XStart):int32(XStart+XEnd-1);
 
         sizx=size(rangeX);
         sizy=size(rangeY);
         ratio2=sizy(2)/sizx(2)
 
     %     ratio=X/Y
         if ratio2>0.8 && ratio2<2
             Final=insertShape(Final,'rectangle',BB.BoundingBox,'Color','green','LineWidth',3);
         end
 
 
     end
 
     %figure,imshow(Final)
     imwrite(Final,strcat('output2/',int2str(p),'.jpg'));
end

