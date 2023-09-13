provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}




resource "kubernetes_deployment" "hello_world_deployment" {
  metadata {
    name = "kubernetes-example-deployment"
    namespace = kubernetes_namespace.hello_world_namespace.metadata.0.name
    labels = {
      app = "hello-world-example"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "hello-world-example"
      }
    }
    template {
      metadata {
        labels = {
          app = "hello-world-example"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "hello-world"
        }
      }
    }
  }
}



resource "kubernetes_service" "hello_world_service" {
  depends_on = [kubernetes_deployment.hello_world_deployment]

  metadata {
    labels = {
      app = "hello-world-example"
    }
    name = "hello-world-example"
    namespace = kubernetes_namespace.hello_world_namespace.metadata.0.name
  }

  spec {
    port {
      name = "api"
      port = 80
      target_port = 80
    }
    selector = {
      app = "hello-world-example"
    }
    type = "ClusterIP"
  }
}


resource "kubernetes_namespace" "hello_world_namespace" {
  metadata {
    labels = {
      app = "hello-world-example"
    }
    name = "hello-world-namespace"
  }
}


resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    labels = {
      app = "ingress-nginx"
    }
    name = "api-ingress"
    namespace = kubernetes_namespace.hello_world_namespace.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class": "nginx-hello-world-namespace"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = "hello-world-example"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}


