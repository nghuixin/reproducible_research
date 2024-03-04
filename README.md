# Reproducible and Replicable Research with R, Docker and Github
This repository contains scripts and resources for reproducible research analysis related to inflammation markers. By following the instructions below, you can replicate the analysis and explore the provided datasets and scripts.

## Getting Started
To begin, clone this repository to your local machine using Git:

```git clone https://github.com/nghuixin/reproducible_research.git```

## Creating the Analysis Environment
You can utilize Docker to set up a consistent analysis environment. First, pull the docker image: https://hub.docker.com/repository/docker/nghuixin/infl_marker_analysis/general.   
Run the following command in the cloned directory:
 
```docker run --rm -p 8787:8787 -e DISABLE_AUTH=true -v $(pwd):/home/rstudio -v /home/rstudio/renv nghuixin/infl_marker_analysis:1.0.1```

This will start an RStudio session accessible via your browser at localhost:8787. The environment is pre-configured with all necessary system dependencies, R version, and packages required for the analysis.

## Replicating the Analysis

#### Using ```inflam_marker_part1.R```
If you have access to the original study dataset infl_231010.csv, you can replicate the analysis performed in inflam_marker_part1.R. This script generates figures and linear regression output.

If you don't have access to the original dataset, you can still view the output of the analysis (analysis/mod1.rda) and the generated figures.

#### Using ```inflam_marker_part2.R```
This script simulates a fake dataset for users who don't have access to the original study dataset. If you have access to infl_231010.csv, you can replicate the simulation.

If you don't have access to the original dataset, you can still replicate the analysis performed on the simulated data, including figures and linear regression models.
The statistical properties from the original study dataset `infl_231010.csv` were pre-populated at build time in the container. However, these csv files are not included in this repository due to privacy concerns. 
Once you `git pull` the docker image and run it, you will be able to access those data files, like `data/subset_data_correlation.csv` etc. 

## Disclaimer
Please note that the provided scripts and datasets are for educational and research purposes only.  

 
