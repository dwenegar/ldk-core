cache = true
codes = true
module = true
allow_defined_top = true
ignore = { '_ENV' }
std = 'lua53+busted+ldoc'
files = {
  ['spec'] = {
    max_line_length = 200,
    allow_defined = true
  },
  ['spec/debugx_spec.lua'] = {
    ignore = {
      '111'
    }
  }
}
