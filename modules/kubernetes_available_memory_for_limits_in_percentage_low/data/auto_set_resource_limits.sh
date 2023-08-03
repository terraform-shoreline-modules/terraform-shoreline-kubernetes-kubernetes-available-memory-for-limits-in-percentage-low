bash

#!/bin/bash

# Set the namespace where the resources are located

NAMESPACE=${NAMESPACE}

# Loop through all pods in the namespace and check the resource requests and limits

for pod in $(kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do

    # Get the resource requests and limits for the pod

    requests=$(kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.spec.containers[*].resources.requests.memory}')

    limits=$(kubectl get pod $pod -n $NAMESPACE -o jsonpath='{.spec.containers[*].resources.limits.memory}')

    # If the requests or limits are not set, set them to a default value

    if [ -z "$requests" ]; then

        kubectl patch pod $pod -n $NAMESPACE --patch '{"spec": {"containers": [{"name": "'"$pod"'", "resources": {"requests": {"memory": "256Mi"}}}]}}'

    fi

    if [ -z "$limits" ]; then

        kubectl patch pod $pod -n $NAMESPACE --patch '{"spec": {"containers": [{"name": "'"$pod"'", "resources": {"limits": {"memory": "512Mi"}}}]}}'

    fi

      # If the requests or limits are too low, increase them to a higher value

    if [ "$requests" -lt "256Mi" ]; then

        kubectl patch pod $pod -n $NAMESPACE --patch '{"spec": {"containers": [{"name": "'"$pod"'", "resources": {"requests": {"memory": "256Mi"}}}]}}'

    fi

    if [ "$limits" -lt "512Mi" ]; then

        kubectl patch pod $pod -n $NAMESPACE --patch '{"spec": {"containers": [{"name": "'"$pod"'", "resources": {"limits": {"memory": "512Mi"}}}]}}'

    fi

done