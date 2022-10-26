FROM rocker/verse

#to install the packages  "readxl"
RUN Rscript --no-restore --no-save -e "install.packages('readxl')"

#to install the packages  "vistime"
RUN Rscript --no-restore --no-save -e "install.packages('vistime')"

#to install the packages  "reticulate"
RUN Rscript --no-restore --no-save \
    -e "install.packages('reticulate'); reticulate::install_miniconda();"

RUN Rscript --no-restore --no-save \
    -e "webshot::install_phantomjs()"

#make sure we can render markdown
RUN Rscript --no-restore --no-save -e "update.packages(ask = FALSE);"
