cache = true
codes = true
module = true
allow_defined_top = true
ignore = { '_ENV' }
std = 'lua53'
files = {
  ['spec'] = {
    max_line_length = 200
  },
  ['spec/debugx_spec.lua'] = {
    ignore = {
      '111'
    }
  }
}
