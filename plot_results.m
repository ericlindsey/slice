%load model outputs
dir='test1';
data=load([dir '/line.dat']);
load([dir '/meanmodel.dat']);
load([dir '/axis_scales.dat']);
load([dir '/margs1D.dat']);
load([dir '/means_stds.dat']);
load([dir '/marg2d21.dat']);
load([dir '/realvals.dat']);

%plot data / model fit
figure(1),clf
plot(data(:,1),data(:,2),'b.','markersize',15 ), hold on
plot(data(:,1),meanmodel,'r','linewidth',2)
%'true' model as dotted black line
plot(data(:,1),realvals(1)+realvals(2)*data(:,1),'--k')
legend('data','model','"true" value','location','northwest')
set(gca,'fontsize',14)
xlabel('x')
ylabel('y') 

%plot 1D marginal pdfs, and means / uncertainties
figure(2),clf
subplot(2,1,1)
plot(axis_scales(:,1),margs1D(:,1))
xlim([min(axis_scales(:,1)) max(axis_scales(:,1))])
%mean as tall red line, 1-sigma error bars as short red lines
line([means_stds(1,1) means_stds(1,1)], ylim,'color','r')
line([means_stds(1,1)-means_stds(1,2) means_stds(1,1)-means_stds(1,2)],...
  ylim/2,'color','r')
line([means_stds(1,1)+means_stds(1,2) means_stds(1,1)+means_stds(1,2)],...
  ylim/2,'color','r')
%'true' value as a black line
line([realvals(1),realvals(1)],ylim,'color','k')
xlabel('intercept')
set(gca,'fontsize',14)

subplot(2,1,2)
plot(axis_scales(:,2),margs1D(:,2))
xlim([min(axis_scales(:,2)) max(axis_scales(:,2))])
%mean as tall red line, 1-sigma error bars as short red lines
line([means_stds(2,1) means_stds(2,1)], ylim,'color','r')
line([means_stds(2,1)-means_stds(2,2) means_stds(2,1)-means_stds(2,2)],...
  ylim/2,'color','r')
line([means_stds(2,1)+means_stds(2,2) means_stds(2,1)+means_stds(2,2)],...
  ylim/2,'color','r')
%'true' value as a black line
line([realvals(2),realvals(2)],ylim,'color','k')
xlabel('slope')
set(gca,'fontsize',14)

%contour plot 2D marginal pdf
figure(3),clf
contour(axis_scales(:,1),axis_scales(:,2),marg2d21,3,'color','b'),hold on
%mean and 1D uncertainties as red crosshairs
line([means_stds(1,1)+means_stds(1,2),means_stds(1,1)-means_stds(1,2)],...
  [means_stds(2,1),means_stds(2,1)],'color','r')
line([means_stds(1,1),means_stds(1,1)],...
  [means_stds(2,1)+means_stds(2,2),means_stds(2,1)-means_stds(2,2)],'color','r')
%'true' value as a black dot
plot(realvals(1),realvals(2),'k.')
xlabel('intercept')
ylabel('slope')
xlim([min(axis_scales(:,1)) max(axis_scales(:,1))])
ylim([min(axis_scales(:,2)) max(axis_scales(:,2))])
set(gca,'fontsize',14)
