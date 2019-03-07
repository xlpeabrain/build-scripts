#!/usr/bin/env bash

M2_HOME="${HOME}/.m2"
M2_CACHE="${PWD}/maven"

echo "Generating symbolic links for caches"
[[ -d "${M2_CACHE}" && ! -d "${M2_HOME}" ]] && ln -s "${M2_CACHE}" "${M2_HOME}"

echo "Setting up Git"
apt-get -y update
apt-get -y upgrade
apt-get -y install git

git --version
git config --global user.email "concourse@nomail.com"
git config --global user.name "Concourse"
git clone git-resource-core updated-core
cd updated-core/${WORKING_DIR}
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}-SNAPSHOT versions:commit
#mvn clean package
git add .
git commit -a -m "Commit new snapshot"
pwd