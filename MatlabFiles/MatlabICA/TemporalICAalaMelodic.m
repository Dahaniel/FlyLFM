% This script performs PCA and spatial ICA in a manner similar to melodic from FSL 

clear all

% Open Data
[FileName,PathName] = uigetfile('*.nii','Select the Nifti file');
file=strcat(PathName,FileName)
B=MRIread(file);
D=double(B.vol);
clear B

% Reshape as a space*time 2D matrix 
S1=size(D);
parfor i=1:S1(4)
R(i,:)=reshape(D(:,:,:,i),[1,S1(1)*S1(2)*S1(3)]);
end
clear D


% Demean
S2=size(R);
parfor i=1:S2(2)
    Rm(i)=mean(R(:,i));
    R(:,i)=R(:,i)-Rm(i);
end

P=prctile(reshape(R,size(R,1)*size(R,2),1),90);
R1=R.*(10000/P);
clear R
R=R1;

% % %simple std norm (choose between this and Smith lines below)
%   stddevs=max(std(R),0.01);  
%   R=R./repmat(stddevs,size(R,1),1);  % var-norm

%% Variance normalisation ala melodic
[uu,ss,vv]=nets_svds(R,60); % initial SVD to the top 30 components (arbitrary number fixed in MELODIC)
vv(abs(vv)<2.3*std(vv(:)))=0;
%vv(abs(vv)<2.3*std(vv(:)))=0;
stddevs=max(std(R-uu*ss*vv'),1);  % subtract main parts of top components from data to get normalisation
R=R./repmat(stddevs,size(R,1),1);  % var-norm

Rt=R';
%SVD
Npc=40;
[u,s,v]=nets_svds(Rt,Npc);

% save PCA maps
DE=s*u';
for i=1:Npc
Dpca(:,:,:,i)=reshape(DE(i,:),[S1(1),S1(2),S1(3)]);
end
out4.vol = Dpca;
err = MRIwrite(out4,strcat(file(1:size(file,2)-4),'PCAzthreshe.nii'));


%% ICA
[icasig, A, W] = fastica (v','approach','symm','epsilon', 0.01,'maxNumIterations',3000);

% form back ica maps
GM=u*s*A;
GMv=GM./repmat(std(GM),size(GM,1),1);
%Correct sign so that mean of the positive side is larger than the mean of
%the negative side after zscoring

GMzp=GMv-2;
GMzp(GMzp<0)=0;
GMzpm=mean(GMzp);
GMzn=GMv+2;
GMzn(GMzn>0)=0;
GMznm=mean(GMzn);
GMs=GM.*repmat(sign(GMzpm+GMznm),size(GM,1),1); 

TS=icasig';
TSs=TS.*repmat(sign(GMzpm+GMznm),size(TS,1),1);

%reorder maps by variance
[varo,Order]=sort(var(TS));
TSo=TSs(:,Order(Npc:-1:1));
GMo=GMs(:,Order(Npc:-1:1));

% Reform volumes
for i=1:Npc
Dica(:,:,:,i)=reshape(GMo(:,i),[S1(1),S1(2),S1(3)]);
end

% Save ICA maps and time series
out.vol = Dica;
err = MRIwrite(out,strcat(file(1:size(file,2)-4),'temp40Smith23IC.nii'));

save(strcat(file(1:size(file,2)-4),'temp40Smith23TS'),'TSo')

% Next step is opening the maps and time series in an ipython notebook for
% manual sorting

