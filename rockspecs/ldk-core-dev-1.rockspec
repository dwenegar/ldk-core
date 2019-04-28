rockspec_format = '3.0'

package = 'ldk-core'
version = 'dev-1'
source = {
  url = 'git://github.com/luadevkit/ldk-core.git',
  branch = 'dev'
}
description = {
  summary = 'Core Libraries',
  license = 'MIT',
  maintainer = 'simone.livieri@gmail.com'
}
dependencies = {
  'lua = 5.3',
}
build = {
  modules = {
    ['ldk.array'] = 'src/ldk/array.lua',
    ['ldk.func'] = 'src/ldk/func.lua',
    ['ldk.predicates'] = 'src/ldk/predicates.lua',
    ['ldk.stringx'] = 'src/ldk/stringx.lua',
    ['ldk.tablex'] = 'src/ldk/tablex.lua',
    ['ldk.array.native'] = 'csrc/array.c',
    ['ldk.debugx'] = 'csrc/debugx.c',
  },
}

test = {
  type = 'busted'
}
