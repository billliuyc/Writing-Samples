// Bill Yuanchen Liu
// Dec. 13, 2018
// General Linear Modeling, Dr. Shenyang Guo

// Priliminary data exploration and cleaning
clear
cd "D:\Dropbox\Dropbox\Study\6910 GLM\Final"
use "D:\Dropbox\Dropbox\Study\6910 GLM\Final\Final\GSS2014.DTA"

keep id chldidel sex rincom06 degree race natchld sibs hapmar
save FinalCleanedDataset, replace
use FinalCleanedDataset

tab chldidel
generate ideal = chldidel
drop if ideal == 8
tab ideal, mi
drop if ideal == .i
tab ideal, mi

tab sex
generate sex2 = sex
tab sex2, mi

tab rincom06
generate income2 = rincom06
tab income2, mi
drop if income2 == .i
drop if income2 == .a
tab income2, mi

tab degree
generate degree2 = degree
tab degree2, mi

tab race
generate race2 = race
tab race2, mi

tab natchld
generate childcare = natchld
tab childcare, mi
drop if childcare == .d
tab childcare, mi

tab sibs
generate siblings = sibs
tab siblings, mi
drop if siblings == .n
tab siblings, mi

tab hapmar
generate happiness = hapmar
recode happiness (3=1) (2=2) (1=3)
tab happiness, mi
drop if happiness == .d
drop if happiness == .i
tab happiness, mi

// Descriptives
tab ideal, mi // (count variable, 0-6)
tab sex2, mi // (binary variable, 1,2)
tab income2, mi // (ordered categorical of 25, 1-25)
tab degree2, mi // (categorical, 0-4)
tab race2, mi // (categorical, 1-3)
tab childcare, mi // (ordered categorical, 1-3)
tab siblings, mi // (count variable, 0-16)
tab happiness, mi // (categorical, 1-3)
sum ideal sex2 income2 degree2 race2 childcare siblings happiness

histogram ideal, normal xtitle("Ideal number of children") title("Distribution of the Ideal Variable")
graph export "D:\Dropbox\Dropbox\Study\6910 GLM\Final\Graph 1.png", as(png) replace
sum ideal, d // Interpret overdispersion metric

// Univariate Poisson model
poisson ideal
mgen, pr(0/6) meanpred stub(psn)
label var psnobeq "Observed"
label var psnpreq "Poisson Prediction"
label var psnval "Ideal number of children"
graph twoway connected psnobeq psnpreq psnval, ytitle("Probability") ylabel(0(.1).7, gmax) xlabel(0/6) msym(O Th)
graph export "D:\Dropbox\Dropbox\Study\6910 GLM\Final\Graph 2.png", as(png) replace

// Running Poisson regression and multivariate negative binomial regression
poisson ideal i.sex2 income2 i.degree2 i.race2 i.childcare siblings i.happiness
estimate store prm
nbreg ideal i.sex2 income2 i.degree2 i.race2 i.childcare siblings i.happiness
estimate store negbin

// Create an estimate table
estimate table prm negbin, b(%9.3f) se p(%9.3f) eform

// Re-running appropriate model using vce(robust)
poisson ideal i.sex2 income2 i.degree2 i.race2 i.childcare siblings i.happiness, vce(robust)

// IRRS and percentage
listcoef, help
listcoef, percent help

// AMEs
mchange, pr(0/6)

// Add interaction term to test for moderation
poisson ideal i.sex2 income2 i.degree2 i.race2 i.childcare siblings i.happiness c.siblings##i.happiness, vce(robust)

// Test for joint effect of multiple independent variables
correlate sex2 income2 degree2 race2
correlate siblings happiness
regress ideal i.sex2 income2 i.degree2 i.race2 i.childcare siblings i.happiness
estat vif

// Present final results
margins i.race2, at(degree2=(0(1)4)) atmeans noatlegend
marginsplot, title("The Impact of Degree on Ideal Number of Children among Races") ytitle("Predicted ideal number of children")
graph export "D:\Dropbox\Dropbox\Study\6910 GLM\Final\Graph 3.png", as(png) replace
