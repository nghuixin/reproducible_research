### ----- SCENARIO (PART I)-----
# For people with data access
# As a collaborator, you can replicate the exact same analyses that were done for this research project by loading the data file shared with you
# The analyses include fitting a mixed-effects model and creating visualizations.
# For users who were not given the data file, they can still access the i) linear regression model results, ii) figures

### --- LOAD PACKAGES ---
# Compare the list of required packages to installed packages.
# Install missing packages if necessary.
list.of.packages <- c("readr", "MASS", "plyr", "tidyverse", "lme4", "car", "ggplot2", "nlme")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages) > 0) {
  install.packages(new.packages)
}

# Load required packages
library(readr)     # For reading CSV files
library(plyr)      # For data manipulation
library(tidyverse) # For data wrangling and visualization
library(lme4)      # For linear mixed-effects models
library(car)       # For diagnostic plots
library(ggplot2)   # For visualization
library(nlme)      # For fitting mixed-effects models
library(MASS)      # For simulating data based on sample correlations

# ==== If you do not have data access, you can still get the linear regression model results by loading the .rda object === 
# Load the model object from the file
load("analysis/mod1.rda")

# Print model summary
summary(mod1)


### Note: Study goals
# The simulated data is from a longitudinal study on bipolar disorder.
# The goal is to investigate the relationship between inflammation markers and symptom severity in BD.
# We aim to establish how the illness progresses and what influences the prognosis.
# Due to data sharing and privacy protocols, the CSV file cannot be shared.

### --- LOAD DATA ---
# Read the simulated data file
data <- read_csv("data/infl_231010.csv")

# Retain rows with complete data
complete_data <- data[complete.cases(data[, c("bdnf", "ccl11", "ccl26", "ip10",
                                              "mcp1", "mdc", "mip1b", "il17a", "vegf", "fract",
                                              "ifny", "il10", "il6", "il8", "tnfa", "crp",
                                              "saa", "icam1", "vcam1", "lgcrp", "lgccl11",
                                              "lgccl26", "lgip10", "lgmcp1", "lgmdc", "lgmip1b",
                                              "lgil17a", "lgvegf", "lgifny", "lgil10", "lgil6",
                                              "lgil8", "lgtnfa", "lgsaa", "lgicam1", "lgvcam1",
                                              "lgbdnf", "lgfract", 'agem' ,'dxgroup', 'gender', 'visit', 'subnum', 'time')]), ]

# Convert selected columns to factors
complete_data <- complete_data %>%
  mutate(across(c(subnum, visit, gender, dxgroup, gender, race, race_lat, hisp, veteran,), as.factor))

### --- FIT DATA TO MODEL ---
# Fit the mixed-effects model using lme4
mod1 <- lme(lgvegf ~ time * (agem * dxgroup + gender) + dxgroup * (gender),
            random = ~ time | subnum, data = complete_data)

# Print model summary
summary(mod1)

# Save the model object
save(mod1, file = "analysis/mod1.rda")

# Extract fitted/predicted values
complete_data$fitted_values <- fitted(mod1)

### --- PLOT DATA ---
# Plot the raw data showing BD vs. HC group
jpeg('figures/plot1.jpg')
ggplot(complete_data, aes(x = time, y = lgvegf, color = dxgroup)) +
  geom_point(size = 0.9) +  # Add points for the observed data
  geom_smooth(method = "lm", se = FALSE) +  # Add regression line without confidence interval
  labs(x = "Time", y = "lgvegf", color = "dxgroup") +  # Labels
  theme_minimal()
dev.off()

# Plot the raw data showing BD vs. HC and Female vs. Male
jpeg('figures/plot2.jpeg')
ggplot(complete_data, aes(x = time, y = lgvegf, color = dxgroup, linetype = gender)) +
  geom_point(size = 0.9) +  # Add points for the observed data
  geom_smooth(method = "lm", se = TRUE, alpha = 0.3) +  # Add regression line with confidence interval
  labs(x = "Time", y = "lgvegf", color = "dxgroup", linetype = "Gender") +  # Labels
  scale_linetype_manual(values = c("solid", "dashed")) +  # Specify line styles
  theme_minimal()
dev.off()

# Plot the predicted values showing BD vs. HC and Female vs. Male
jpeg('figures/predicted.jpeg')
ggplot(complete_data, aes(x = time, y = fitted_values, color = dxgroup, linetype = gender)) +
  geom_point(size = 0.9) +  # Add points for the observed data
  geom_smooth(method = "lm", se = TRUE) +  # Add regression line without confidence interval
  labs(x = "Time", y = "Predicted lgvegf", color = "dxgroup") +  # Labels
  theme_minimal()
dev.off()
