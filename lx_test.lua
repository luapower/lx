
local glue = require'glue'
local clock = require'time'.clock
local fs = require'fs'
local C = require'lx'

local out = function(s) io.stdout:write(s) end
local printf = function(...) out(string.format(...)) end

local function test(f)
	local f = assert(fs.open'ui.lua')
	local fs = assert(f:stream'rb')
	local ls = C.lx_state_create_for_file(fs)

	local out = glue.noop
	local printf = glue.noop

	local t0 = clock()
	local n = 0
	while true do
		local tok = ls:next(); n = n + 1
		if tok == C.TK_EOF then
			break
		elseif tok == C.TK_ERROR then
			error(ls:errmsg())
		elseif tok == C.TK_NUMBER then
			local fmt = ls:numtype()
			if fmt == C.STRSCAN_NUM then
				printf('%f ', ls:num())
			elseif fmt == C.STRSCAN_IMAG then
				printf('imag NYI ')
			elseif fmt == C.STRSCAN_INT then
				printf('%d ', ls:int())
			elseif fmt == C.STRSCAN_U64 then
				printf('%d ', ls:ulong())
			else
				assert(false)
			end
		elseif tok == C.TK_NAME or tok == C.TK_STRING or tok == C.TK_LABEL then
			out(ls:string()); out' '
		elseif tok == C.TK_EQ     then out'= '
		elseif tok == C.TK_LE     then out'<= '
		elseif tok == C.TK_GE     then out'>= '
		elseif tok == C.TK_NE     then out'~= '
		elseif tok == C.TK_DOTS   then out'... '
		elseif tok == C.TK_CONCAT then out'.. '
		elseif tok == C.TK_SHL    then out'<< '
		elseif tok == C.TK_SHR    then out'>> '
		else
			out(string.char(tok)); out' '
		end
	end
	out'\n'
	local ln = ls:line()
	local d = clock() - t0

	ls:free()
	fs:close()
	f:close()

	return d, n, ln
end

local d, n, l = 0, 0, 0
for i=1,1000 do
	local d1, n1, l1 = test()
	d = d + d1
	n = n + n1
	l = l + l1
end
print(string.format(
	'%.1fs %.1f Mtokens/s %.1f Mlines/s', d, n / d / 1e6, l / d / 1e6))
