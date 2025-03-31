#!/bin/bash

VERSION=$1

# Update version in application.properties
sed -i "s/version=.*/version=$VERSION/" src/main/resources/application.properties