for i=1:Npc
    GM1vn(:,i)=GM(:,i)/(sqrt(var(GM(:,i))));
end

GMz=GM;
GMz(GM1vn<2.5)=0;
GMzbin=GMz;
GMzbin(GMz~=0)=1;

for j=1:Npc
parfor i=1:S1(4)
Rm(i,:,j)=R(i,:).*GMzbin(:,j)';
end
j
end

TSroi=sum(Rm,2);

for j=1:Npc
parfor i=1:S1(4)
Rmap(i,:,j)=R(i,:).*GMz(:,j)';
end
j
end

TSzmap=sum(Rmap,2);

for j=1:Npc    
    TSmum(:,j)=squeeze(Rm(:,:,j)*pinv(icasig(j,:)));
end

for j=1:Npc
TSzum(:,j)=Rmap(:,:,j)*pinv(icasig(j,:));
end

n=30
figure 
plot(TS(:,n)/sqrt(var(TS(:,n))),'b')
hold on
plot(TSroi(:,1,n)/sqrt(var(TSroi(:,1,n))),'r')
plot(TSmum(:,n)/sqrt(var(TSmum(:,n))),'g')
plot(TSzum(:,n)/sqrt(var(TSzum(:,n))),'m')