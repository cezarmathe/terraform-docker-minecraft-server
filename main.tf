# terraform-docker-minecraft - main.tf

resource "random_uuid" "this" {}

data "docker_registry_image" "this" {
  name = "itzg/minecraft-server:${var.image_version}"
}

resource "docker_image" "this" {
  name          = data.docker_registry_image.this.name
  pull_triggers = [data.docker_registry_image.this.sha256_digest]
}

resource "docker_volume" "this" {
  count = var.create_volume ? 1 : 0

  name        = local.volume_name
  driver      = var.volume_driver
  driver_opts = var.volume_driver_opts

  dynamic "labels" {
    for_each = var.labels
    iterator = label
    content {
      label = label.key
      value = label.value
    }
  }
}

resource "docker_container" "this" {
  name  = local.container_name
  image = docker_image.this.latest

  env = [for k, v in local.env : format("%s=%s", k, v) if v != ""]

  cpu_set     = local.container_cpu_set
  cpu_shares  = local.container_cpu_shares
  memory      = local.container_memory
  memory_swap = local.container_memory_swap

  # fixme 17/05/2021: container healthcheck tuning options
  healthcheck {
    interval     = "0s"
    retries      = 0
    start_period = "1m0s"
    test = [
      "CMD-SHELL",
      "/health.sh",
    ]
    timeout = "0s"
  }

  ports {
    internal = var.internal_server_port
    external = var.external_server_port
    ip       = var.server_ip
  }

  ports {
    internal = var.internal_rcon_port
    external = var.external_rcon_port
    ip       = var.rcon_ip
  }

  upload {
    file    = "/data/server.properties"
    content = local.server_properties
  }

  dynamic "volumes" {
    for_each = docker_volume.this
    iterator = volume
    content {
      volume_name    = volume.value.name
      container_path = "/data"
    }
  }

  dynamic "labels" {
    for_each = var.labels
    iterator = label
    content {
      label = label.key
      value = label.value
    }
  }

  must_run = true
  restart  = var.restart
  start    = var.start
}

locals {
  volume_name = var.volume_name != "" ? var.volume_name : (
    "minecraft_data_${random_uuid.this.result}"
  )

  container_name = var.container_name != "" ? var.container_name : (
    "minecraft_${random_uuid.this.result}"
  )

  server_properties = var.server_properties != "" ? var.server_properties : (
    file("server.properties")
  )

  autopause = {
    enable = var.autopause_enable ? (
      upper(format("%s", true))
    ) : ""
    timeout_est = var.autopause_enable ? (
      format("%s", var.autopause_timeout_est)
    ) : ""
    timeout_init = var.autopause_enable ? (
      format("%s", var.autopause_timeout_init)
    ) : ""
    timeout_kn = var.autopause_enable ? (
      format("%s", var.autopause_timeout_kn)
    ) : ""
    timeout_period = var.autopause_enable ? (
      format("%s", var.autopause_timeout_period)
    ) : ""
    knock_interface = var.autopause_enable ? var.autopause_knock_interface : ""
  }

  uid                 = var.uid != 1000 ? format("%s", var.uid) : ""
  gid                 = var.gid != 1000 ? format("%s", var.gid) : ""
  enable_rolling_logs = var.enable_rolling_logs ? upper(format("%s", true)) : ""
  use_aikar_flags     = var.use_aikar_flags ? format("%s", true) : ""
  use_large_pages     = var.use_large_pages ? format("%s", true) : ""
  stop_duration       = var.stop_duration != 60 ? format("%s", var.stop_duration) : ""

  env = {
    MEMORY                    = var.memory_default
    INIT_MEMORY               = var.memory_init
    MAX_MEMORY                = var.memory_max
    EULA                      = upper(format("%s", true))
    VERSION                   = var.minecraft_version
    TZ                        = var.timezone
    ENABLE_AUTOPAUSE          = local.autopause.enable
    AUTOPAUSE_TIMEOUT_EST     = local.autopause.timeout_est
    AUTOPAUSE_TIMEOUT_INIT    = local.autopause.timeout_init
    AUTOPAUSE_TIMEOUT_KN      = local.autopause.timeout_kn
    AUTOPAUSE_PERIOD          = local.autopause.timeout_period
    AUTOPAUSE_KNOCK_INTERFACE = local.autopause.knock_interface
    UID                       = local.uid
    GID                       = local.gid
    ENABLE_ROLLING_LOGS       = local.enable_rolling_logs
    USE_AIKAR_FLAGS           = local.use_aikar_flags
    USE_LARGE_PAGES           = local.use_large_pages
    PROXY                     = var.proxy
    GUI                       = upper(format("%s", false))
    STOP_DURATION             = local.stop_duration
  }

  container_cpu_set     = var.container_cpu_set != "" ? var.container_cpu_set : null
  container_cpu_shares  = var.container_cpu_shares > 0 ? var.container_cpu_shares : null
  container_memory      = var.container_memory > 0 ? var.container_memory : null
  container_memory_swap = var.container_memory > 0 ? var.container_memory : null
}
