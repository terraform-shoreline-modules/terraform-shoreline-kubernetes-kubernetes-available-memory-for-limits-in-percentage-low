#!/bin/bash

# Define the threshold for excessive memory usage

MEMORY_THRESHOLD=${MEMORY_THRESHOLD}

# Get a list of all pods running on the Kubernetes cluster

PODS=$(kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

# Loop through each pod and check if it is using excessive memory

for POD in $PODS

do

  MEMORY_USAGE=$(kubectl top pod $POD | awk '{print $2}' | grep -v MEMORY)

  if [ $MEMORY_USAGE -gt $MEMORY_THRESHOLD ]

  then

    # If the pod is using excessive memory, terminate it

    kubectl delete pod $POD

    echo "Terminated pod: $POD"

  fi

done

echo "Memory usage check complete."