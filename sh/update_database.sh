#!/bin/sh -e
# shellcheck disable=SC1090
# shellcheck disable=SC2129

#    Licensed to the Apache Software Foundation (ASF) under one or more
#    contributor license agreements.  See the NOTICE file distributed with
#    this work for additional information regarding copyright ownership.
#    The ASF licenses this file to You under the Apache License, Version 2.0
#    (the "License"); you may not use this file except in compliance with
#    the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

prop_replace 'nifi.registry.db.url'                         "${NIFI_REGISTRY_DB_URL:-jdbc:h2:./database/nifi-registry-primary;AUTOCOMMIT=OFF;DB_CLOSE_ON_EXIT=FALSE;LOCK_MODE=3;LOCK_TIMEOUT=25000;WRITE_DELAY=0;AUTO_SERVER=FALSE}"
prop_replace 'nifi.registry.db.driver.class'                "${NIFI_REGISTRY_DB_CLASS:-org.h2.Driver}"
prop_replace 'nifi.registry.db.driver.directory'            "${NIFI_REGISTRY_DB_DIR:-}"
prop_replace 'nifi.registry.db.username'                    "${NIFI_REGISTRY_DB_USER:-nifireg}"
prop_replace 'nifi.registry.db.password'                    "${NIFI_REGISTRY_DB_PASS:-nifireg}"
prop_replace 'nifi.registry.db.maxConnections'              "${NIFI_REGISTRY_DB_MAX_CONNS:-5}"
prop_replace 'nifi.registry.db.sql.debug'                   "${NIFI_REGISTRY_DB_DEBUG_SQL:-false}"

mkdir -p "${NIFI_REGISTRY_HOME}/ssl/"
if [ -n "${NIFI_REGISTRY_DB_SSL_CERT}" ]; then
  echo "$NIFI_REGISTRY_DB_SSL_CERT" | base64 -d > "${NIFI_REGISTRY_HOME}/ssl/cert"
fi
if [ -n "${NIFI_REGISTRY_DB_SSL_PRIVATE_KEY}" ]; then
  echo "$NIFI_REGISTRY_DB_SSL_PRIVATE_KEY" | base64 -d > "${NIFI_REGISTRY_HOME}/ssl/private_key"
fi
if [ -n "${NIFI_REGISTRY_DB_SSL_SERVER_CA_CERT}" ]; then
  if grep -q "javax.net.ssl.trustStore" "${NIFI_REGISTRY_HOME}/conf/bootstrap.conf"; then
    echo "Conf already set"
  else
    echo "$NIFI_REGISTRY_DB_SSL_SERVER_CA_CERT" | base64 -d > "${NIFI_REGISTRY_HOME}/ssl/server_ca_cert"
    keytool -importcert -alias database -keystore "${NIFI_REGISTRY_HOME}/ssl/keystore" -storepass keystore -file "${NIFI_REGISTRY_HOME}/ssl/server_ca_cert" -noprompt || echo "Certificate not imported"
    echo "" >> "${NIFI_REGISTRY_HOME}/conf/bootstrap.conf"
    echo "java.arg.7=-Djavax.net.ssl.trustStore=${NIFI_REGISTRY_HOME}/ssl/keystore" >> "${NIFI_REGISTRY_HOME}/conf/bootstrap.conf"
    echo "java.arg.8=-Djavax.net.ssl.trustStorePassword=keystore" >> "${NIFI_REGISTRY_HOME}/conf/bootstrap.conf"
  fi
fi
