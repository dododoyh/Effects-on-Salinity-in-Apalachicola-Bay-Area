/*Time Series analysis for the effects on salinity using ARIMA model*/

/*First, load the dataset, transform the River variable by logarithm and 
the rainfall variable by square root and split data into train and test data*/

options missing=0;
data sal;
infile "/courses/d452b5e5ba27fe300/HW5p1.dat" firstobs=2;
input Level Salin x y;
if _N_>375 then Salin2=Salin;
if _N_<=375 then Salin1=Salin;
Rain=sqrt(x);
River=log(y);
keep Level Salin Rain River Salin2 Salin1;
run;
proc print data=sal(firstobs=375);
run;

/*Fit an ARIMA model to salinity Yt alone and Check the model diagnostic plots*/

proc arima data=sal;
identify var=Salin2(1) nlag=50;
estimate p=1 q=2 noint;
forecast out=for1 back=0 lead=20 noprint;
run;


/*Fit the regression-time series model for the salinity and Check the model diagnostic plots*/

proc arima data=sal;
identify var=Salin2(1) crosscorr=(Level(1) Rain(1) River(1));
estimate p=2 input=(Level Rain River) noint;
forecast out=for2 back=0 lead=20;
run;

/*Compute 20 forecasts for the salinity from both models*/

data c1;
set for1(firstobs=376);
forecasty=forecast;
keep forecasty;
run;
data c2;
set for2(firstobs=376);
keep forecast;
run;
data c3;
set sal(firstobs=376);
keep Salin2;
run;
data c4;
merge c1 c2 c3;
t=_N_;
run;
proc gplot data=c4;
plot Salin2*t forecasty*t forecast*t/overlay;
symbol1 c=black i=join v=star;
symbol2 c=red i=join v=diamond;
symbol3 c=green i=join v=circle;
run;

