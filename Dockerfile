# Base R image
FROM rocker/verse:4.3.2

# Install R dependencies
RUN R -e "install.packages(c('renv'), repos = 'https://cloud.r-project.org')"

# Set the working directory
WORKDIR /home/rstudio

# Copy the R script and data
COPY analysis/ ./analysis/
COPY data/  ./data/
COPY figures/ ./figures/

# Copy renv files
COPY renv.lock renv.lock
COPY renv renv

# Run this to install the R packages specified in the renv.lock file to set up the project's environment.
RUN R -e "renv::restore()"

 
