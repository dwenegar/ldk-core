rockspec_format = '3.0'

package = 'ldk-core'
version = '0.2.1-1'
source = {
  url = 'git://github.com/luadevkit/ldk-core.git',
  branch = '0.2.1'
}
description = {
  summary = 'LDK - core modules',
  license = 'MIT',
  maintainer = 'info@luadevk.it'
}
dependencies = {
  'lua >= 5.3'
}
build = {
  modules = {
    ['ldk._base'] = 'src/ldk/_base.lua',
    ['ldk.array'] = 'src/ldk/array.lua',
    ['ldk.debugx'] = 'src/ldk/debugx.lua',
    ['ldk.stringx'] = 'src/ldk/stringx.lua',
    ['ldk.tablex'] = 'src/ldk/tablex.lua',
    ['ldk.func'] = 'src/ldk/func.lua',
  }
}
test = {
  type = 'busted'
}
