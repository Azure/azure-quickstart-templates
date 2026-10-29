targetScope = 'subscription'

// Intentionally empty. Callers put their diagnostics validation in this module's deployment name,
// which ARM evaluates during template validation, so invalid input is rejected before deployment.
output validated bool = true
