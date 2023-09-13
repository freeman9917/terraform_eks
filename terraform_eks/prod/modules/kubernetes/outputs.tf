output "kubernetes_namespace" {
    description = "Kubernetes Namespace Name"
    value = kubernetes_namespace.hello_world_namespace.metadata.0.name
}