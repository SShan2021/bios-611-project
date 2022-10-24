FROM rocker/verse

#to install the packages  "readxl"
RUN Rscript --no-restore --no-save -e "install.packages('readxl')"
