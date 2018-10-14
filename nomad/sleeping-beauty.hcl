job "sleeping-beauty" {
  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  region = "global"

  # Spread the tasks in these datacenters based on the Nomad server' configuration.
  datacenters = ["dc1"]

  # Run this job as a "service" type. Each job type has different
  # properties. See the documentation below for more examples.
  type = "batch"

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "sb-group" {
    # Specify the number of these tasks we want.
    count = 10000

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "sb-task" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "tianon/sleeping-beauty"
      }

      # Specify the maximum resources required to run the task,
      # include CPU, memory, and bandwidth.
      resources {
        cpu    = 20 # MHz
        memory = 10 # MB
      }
    }
  }
}
