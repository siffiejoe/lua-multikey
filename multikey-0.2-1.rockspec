package = "multikey"
version = "0.2-1"
source = {
  url = "git://github.com/siffiejoe/lua-multikey.git",
  tag = "v0.2",
}
description = {
  summary = "A simple multidimensional table.",
  detailed = [[
    This small Lua module allows to store values indexed by
    multiple keys.
  ]],
  homepage = "http://siffiejoe.github.io/lua-multikey/",
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

