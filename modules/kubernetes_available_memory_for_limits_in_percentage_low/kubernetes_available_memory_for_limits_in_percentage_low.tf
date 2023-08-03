resource "shoreline_notebook" "kubernetes_available_memory_for_limits_in_percentage_low" {
  name       = "kubernetes_available_memory_for_limits_in_percentage_low"
  data       = file("${path.module}/data/kubernetes_available_memory_for_limits_in_percentage_low.json")
  depends_on = [shoreline_action.invoke_auto_set_resource_limits,shoreline_action.invoke_memory_usage_check]
}

resource "shoreline_file" "auto_set_resource_limits" {
  name             = "auto_set_resource_limits"
  input_file       = "${path.module}/data/auto_set_resource_limits.sh"
  md5              = filemd5("${path.module}/data/auto_set_resource_limits.sh")
  description      = "Check the resource requests and limits for the pods running on the Kubernetes cluster to ensure they are properly configured. Adjust any values as necessary, keeping in mind the available resources on the cluster."
  destination_path = "/agent/scripts/auto_set_resource_limits.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "memory_usage_check" {
  name             = "memory_usage_check"
  input_file       = "${path.module}/data/memory_usage_check.sh"
  md5              = filemd5("${path.module}/data/memory_usage_check.sh")
  description      = "Identify and terminate any pods or containers that are using excessive amounts of memory, either due to a memory leak or other issue. This can free up resources for other parts of the cluster."
  destination_path = "/agent/scripts/memory_usage_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_auto_set_resource_limits" {
  name        = "invoke_auto_set_resource_limits"
  description = "Check the resource requests and limits for the pods running on the Kubernetes cluster to ensure they are properly configured. Adjust any values as necessary, keeping in mind the available resources on the cluster."
  command     = "`chmod +x /agent/scripts/auto_set_resource_limits.sh && /agent/scripts/auto_set_resource_limits.sh`"
  params      = ["NAMESPACE"]
  file_deps   = ["auto_set_resource_limits"]
  enabled     = true
  depends_on  = [shoreline_file.auto_set_resource_limits]
}

resource "shoreline_action" "invoke_memory_usage_check" {
  name        = "invoke_memory_usage_check"
  description = "Identify and terminate any pods or containers that are using excessive amounts of memory, either due to a memory leak or other issue. This can free up resources for other parts of the cluster."
  command     = "`chmod +x /agent/scripts/memory_usage_check.sh && /agent/scripts/memory_usage_check.sh`"
  params      = ["MEMORY_THRESHOLD"]
  file_deps   = ["memory_usage_check"]
  enabled     = true
  depends_on  = [shoreline_file.memory_usage_check]
}

