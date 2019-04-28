local function usage_and_exit()
  print(("Usage: %s input-file output-file key=value key=value"):format(arg[0]))
  os.exit(1)
end

local input, output = arg[1], arg[2]
if not input or not output then
  usage_and_exit()
end

local function open_file(filename, mode)
  local file, err = io.open(filename, mode)
  if err then
    error(err)
  end
  return file
end

local function read_input()
  local file = open_file(input)
  local text, err = file:read('a')
  if err then
    error(err)
  end
  file:close()
  return text
end

local function write_output(text)
  local file = open_file(output, 'w+b')
  local _, err = file:write(text)
  if err then
    error(err)
  end
  file:close()
end

local function replace_values(text)
  local repl = {}
  for i = 3, #arg do
    local kvp = arg[i]
    local key, value = kvp:match('^([^=]+)=(.+)$')
    if not key then
      usage_and_exit()
    end
    repl[key] = value
  end
  return text:gsub('@([%a_]+)@', repl)
end

local text = read_input()
text = replace_values(text)
write_output(text)
