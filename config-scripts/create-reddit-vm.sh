#!/bin/bash

gcloud compute instances create reddit-full \
  --image-family reddit-full \
  --machine-type f1-micro \
  --tags puma-server \
  --restart-on-failure
