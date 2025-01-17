type imageSettings = {
  name: string?
  baseImage: string?
  shouldBuild: bool
}

@export()
type images = {
  eShop: imageSettings?
  axios: imageSettings?
  MSBuildSdks: imageSettings?
}

type imageResult = {
  buildLog: string?
  stagingResourceGroupName: string?
}

@export()
type results = {
  eShop: imageResult
  axios: imageResult
  MSBuildSdks: imageResult
}

@export()
type artifactSource = {
  Url: string
  Branch: string
  Path: string
}
