%generate fake data
dir='test2';

n=20;
sig=1.5; 
m=4;
b=3;

% forward model with 2 parameters
x = linspace(1,n,n)';
y = b + m*x + sig*randn(n,1);

%even the error bars are fake!
data=[x y sig*ones(size(x))];
save([dir '/line.dat'],'data','-ASCII')

%save parameters for comparison with the results
realvals=[b m];
save([dir '/realvals.dat'],'realvals','-ASCII')


figure(1),clf,plot(x,y,'r.'), hold on
%%

%plot best-fitting model, once it's been computed
load([dir '/meanmodel.dat']);
plot(x,meanmodel(:,1),'-b')
