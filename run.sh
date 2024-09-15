#!/bin/bash

cd frontend/src
npm run build
npm run export
cd ../../iac
terraform init && terraform apply --auto-approve