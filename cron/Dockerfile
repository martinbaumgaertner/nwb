# Base image https://hub.docker.com/u/oliverstatworx/
FROM oliverstatworx/base-r-tidyverse:latest

# Install dependencies
RUN apt-get update --allow-releaseinfo-change && apt-get install -y \
    cron

# install R packages
RUN R -e "install.packages(c('RMariaDB'), dependencies = TRUE)"

# copy folder which contains cronfile, RScript
COPY /src    /src  
WORKDIR /src

# make all app files readable, gives rwe permisssion (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /src

# Apply cron job
RUN crontab /src/cronjob

CMD echo "cronjob gets started" && (cron) && echo "done" && touch /var/log/cron.log && tail -f /var/log/cron.log && echo "done"