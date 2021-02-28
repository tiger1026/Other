# A small function to calculate partial correlations:
pcor <- function(s)
{ i1 <- c(1, 2)
  i2 <- 3:nrow(s); 
  s11 <- s[i1,i1]; s12 <- s[i1,i2]; s21 <- s[i2,i1]; s22  <- s[i2,i2];
  condcov <- s11 - s12 %*% solve(s22) %*% s21
  return(condcov[1,2]/sqrt(condcov[1,1] * condcov[2,2]))
}

dat<-burnaby_condos

# look at the data:
head(dat)
tail(dat)
summary(dat)

# we will not use MLS or region
dat <- dat[,-c(1, 10)]

# Scale the numbers:
dat$askprice <- dat$askprice/1000
dat$ffarea <- dat$ffarea/100
dat$mfee <- dat$mfee/10

# Transform floor to sqrt(floor)
dat$floor <- sqrt(dat$floor)

# Install the "leaps" package
install.packages("leaps")
library(leaps)

###############################################################
### Exhaustive selection.

s1 <- regsubsets(askprice~., data=dat, method="exhaustive")
ss1 <- summary(s1)
ss1

#This table can be accessed directly via 
ss1$which
#where TRUE is *

#Get the adjusted R^2 of each model
ss1$adjr2
which.max(ss1$adjr2)
#Best model is with 4 variables according to adj-R^2

#Get the cp of each model
ss1$cp
which.min(ss1$cp)
#Best model is with 4 variables according to Cp

###############################################################
### PART 2: Forward selection.
s2 <- regsubsets(askprice~., data=dat, method="forward")
ss2 <- summary(s2)
ss2

#find the variable with highest corrleation with y.
cormat <- cor(dat)
cormat
cormat[1,-1]

# baths has the highest absolute correlation with askprice.

#find the highest partial correlation conditioning on baths.
pcorStep2 <-rep(NA, 6)
# Loop over all the variables except baths
for (j in c(2,3,5,6,7,8))
{ cat(colnames(dat)[j], "\t")
  index <- c(1,j,4)
  tpcor <- pcor(cormat[index,index])
  cat(tpcor,"\n")
  pcorStep2[j-1] <- tpcor
}

# floor has highest absolute partial correlation with askprice.

#continuing to find the largest partial correlation conditioning on baths and floor
pcorStep2 <-rep(NA, 5)
# Loop over all the variables.
for (j in c(2,3,6,7,8))
{ cat(colnames(dat)[j], "\t")
  index <- c(1,j,4,5)
  tpcor <- pcor(cormat[index,index])
  cat(tpcor,"\n")
  pcorStep2[j-1] <- tpcor
}
#ffarea 	0.2978755 
#beds 	0.260815 
#view 	0.1328825 
#age 	-0.4858478 
#mfee 	0.0828914 
# age has highest absolute partial correlation with askprice.

# so the first three variables are: baths, floor, and age
#  This is what regsubsets came up with:
ss2

###############################################################
### K-Cross-Validation: 
### Find the "best" model for predictions using Cross-Validation:

library(caret)

# set random seed so that we can replicate our findings:
set.seed(123)

# We will calculate 5-fold CV-RMSE for 4 potential models:
train(log(askprice)~baths+floor+age, data=dat, method="lm",  
      trControl=trainControl(method="cv",number=5))

# Linear Regression 
# 
# 63 samples
# 3 predictor
# 
# No pre-processing
# Resampling: Cross-Validated (5 fold) 
# Summary of sample sizes: 51, 51, 51, 49, 50 
# Resampling results:
#   
#   RMSE       Rsquared   MAE      
# 0.1756646  0.7561191  0.1415126
# 
# Tuning parameter 'intercept' was held constant at a value of TRUE

train(log(askprice)~baths+floor+age+view+ffarea, data=dat, method="lm", 
      trControl=trainControl(method="cv",number=5))
# Linear Regression 
# 
# 63 samples
# 5 predictor
# 
# No pre-processing
# Resampling: Cross-Validated (5 fold) 
# Summary of sample sizes: 50, 49, 51, 51, 51 
# Resampling results:
#   
#   RMSE       Rsquared   MAE       
# 0.1230814  0.8742555  0.09467117
# 
# Tuning parameter 'intercept' was held constant at a value of TRUE

train(log(askprice)~baths+floor+age+view+ffarea+mfee, data=dat, method="lm", 
      trControl=trainControl(method="cv",number=5))
# Linear Regression 
# 
# 63 samples
# 6 predictor
# 
# No pre-processing
# Resampling: Cross-Validated (5 fold) 
# Summary of sample sizes: 50, 51, 51, 49, 51 
# Resampling results:
#   
#   RMSE       Rsquared  MAE       
# 0.1156683  0.899719  0.09095212
# 
# Tuning parameter 'intercept' was held constant at a value of TRUE

train(log(askprice)~baths+floor+age+view+ffarea+mfee+beds, data=dat, method="lm", 
      trControl=trainControl(method="cv",number=5))
# Linear Regression 
# 
# 63 samples
# 7 predictor
# 
# No pre-processing
# Resampling: Cross-Validated (5 fold) 
# Summary of sample sizes: 50, 51, 50, 50, 51 
# Resampling results:
#   
#   RMSE       Rsquared   MAE       
# 0.1174355  0.9022152  0.09251848
# 
# Tuning parameter 'intercept' was held constant at a value of TRUE

#### The model with 6 predictors has the best results,
#### the value of its RSME is the smallest which indicates a better fit of the model.

train(log(askprice)~baths+floor+age+view, data=dat, method="lm", 
      trControl=trainControl(method="cv",number=5))

# vLinear Regression 
# 
# 63 samples
# 4 predictor
# 
# No pre-processing
# Resampling: Cross-Validated (5 fold) 
# Summary of sample sizes: 51, 50, 50, 51, 50 
# Resampling results:
#   
#   RMSE       Rsquared   MAE     
# 0.1769383  0.7414574  0.144994
# 
# Tuning parameter 'intercept' was held constant at a value of TRUE
