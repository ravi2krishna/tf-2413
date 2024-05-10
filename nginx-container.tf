# Pull Image
resource "docker_image" "web-server" {
  name = "nginx"
}

# Start Container
resource "docker_container" "c1" {
  image = docker_image.web-server.image_id
  name  = "nginx-container"
  ports {
    internal = 80
    external = 8080
    ip       = "0.0.0.0"
  }
}
