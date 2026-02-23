{
  fetchFromGitHub,
}:

# zbench is a Zig benchmarking library used as a build dependency.
# This derivation provides the source for other packages to reference.
fetchFromGitHub {
  owner = "hendriknielaender";
  repo = "zbench";
  rev = "ad7ccbdb06476affc512c12574b54f7d4386622c";
  hash = "sha256-g7Dl2+LxIqtffm5yqzA0iPszb2o6AAOMb/6W5i1XSMA=";
}
