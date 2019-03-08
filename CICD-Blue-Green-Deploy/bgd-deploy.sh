#!/usr/bin/env bash

echo "Setting up CF Cli"
# ...or Linux 64-bit binary
curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx
# ...move it to /usr/local/bin or a location you know is in your $PATH
mv cf /usr/local/bin
# ...copy tab completion file on Ubuntu (takes affect after re-opening your shell)
curl -o /usr/share/bash-completion/completions/cf https://raw.githubusercontent.com/cloudfoundry/cli/master/ci/installers/completion/cf
# ...and to confirm your cf CLI version
cf --version
cf install-plugin -f -r CF-Community "blue-green-deploy"
#Log in to cloud foundry
echo "Running: cf login -a ${CF_API} --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE}"
cf login -a ${CF_API} --skip-ssl-validation -o ${CF_ORG} -s ${CF_SPACE} -u ${CF_USERNAME} -p ${CF_PASSWORD}

#Download artifact
echo "Downloading artifact to deploy"
cd version-resource-gist

#Download manifest and associated files
echo "Contents in version-resource-gist: $(ls)"
echo "Downloading from Bintray"
Version=$(cat *release-version)
Group=$(mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout -f=pom.xml | tr . /)
Artifact=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout -f=pom.xml)

FILE_PATH="${Group}/${Artifact}/${Version}/${Artifact}-${Version}.jar"
echo "Downloading artifact from: https://dl.bintray.com/xlpeabrain/maven-repo/${FILE_PATH}"
curl -L "https://dl.bintray.com/xlpeabrain/maven-repo/${FILE_PATH}" -o ${Artifact}.jar

cd ..
cp version-resource-gist/* built-core-op/
mkdir built-core-op/target
mv built-core-op/${Artifact}.jar built-core-op/target/

cat built-core-op/manifest.yml

echo "Contents in built-core-op: $(ls built-core-op)"

cd built-core-op
#Blue Green Deploy only for services not connected to API Gateway
cf bgd ${CF_APP_NAME} -delete-old-apps
