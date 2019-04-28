local getenv = os.getenv

local os, arch

local OS = getenv('OS')
if OS == 'Windows_NT' then
  os = 'win'
  local processor_architecture = getenv('PROCESSOR_ARCHITECTURE')
  if processor_architecture == 'AMD64' then
    arch = '64'
  elseif processor_architecture == 'x86' then
    arch = '32'
  end
else
  local UNAME_S = io.popen('uname -s')
  os = UNAME_S and UNAME_S or 'unknown'

  local UNAME_P = io.popen('uname -p')
  if UNAME_P == 'x86_64' then
    arch = '64'
  elseif UNAME_P:find('x86') then
    arch = '32'
  elseif UNAME_P:find('arm') then
    arch = 'arm'
  else
    arch = ''
  end
end

print(('%s%s'):format(os, arch))
