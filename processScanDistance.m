
clear all;
clc;

maxDistance=20;ve reading

midThreshUpper=0.5; 
midThreshLower=-midThreshUpper; 
windowSize=3;
interpRes=1; 

centerDistance=10.3;
zDelta=0.1;
rawData=load('ponds.txt');
rawData(rawData<0)=0; 
indeces=find(rawData==9999);


r(1,:)=rawData(1:indeces(1));
for i=2:1:size(indeces,1)
   r(i,:)=rawData(indeces(i-1)+1:indeces(i)); 
end

r(:,end)=[]; 

r=centerDistance-r; 
r(r>maxDistance)=NaN; 
r(r<minDistance)=NaN; 

midThreshUpperIdx=r>midThreshLower;
midThreshLowerIdx=r<midThreshUpper;
midThreshIdx=midThreshUpperIdx.*midThreshLowerIdx;
r(midThreshIdx==1)=NaN;


theta=360:-360/size(r,2):0;
theta(end)=[];
theta=repmat(theta,[size(r,1) 1]);

theta=theta*pi/180;


z=0:zDelta:size(r,1)*zDelta;
z(end)=[];
z=z';
z=repmat(z,[1,size(r,2)]);

[x,y,z]=pol2cart(theta,r,z);


for i=1:1:size(x,1)
   if sum(isnan(x(i,:)))==size(x,2)
      x(i:end,:)=[];
      y(i:end,:)=[];
      z(i:end,:)=[];
    break;
   end
end

for i=1:1:size(x,1)
   latestValueIdx=find(~isnan(x(i,:)),1,'first');
   latestX=x(i,latestValueIdx);
   latestY=y(i,latestValueIdx);
   for j=1:1:size(x,2)
       if isnan(x(i,j))==0
          latestX=x(i,j); 
          latestY=y(i,j);
       else
           x(i,j)=latestX;
           y(i,j)=latestY;
       end
       
   end
end

interpIdx=1:interpRes:size(x,1);
xInterp=x(interpIdx,:);
yInterp=y(interpIdx,:);
zInterp=z(interpIdx,:);




h=fspecial('average',windowSize); 

xInterp=padarray(xInterp,[0, windowSize],'symmetric'); 
yInterp=padarray(yInterp,[0, windowSize],'symmetric'); 
xInterp=filter2(h,xInterp);
yInterp=filter2(h,yInterp); 
xInterp=xInterp(:,windowSize:end-windowSize-1);

xInterp(:,end)=xInterp(:,1);
yInterp(:,end)=yInterp(:,1);
zInterp(:,end)=zInterp(:,1);


xTop=mean(xInterp(end,:));
yTop=mean(yInterp(end,:));
xInterp(end+1,:)=xTop;
yInterp(end+1,:)=yTop;
zInterp(end+1,:)=zInterp(end,1)-zInterp(end-1,1)+zInterp(end,1);

%surf(xInterp,yInterp,zInterp);
plot3(xInterp,yInterp,zInterp,'.b'); 

surf2stl('farmer.stl',xInterp,yInterp,zInterp); 