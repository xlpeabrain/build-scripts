#!/usr/bin/env bash
#echo "Setting up jq"
apt-get -y update
apt-get -y upgrade
apt-get -y install jq

echo "Setting up CF Cli"
# ...or Linux 64-bit binary
curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx
# ...move it to /usr/local/bin or a location you know is in your $PATH
mv cf /usr/local/bin
# ...copy tab completion file on Ubuntu (takes affect after re-opening your shell)
curl -o /usr/share/bash-completion/completions/cf https://raw.githubusercontent.com/cloudfoundry/cli/master/ci/installers/completion/cf
# ...and to confirm your cf CLI version
cf --version
#Log in to cloud foundry
echo "Running: cf login -a ${CF_API} --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE}"
cf login -a ${CF_API} --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE} -u ${CF_USERNAME} -p ${CF_PASSWORD}

APP_ROUTE=$(cf app core| grep routes | sed 's/routes:[ \t]*//')

echo "${APP_ROUTE}"

APP_STATUS="$(curl -k https://${APP_ROUTE}/actuator/health | jq '.status')"
EXPECTED_STATUS="\"UP\""
echo "Status: ${APP_STATUS}"

if [ "${APP_STATUS}" == "${EXPECTED_STATUS}" ]; then
    echo "match"
    exit
else
    echo "no match"
    exit 1
fi