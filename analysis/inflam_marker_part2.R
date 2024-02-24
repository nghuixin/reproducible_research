### ----- SCENARIO (PART II)-----
# For people without data access
# This script includes a workflow for simulating data based on observed data from a sample and performing basic data checks to ensure the simulated data retains similar properties
# It is unnecessary for you to run this script since the already is ALREADY simulated, but for transparency purposes I have included it here to show the simulation process
# This simulated data is provided for non-collaborators who wish to replicate analyses typically written for psychological research, as in part1.R
# The statistical properties (mean and covariance matrix) of the original and simulated data are saved in csv files in the data folder

### --- LOAD PACKAGES --- 
# compare list to the output from new packages and install the missing packages
list.of.packages <- c("readr", "MASS", "plyr", "tidyverse", "lme4", "car","ggplot2", "nlme" )
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(readr)   # For reading CSV files
library(plyr)    # For data manipulation
library(tidyverse)  # For data wrangling and visualization
library(lme4)    # For linear mixed-effects models
library(car)     # For diagnostic plots
library(ggplot2) # For visualization
library(nlme)    # For fitting mixed-effects models
library(MASS)  # For simulating data with based on sample correlations

### --- PART II ---
### Note: Data sharing and privacy
# Due to data privacy protocols, I have simulated a subset of the data (from the first visit) and a subset of variables as sample data for this tutorial

### --- LOAD DATA ---
# Read the CSV file
data <- read_csv("data/infl_231010.csv") # You do not have access to this data file

# Use complete.cases() function to retain rows with complete data
complete_data <- data[complete.cases(data[, c("bdnf", "ccl11", "ccl26", "ip10",
                                              "mcp1", "mdc", "mip1b", "il17a", "vegf", "fract",
                                              "ifny", "il10", "il6", "il8", "tnfa", "crp",
                                              "saa", "icam1", "vcam1", "lgcrp", "lgccl11",
                                              "lgccl26", "lgip10", "lgmcp1", "lgmdc", "lgmip1b",
                                              "lgil17a", "lgvegf", "lgifny", "lgil10", "lgil6",
                                              "lgil8", "lgtnfa", "lgsaa", "lgicam1", "lgvcam1",
                                              "lgbdnf", "lgfract", 'agem' ,'dxgroup', 'gender', 'visit', 'subnum', 'time')]), ]

complete_data <- complete_data %>% mutate(across(c(subnum, visit, gender, dxgroup, gender, race, race_lat, hisp, veteran,), as.factor))

### --- SIMULATE NEW DATA ---
#Subset variables and data from visit 101 for simulation
subset_data <- complete_data %>%
  dplyr::select(gender,visit, dxgroup ,  lgmip1b , lgil17a ,  agem  , dxgroup , lgvegf, lgbdnf) %>% filter(visit == 101)

# Get the mean and covariance matrix of the observed data for continuous variables
continuous_data <- subset_data %>% dplyr::select(-c(dxgroup, gender, visit ))
mean_continuous <- colMeans(continuous_data)
cov_continuous <- cov(continuous_data)

# Generate simulated data for continuous variables using multivariate normal distribution
n_obs_simulated <- 1000
simulated_continuous <- mvrnorm(n = n_obs_simulated, mu = mean_continuous, Sigma = cov_continuous)

# Convert simulated continuous data to a dataframe
simulated_continuous_df <- as.data.frame(simulated_continuous)

# Get the proportion of each category in dxgroup and gender variables from the observed dataset
prop_dxgroup <- prop.table(table(subset_data$dxgroup))
prop_gender <- prop.table(table(subset_data$gender))

# Generate simulated binary data for dxgroup and gender variables based on the proportions from the observed dataset
simulated_binary_dxgroup <- rbinom(n_obs_simulated, 1, prob = prop_dxgroup[2])
simulated_binary_gender <- rbinom(n_obs_simulated, 1, prob = prop_gender[2])

# Combine simulated binary data for dxgroup and gender variables
simulated_binary <- cbind(simulated_binary_dxgroup, simulated_binary_gender)

# Combine simulated continuous and binary data
simulated_data <- cbind(simulated_binary, simulated_continuous_df)

# Rename columns and ensure the binary variables are factorized
colnames(simulated_data)[1:2] <- c("dxgroup", "gender")
simulated_data <- simulated_data %>% mutate(across(c("dxgroup", "gender"), as.factor))

# write data to csv file
write.csv(simulated_data, "data/bd_inflm_simulated.csv", row.names=FALSE)

### --- SANITY CHECKS ---
# Compute mean for numeric variables in subset_data and simulated_data
mean_subset_data <- subset_data %>%
  dplyr::select(where(is.numeric)) %>%
  apply(X = ., MARGIN = 2, FUN = mean)

mean_simulated_data <- simulated_data %>%
  dplyr::select(where(is.numeric)) %>%
  apply(X = ., MARGIN = 2, FUN = mean)

# Compute correlation matrix for numeric variables in subset_data and simulated_data
cor_subset_data <- subset_data %>%
  dplyr::select(where(is.numeric)) %>%
  cor()

cor_simulated_data <- simulated_data %>%
  dplyr::select(where(is.numeric)) %>%
  cor()

# Calculate proportions for categorical variables in subset_data
proportions_subset_data <- subset_data %>%
  dplyr::select(where(is.factor)) %>%
  sapply(function(x) prop.table(table(x)))

# Calculate proportions for categorical variables in simulated_data
proportions_simulated_data <- simulated_data %>%
  dplyr::select(where(is.factor)) %>%
  sapply(function(x) prop.table(table(x)))

# Save means to CSV
write.csv(mean_subset_data, file = "data/subset_data_mean.csv")
write.csv(mean_simulated_data, file = "data/simulated_data_mean.csv")

# Save correlation matrices to CSV
write.csv(cor_subset_data, file = "data/subset_data_correlation.csv")
write.csv(cor_simulated_data, file = "data/simulated_data_correlation.csv")

# Save proportions to csv
write.csv(proportions_subset_data, file = "data/subset_data_prop.csv")
write.csv(proportions_simulated_data, file = "data/simulated_data_prop.csv")

### ================================================================= 

### --- SANDBOX FOR EDITING AND ADDING NEW CODE TO PLOT AND ANALYZE DATA  ---
simulated_data <- read.csv(file = "data/bd_inflm_simulated.csv")

ggplot(simulated_data, aes(x = agem, y = lgvegf, color = factor(dxgroup), linetype = factor(gender))) +
  geom_point(size = 0.9) +  # Add points for the observed data
  geom_smooth(method = "lm", se = TRUE) +  # Add regression line without confidence interval
  labs(x = "Age (months)", y = "lgvegf", color = "dxgroup", linetype = "Gender") +  # Labels
  theme_minimal()

mod <- lm(lgvegf ~ dxgroup*agem*gender, data = simulated_data)
summary(mod)

