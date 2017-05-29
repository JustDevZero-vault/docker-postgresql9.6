FROM debian:8
MAINTAINER Daniel Ripoll <info@danielripoll.es>

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.6``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes and install ``python-software-properties``,
# ``software-properties-common`` and PostgreSQL 9.6
# There are some warnings (in red) that show up during the build. You can hide
# them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -t jessie-pgdg postgresql-9.6 \
    postgresql-contrib-9.6 postgresql-server-dev-9.6 libpq-dev libproj-dev libproj0 proj-bin libgeos-dev libgeos-c1 build-essential ccache \
    wget net-tools emacs-nox postgresql-9.6-postgis-2.3

USER postgres

RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER pguser WITH SUPERUSER PASSWORD 'pguser';" \
    && createdb -O pguser pguser

USER root

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible
ADD confs/pg_hba.conf /etc/postgresql/8.4/main/pg_hba.conf
ADD confs/postgresql.conf /etc/postgresql/8.4/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5431

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql


USER postgres

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/8.4/bin/postgres", "-D", "/var/lib/postgresql/8.4/main", "-c", "config_file=/etc/postgresql/8.4/main/postgresql.conf"]
