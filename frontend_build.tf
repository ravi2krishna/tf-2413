# Build LMS Frontend Image
resource "docker_image" "lms-fe" {
  name = "ravi2krishna/lms-fe"
  build {
    context = "."
    tag     = ["ravi2krishna/lms-fe:latest"]
    label = {
      author : "Ravi"
    }
  }
}

# Start LMS Frontend Container
resource "docker_container" "lms-fe-container" {
  image = docker_image.lms-fe.image_id
  name  = "lms-frontend"
  ports {
    internal = 80
    external = 80
    ip       = "0.0.0.0"
  }
}
