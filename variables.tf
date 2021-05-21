# terraform-docker-minecraft - variables.tf

variable "image_version" {
  type        = string
  description = <<-DESCRIPTION
  Container image version. This module uses 'itzg/minecraft-server'.
  DESCRIPTION
  default     = "latest"
}

variable "create_volume" {
  type        = bool
  description = "Create a docker volume for minecraft data."
  default     = true
}

variable "volume_name" {
  type        = string
  description = <<-DESCRIPTION
  The name of the data volume. If empty, a name will be automatically generated like this:
  'minecraft_data_{random-uuid}'.
  DESCRIPTION
  default     = ""
}

variable "volume_driver" {
  type        = string
  description = "Storage driver for the data volume."
  default     = "local"
}

variable "volume_driver_opts" {
  type        = map(any)
  description = "Storage driver options for the data volume."
  default     = {}
}

variable "container_cpu_set" {
  type        = string
  description = "Cpu set to allow the container to use. (empty string disables the setting)"
  default     = ""
}

variable "container_cpu_shares" {
  type        = number
  description = "Cpu shares to allow the container to use (<= 0 disables the setting)."
  default     = -1
}

variable "container_memory" {
  type        = number
  description = "Amount of memory to allow the container to use (<= 0 disables the setting)."
  default     = -1
}

variable "container_memory_swap" {
  type        = number
  description = <<-DESCRIPTION
  Total amount of memory (ram + swap) to allow the container to use (<= 0 disables the setting).
  DESCRIPTION
  default     = -1
}

variable "internal_server_port" {
  type        = number
  description = "Internal minecraft server port (must be the same as in 'server.properties')."
  default     = 25565
}

variable "external_server_port" {
  type        = number
  description = "External minecraft server port."
  default     = 25565
}

variable "server_ip" {
  type        = string
  description = "Ip to bind the minecraft server to."
  default     = "0.0.0.0"
}

variable "internal_rcon_port" {
  type        = number
  description = "Internal minecraft rcon port (must be the same as in 'server.properties')."
  default     = 25575
}

variable "external_rcon_port" {
  type        = number
  description = "External minecraft rcon port."
  default     = 25575
}

variable "rcon_ip" {
  type        = string
  description = "Ip to bind the minecraft rcon to."
  default     = "127.0.0.1"
}

variable "start" {
  type        = bool
  description = "Whether to start the container or just create it."
  default     = true
}

variable "restart" {
  type        = string
  description = <<-DESCRIPTION
  The restart policy of the container. Must be one of: "no", "on-failure", "always",
  "unless-stopped".
  DESCRIPTION
  default     = "unless-stopped"
}

variable "container_name" {
  type        = string
  description = <<-DESCRIPTION
  The name of the minecraft container. If empty, one will be generated like this:
  'minecraft_{random-uuid}'.
  DESCRIPTION
  default     = ""
}

variable "server_properties" {
  type        = string
  description = "Contents of the 'server.properties' file. Leave empty for the default properties."
  default     = ""
  sensitive   = true
}

variable "autopause_enable" {
  type        = bool
  description = "Enable server autopause."
  default     = false
}

variable "autopause_timeout_est" {
  type        = number
  description = <<-DESCRIPTION
  Describes the time between the last client disconnect and the pausing of the process (read as
  timeout established).
  DESCRIPTION
  default     = 3600
}

variable "autopause_timeout_init" {
  type        = number
  description = <<-DESCRIPTION
  Time between server start and the pausing of the process, when no client connects inbetween (read
  as timeout initialized).
  DESCRIPTION
  default     = 600
}

variable "autopause_timeout_kn" {
  type        = number
  description = <<-DESCRIPTION
  Time between knocking of the port (e.g. by the main menu ping) and the pausing of the process,
  when no client connects inbetween (read as timeout knocked).
  DESCRIPTION
  default     = 120
}

variable "autopause_timeout_period" {
  type        = number
  description = <<-DESCRIPTION
  Period of the daemonized state machine, that handles the pausing of the process (resuming is done
  independently).
  DESCRIPTION
  default     = 10
}

variable "autopause_knock_interface" {
  type        = string
  description = <<-DESCRIPTION
  Interface passed to the knockd daemon. If the default interface does not work, run the ifconfig
  command inside the container and derive the interface receiving the incoming connection from its
  output. The passed interface must exist inside the container. Using the loopback interface (lo)
  does likely not yield the desired results.
  DESCRIPTION
  default     = "eth0"
}

variable "enable_rolling_logs" {
  type        = bool
  description = <<-DESCRIPTION
  By default the vanilla log file will grow without limit. The logger can be reconfigured to use a
  rolling log files strategy by setting this to 'true'.
  DESCRIPTION
  default     = false
}

variable "use_aikar_flags" {
  type        = bool
  description = <<-DESCRIPTION
  Aikar has does some research into finding the optimal JVM flags for GC tuning, which becomes more
  important as more users are connected concurrently. Set this to 'true' to use those flags.
  When MEMORY is greater than or equal to 12G, then the Aikar flags will be adjusted according to
  the article (https://mcflags.emc.gs/).
  DESCRIPTION
  default     = false
}

variable "use_large_pages" {
  type        = bool
  description = "Large page support can also be enabled by setting this to 'true'."
  default     = false
}

variable "memory_default" {
  type        = string
  description = "Used to adjust both initial (Xms) and max (Xmx) memory heap settings of the JVM."
  default     = "1G"
}

variable "memory_init" {
  type        = string
  description = "Independently set the initial heap size."
  default     = ""
}

variable "memory_max" {
  type        = string
  description = "Independently sets the max heap size."
  default     = ""
}

variable "minecraft_version" {
  type        = string
  description = "Minecraft version to use. Please check container docs."
  default     = "LATEST"
}

variable "timezone" {
  type        = string
  description = "Timezone."
  default     = "Europe/London"
}

variable "uid" {
  type        = number
  description = "Uid to run minecraft with."
  default     = 1000
}

variable "gid" {
  type        = number
  description = "Gid to run minecraft with."
  default     = 1000
}

variable "proxy" {
  type        = string
  description = "Configure the use of an HTTP/HTTPS proxy."
  default     = ""
}

variable "stop_duration" {
  type        = number
  description = <<-DESCRIPTION
  When the container is signalled to stop, the Minecraft process wrapper will attempt to send a
  "stop" command via RCON or console and waits for the process to gracefully finish. By default it
  waits 60 seconds, but that duration can be configured by setting this variable to another number
  of seconds.
  DESCRIPTION
  default     = 60
}

variable "labels" {
  type        = map(string)
  description = "Labels to attach to created resources that support labels."
  default     = {}
}
