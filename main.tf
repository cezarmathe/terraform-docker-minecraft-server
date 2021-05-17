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
}


resource "docker_container" "minecraft" {
  name  = local.container_name
  image = docker_image.minecraft.latest

  env = [for k, v in local.env : format("%s=%s", k, v) if v != ""]

  # fixme 17/05/2021: container resource limits
  cpu_set     = var.cpu_set
  memory      = var.container_memory
  memory_swap = var.container_memory * 2

  # fixme 17/05/2021: container healthcheck tuning
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
    enable = var.autopause.enable ? (
      upper(format("%s", true))
    ) : ""
    timeout_est = var.autopause.enable ? (
      format("%s", var.autopause.timeout_est)
    ) : ""
    timeout_init = var.autopause.enable ? (
      format("%s", var.autopause.timeout_init)
    ) : ""
    timeout_kn = var.autopause.enable ? (
      format("%s", var.autopause.timeout_kn)
    ) : ""
    timeout_period = var.autopause.enable ? (
      format("%s", var.autopause.timeout_period)
    ) : ""
    knock_interface = var.autopause.enable ? var.autopause.knock_interface : ""
  }

  enable_rolling_logs = var.enable_rolling_logs ? upper(format("%s", true)) : ""
  use_aikar_flags     = var.use_aikar_flags ? format("%s", true) : ""
  use_large_pages     = var.use_large_pages ? format("%s", true) : ""

  env = {
    MEMORY                    = var.memory.default
    INIT_MEMORY               = var.memory.init
    MAX_MEMORY                = var.memory.max
    EULA                      = upper(format("%s", true))
    VERSION                   = var.version
    TZ                        = var.timezone
    ENABLE_AUTOPAUSE          = local.autopause.enable
    AUTOPAUSE_TIMEOUT_EST     = local.autopause.timeout_est
    AUTOPAUSE_TIMEOUT_INIT    = local.autopause.timeout_init
    AUTOPAUSE_TIMEOUT_KN      = local.autopause.timeout_kn
    AUTOPAUSE_PERIOD          = local.autopause.period
    AUTOPAUSE_KNOCK_INTERFACE = local.autopause.knock_interface
    UID                       = var.uid
    GID                       = var.gid
    ENABLE_ROLLING_LOGS       = local.enable_rolling_logs
    USE_AIKAR_FLAGS           = true
    USE_LARGE_PAGES           = true
    PROXY                     = var.proxy
    GUI                       = upper(format("%s", false))
    STOP_DURATION             = var.stop_duration
  }
}
