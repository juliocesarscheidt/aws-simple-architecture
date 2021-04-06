#!/bin/bash

set -e

pushd terraform/

terraform init && \
  terraform validate && \
  terraform plan && \
  terraform apply -auto-approve

popd
