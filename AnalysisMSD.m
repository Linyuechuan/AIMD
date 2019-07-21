
function [D,RSD]=AnalysisMSD(s,d,dt,N)
dir1=['./' s '/TMSD.mat'];
dir2=['./' s '/fitrange.mat'];
load(dir1);
load(dir2);
MSD=TMSD/N;
%%
t=(fitrange(1)+1:fitrange(2))*dt;
f=fit(t',MSD(fitrange(1)+1:fitrange(2)),'poly1');
t=(1:size(MSD,1))*dt;
plot(t,MSD);
hold on
plot(f)
xlim([0 inf])
ylim([0 inf])
xlabel('Time (fs)')
ylabel('MSD (A^2)')
saveas(gcf,s)
saveas(gcf,[s,'.jpg'])
hold off
D=f.p1/2/d/10^(5);
Nhoop=max(TMSD)/(2.77^2);
RSD=(3.43/sqrt(Nhoop)+0.04);
end