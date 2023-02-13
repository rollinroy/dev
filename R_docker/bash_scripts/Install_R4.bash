#!/bin/bash
# remove R 3.4.x via http://genomespot.blogspot.com/2020/06/installing-r-40-on-ubuntu-1804.html
sudo apt remove r-base* --purge
# R 3.4.x is installed in /usr/lib/R; R 4.2.2 will be installed there.  check if 3.4.x has been removed

#Remove any existing entry for R in the etc/apt/sources.list to install an older R version.
#      sudo vi /etc/apt/sources.list
#For example you might have something like this:
#deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/

# unlink R 3.6.1 in /usr/local/bin
sudo unlink /usr/local/bin/R
sudo unlink /usr/local/bin/Rscript
#  Install R4+ on ubuntu 18.04 via https://cran.r-project.org/bin/linux/ubuntu/
# update indices
sudo apt update -qq
# install two helper packages we need
sudo apt install --no-install-recommends software-properties-common dirmngr
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# install R and packages
sudo apt install --no-install-recommends r-base
sudo apt install --no-install-recommends r-cran-tidyverse

# mkl_intel64 via http://dirk.eddelbuettel.com/blog/2018/04/15/
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB

sudo sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list'
sudo apt-get update

sudo apt-get install intel-mkl-64bit-2018.2-046

sudo update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so     \
                    libblas.so-x86_64-linux-gnu      /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
sudo update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so.3   \
                    libblas.so.3-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
sudo update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so   \
                    liblapack.so-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
sudo update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so.3 \
                    liblapack.so.3-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 50

sudo echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf
sudo echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf
sudo ldconfig

# a manual, simple way which gives the same result (once mkl is installed like it is for R 3.6.1)
#/etc/alternatives/libblas.so.x86_64-linux-gnu -> /usr/lib/x86_64-linux-gnu/blas/libblas.so.3
#sudo unlink /etc/alternatives/libblas.so.3-x86_64-linux-gnu
#sudo ln -s /opt/intel/mkl/lib/intel64/libmkl_rt.so /etc/alternatives/libblas.so.3-x86_64-linux-gnu

# update /usr/lib/R/etc/Renviron.site to have:
# add mkl environment variables
sudo echo "MKL_INTERFACE_LAYER=GNU,LP64" >> /usr/lib/R/etc/Renviron.site
sudo echo "MKL_THREADING_LAYER=GNU" >> /usr/lib/R/etc/Renviron.site


Rscript -e 'install.packages("BiocManager", repos="https://ftp.osuosl.org/pub/cran/")'

# rstudio server via https://posit.co/download/rstudio-server/
sudo apt-get update
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.12.0-353-amd64.deb
sudo gdebi rstudio-server-2022.12.0-353-amd64.deb
# test for ggplot2: ggplot(mpg, aes(displ, hwy, colour = class)) + geom_point()
