
[FileName,PathName] = uigetfile('*.nii','Select the Nifti file','/home/sophie/Desktop/');
file=strcat(PathName,FileName)
B=MRIread(file);
D=B.vol;
S=size(D);

% Make stimulus
%Tvid=T(Initvid:Endvid);
Tvid=T;
Fr=100;
Flashes=zeros(size(Tvid));
Odor=zeros(size(Tvid));

% for j=1:size(Tvid)
%     for (i=1:8)
%     if (Tvid(j)>(10+(i-1)*4+j*0.003/Fr) && Tvid(j)<(12+(i-1)*4+j*0.003/Fr))
%         Flashes(j)=1;
%     end
% end
% end

% 
for j=1:size(Tvid)
    for (i=1:3)
    if (Tvid(j)>(12+(i-1)*7+j*0.003/Fr) && Tvid(j)<(14+(i-1)*7)+j*0.003/Fr)
        Odor(j)=1;
    end
end
end



Drgb=zeros(size(D,1),size(D,2),size(D,3),3);
for i=1:3
    Drgb(:,:,:,i)=D;
end

for i=1:size(D,3)
    for j=5:15
        for k=185:195
            if Flashes(i)==1
                Drgb(j,k,i,1)=128;
                Drgb(j,k,i,2)=0;
                Drgb(j,k,i,3)=128;
            elseif Odor(i)==1
                Drgb(j,k,i,1)=255;
                Drgb(j,k,i,2)=192;
                Drgb(j,k,i,3)=203;                
            end
        end
    end
end

out.vol=Drgb;
err = MRIwrite(out,strcat(file(1:size(file,2)-4),'wStim.nii'));