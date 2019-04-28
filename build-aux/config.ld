project = 'ldk-core'
version = '0.1.0'
title = 'ldk-core 0.1.0'
description = 'LDK - Core Libraries'
dir = '../docs'
file = {
  '../src',
  '../csrc',
}
format = 'markdown'
not_luadoc = true
no_lua_ref = true
convert_opt = true
sort = true
sort_modules = true
no_space_before_args = true
merge = false
backtick_references = false
style = '!pale'
template = '.'
custom_tags = {
  {'remark', title = 'Remarks'}
}
new_type('fntype', 'Function Types', false, 'Parameters')
