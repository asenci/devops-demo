output "deploy-url" {
  value = "http://${kubernetes_service_v1.web.status.0.load_balancer.0.ingress.0.hostname}"
}
