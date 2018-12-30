#!/usr/bin/env bash
# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#

set -o errexit
set -o pipefail
set -o nounset

METADATA_VERSION="$1"
shift

if [[ -z "${METADATA_VERSION}" ]]
then
  echo "Usage: $0 <version to release>"
  exit 1
fi

# By default we don't deploy to any repository. These two environment
# variables can be set to push to one or both repositories.
DEPLOY_BINTRAY="${DEPLOY_BINTRAY:-false}"
DEPLOY_OSSRH="${DEPLOY_OSSRH:-false}"

WORKDIR=`mktemp -d`

function cleanup {
    echo "Deleting ${WORKDIR}"
    echo rm -rf ${WORKDIR}
}

echo "Building Maven artifacts under ${WORKDIR}"

echo "Copying built jars..."
TARGET_CLASSES=${WORKDIR}/target/classes
PROTO_RESOURCES=${WORKDIR}/src/main/resources/tensorflow_metadata/proto/v0
mkdir -p ${TARGET_CLASSES}
mkdir -p ${PROTO_RESOURCES}
cp -f tensorflow_metadata/java/maven/pom.xml ${WORKDIR}
find tensorflow_metadata/proto/v0 -name '*.jar' -exec unzip -q -d ${TARGET_CLASSES} '{}' '*class' ';'
find tensorflow_metadata/proto/v0 -name '*.proto' -exec cp '{}' ${PROTO_RESOURCES} ';'

echo "Verifying and signing Maven artifacts..."
cd ${WORKDIR}
mvn -q versions:set -DnewVersion="${METADATA_VERSION}"
mvn -q verify
if [[ "${DEPLOY_OSSRH}" == "true" ]]; then
    mvn deploy -Possrh
fi
if [[ "${DEPLOY_BINTRAY}" == "true" ]]; then
    mvn deploy -Pbintray
fi

cleanup
