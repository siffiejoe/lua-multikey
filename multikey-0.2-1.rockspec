package = "multikey"
version = "0.2-1"
source = {
  url = "${SRCURL}",
}
description = {
  summary = "A simple multidimensional table.",
  detailed = [[
    This small Lua module allows to store values indexed by
    multiple keys.
  ]],
  homepage = "${HPURL}",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1, <= 5.2"
}
build = {
  type = "builtin",
  modules = {
    [ "multikey" ]         = "src/multikey.lua",
    [ "multikey.memoize" ] = "src/multikey/memoize.lua"
  }
}

