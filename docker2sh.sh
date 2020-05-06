#!/bin/bash

# This converts a docker file to a shell file
# Almost guaranteed to not work with many Docker files, but hey, it works for us

HOME_DIRECTORY=/home/ubuntu

INPUT=Dockerfile
OUTPUT=Dockerfile.sh

cp -f $INPUT $OUTPUT

# Convert FROM, MAINTAINER, VOLUME, etc. to comments
sed -r 's/^(FROM|MAINTAINER|VOLUME|COPY|ENTRYPOINT|CMD)(.*)\s/# \1 \2/g' -i $OUTPUT

# Get rid of EXPOSE todo: open up ports based on these?
sed -i "s/^EXPOSE/# EXPOSE/g" $OUTPUT

# Get rid of RUNs
sed -i "s/^RUN\s//g" $OUTPUT

# Change workng dir
sed -i "s/^WORKDIR\s/cd $WORK_DIRECTORY/g" $OUTPUT

# Convert home directory into squiggles (tildes)
sed -i 's@'"$HOME_DIRECTORY"'@~@g' $OUTPUT

# Change workng dir
sed -i 's@\/root@'"$HOME_DIRECTORY"'@g' $OUTPUT

# Convert ENVs into EXPORTs
sed -r 's/^ENV\s(.+)\s+(.+)/export \1=\2/g' -i $OUTPUT

# Convert ADDs into cp
sed -i "s/^ADD\s/cp /g" $OUTPUT
