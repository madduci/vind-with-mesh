resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = var.namespace
  }
}

locals {
  target_namespace = kubernetes_namespace_v1.istio_system.metadata[0].name
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  chart      = "base"
  repository = var.helm_repository
  version    = var.helm_version
  namespace  = local.target_namespace
  lint       = true
  atomic     = true
  wait       = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  chart      = "istiod"
  repository = var.helm_repository
  version    = var.helm_version
  namespace  = local.target_namespace
  lint       = true
  atomic     = true
  wait       = true

  set = concat([
    {
      name  = "autoscaleEnabled"
      value = "false"
    },
    {
      name  = "autoscaleMin"
      value = var.replica_count
    },
    {
      name  = "global.logAsJson"
      value = "true"
    },
    {
      name  = "replicaCount"
      value = var.replica_count
    },
    {
      name  = "traceSampling"
      value = var.trace_sampling
    },
    {
      name  = "global.proxy.tracer"
      value = var.tracer_type
    }
    ],
    var.tracer_type != "none" ? [{
      name  = "meshConfig.tracing.${var.tracer_type}.address"
      value = var.tracer_address
    }] : [],
    var.enable_ambient_mode ? [{
      name  = "profile"
      value = "ambient"
  }] : [])

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingressgateway" {
  count      = var.enable_ambient_mode ? 0 : 1
  name       = "istio-ingressgateway"
  chart      = "gateway"
  repository = var.helm_repository
  version    = var.helm_version
  namespace  = local.target_namespace
  lint       = true
  atomic     = true
  wait       = true

  depends_on = [helm_release.istiod]

  values = [<<-YAML
    labels:
      ingress-ready: "true"
  YAML  
  ]

  set = [
    {
      name  = "autoscaling.enabled"
      value = "false"
    },
    {
      name  = "service.type"
      value = "LoadBalancer"
    },
    {
      name  = "replicaCount"
      value = var.replica_count
    }
  ]
}

resource "helm_release" "istio_egressgateway" {
  count      = var.enable_ambient_mode ? 0 : 1
  name       = "istio-egressgateway"
  chart      = "gateway"
  repository = var.helm_repository
  version    = var.helm_version
  namespace  = local.target_namespace
  lint       = true
  atomic     = true
  wait       = true

  depends_on = [helm_release.istiod]

  values = [<<-YAML
    labels:
      ingress-ready: "true"
  YAML  
  ]

  set = [{
    name  = "autoscaling.enabled"
    value = "false"
    },
    {
      # Egress gateways do not need an external LoadBalancer IP
      name  = "service.type"
      value = "ClusterIP"
  }]
}

resource "helm_release" "istio_cni" {
  name       = "istio-cni"
  chart      = "cni"
  repository = var.helm_repository
  version    = var.helm_version
  namespace  = "istio-system"
  lint       = true
  atomic     = true
  wait       = true

  set = concat(var.enable_ambient_mode ? [{
    name  = "profile"
    value = "ambient"
  }] : [])

  depends_on = [helm_release.istio_base]
}

data "kubernetes_service_v1" "istio_ingress" {
  count = var.enable_ambient_mode ? 0 : 1
  metadata {
    name      = "istio-ingressgateway"
    namespace = local.target_namespace
  }

  depends_on = [helm_release.istio_ingressgateway]
}

resource "helm_release" "istio_ztunnel" {
  count = var.enable_ambient_mode ? 1 : 0

  name       = "istio-ztunnel"
  chart      = "ztunnel"
  repository = var.helm_repository
  version    = var.helm_version
  namespace  = "istio-system"
  lint       = true
  atomic     = true
  wait       = true

  depends_on = [helm_release.istio_cni]
}