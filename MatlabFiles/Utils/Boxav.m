
% open Data
[FileName,PathName] = uigetfile('*.nii','Select the Nifti file');
file=strcat(PathName,FileName)

D=MRIread(file);
Data=D.vol;

S=size(Data);

Ds=zeros(floor(S(1)/2), floor(S(2)/2),S(3),S(4));
for i=1:S(3)
    for j=1:S(4)
        X=squeeze(Data(1:floor(S(1)/2)*2,1:floor(S(2)/2)*2,i,j));
        Xs=reshape(sum(sum(reshape(X, 2, floor(S(1)/2), 2, floor(S(2)/2)), 1), 3), floor(S(1)/2), floor(S(2)/2));
        Ds(:,:,i,j)=Xs;
    end
    i
end


out.vol=Ds;
err = MRIwrite(out,strcat(file(1:size(file,2)-4),'boxav.nii'));
