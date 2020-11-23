version = "1.0"

plugins {
  id("com.palantir.docker") version ("0.25.0")
  id("com.palantir.docker-run") version ("0.25.0")
}

docker {
  name = "mdahm/${project.name}:${project.version}"
//  tags("latest")

  files("ziptool.sh")
}

dockerRun {
  name = "test"
  image = "mdahm/${project.name}:${project.version}"
  clean = true

  volumes(mapOf("./examples" to "/tmp/ziptool"))
  arguments("-it")
}
