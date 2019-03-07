#!/usr/bin/env bash

M2_HOME="${HOME}/.m2"
M2_CACHE="${PWD}/maven"
BASE=${PWD}

echo "Generating symbolic links for caches"
[[ -d "${M2_CACHE}" && ! -d "${M2_HOME}" ]] && ln -s "${M2_CACHE}" "${M2_HOME}"

cd git-resource-core
cd $WORKING_DIR
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion} versions:commit
mvn clean package
cp target/${CF_APP_NAME}.jar ${BASE}/built-core/
cp pom.xml ${BASE}/built-core/
ls ${BASE}/built-core

STATUS=$?
echo $STATUS
if [ "$STATUS" != 0 ]; then
    mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}-SNAPSHOT versions:commit
else
    echo "Setting up Git"
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install git

    git --version
    git config --global user.email "concourse@nomail.com"
    git config --global user.name "Concourse"
    cd ${BASE}
    git clone version-resource-gist updated-gist

    cd updated-gist
#    echo $(ls)
    echo $(mvn help:evaluate -Dexpression=project.version -q -DforceStdout -f=${BASE}/git-resource-core/${WORKING_DIR}/pom.xml) > ${CF_APP_NAME}-release-version
    cp ${BASE}/git-resource-core/${WORKING_DIR}/manifest.yml .
    cp ${BASE}/git-resource-core/${WORKING_DIR}/pom.xml .

    echo "Contents for gist:$(ls)"

    git add .
    git commit -m "Bumped version"
fi