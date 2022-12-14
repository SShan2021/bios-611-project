Investigating the Relationship between Uninsured Payer Mix and Relative Cost of Hospital Services
============================
Author: Sophie Shan
----------------------------
This repository contains an analysis of data from RAND's National Evaluation of Health Care Prices Paid by Private Health Plans (https://www.rand.org/pubs/research_reports/RR4394.html) merged with data from The National Academy for State Health Policy's Hospital Cost Tool (NASHP) (https://d3g6lgu1zfs2l4.cloudfront.net/).

The dataset from RAND describes how much private insurers pay relative to the cost of Medicare (Medicare has a set algorithm for deciding payments, while private insurers negotiate separately with each hospital) and includes information on hospital location, hospital system, CMS 5-star rating, relative price for outpatient/inpatient services, etc. This dataset includes hospitals from all 50 states.

The dataset from NASHP has information about a hospital’s payer mix (Medicare Payer Mix, Commercial Payer Mix, Uninsured Payer Mix etc) as well as other hospital characteristics such as bed size, location, hospital system, from 2011-2019.

We seek to understand the kinds of hospitals by using characteristics data from both datasets. We hope to find patterns between types of hospitals that might explain distribution of uninsured and/or charity payer mix. 

Using This Repository
============================
This repository is best used via Docker. Docker builds an environment which contains all the software needed to the project.

One Docker container is provided for both "production" and
"development." To build it you will need to create a file called
`.password` which contains the password you'd like to use for the
rstudio user in the Docker container. Then you run:

```
docker build . --build-arg linux_user_pwd="$(cat .password)" -t 611
```

This will create a docker container. Users using terminal will be able to start an RStudio server by running:

```
docker run -v "$(pwd)":/home/rstudio/work\
           -p 8787:8787\
           -p 8888:8888\
           -e PASSWORD="$(cat .password)"\
           -it 611
```

You then visit http://localhost:8787 via a browser on your machine to
access the machine and development environment. For the curious, we
also expose port 8888 so that we can launch other servers from in the
container.


Project Organization
====================
There are currently only one product of this analysis.
1) A report which has results

In the terminal of R, you simply invoke:

```
cd work
make HospitalValuesReport_SophieShan.pdf
```
