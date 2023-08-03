
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Available Memory for Limits in percentage Low
---

This incident type refers to situations where the available memory for limits in percentage of a Kubernetes cluster is low. This can cause issues with the performance and stability of the cluster, potentially leading to downtime or other problems. The incident may be triggered by an automated query or monitoring tool that checks for certain metrics or thresholds. It is important to address and resolve this issue as soon as possible to ensure the continued health and reliability of the Kubernetes cluster.

### Parameters
```shell
# Environment Variables

export CONTAINER_NAME="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export CONTEXT_NAME="PLACEHOLDER"

export POD_LABEL="PLACEHOLDER"

export MEMORY_THRESHOLD="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"
```

## Debug

### Check the available memory for limits in percentage for all nodes in the cluster
```shell
kubectl top nodes | awk '{print $1,$4}' | column -t
```

### Check the available memory for limits in percentage for all pods in the cluster
```shell
kubectl top pods --all-namespaces | awk '{print $1,$2,$4}' | column -t
```

### Check the resource requests and limits for all pods in the cluster
```shell
kubectl describe pods | grep -e 'Name:\|Limits\|Requests'
```

### Check the memory usage for specific container in a pod
```shell
kubectl exec -it ${POD_NAME} -c ${CONTAINER_NAME} -- sh -c "free -m"
```

### Check the logs for a specific pod to see if any errors or issues are occurring
```shell
kubectl logs ${POD_NAME}
```

### Check the event log for the cluster to see if any events are being generated related to memory usage
```shell
kubectl get events
```

### Check the cluster autoscaler to see if it is scaling up or down properly based on resource usage
```shell
kubectl get hpa
```

### Check the cluster pods and nodes status
```shell
kubectl get pods,nodes
```

## Repair

### Check the resource requests and limits for the pods running on the Kubernetes cluster to ensure they are properly configured. Adjust any values as necessary, keeping in mind the available resources on the cluster.
```shell
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

```
### Identify and terminate any pods or containers that are using excessive amounts of memory, either due to a memory leak or other issue. This can free up resources for other parts of the cluster.
```shell
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

```