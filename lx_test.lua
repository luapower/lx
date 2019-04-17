--go@ luajit *
local glue = require'glue'
local clock = require'time'.clock
local fs = require'fs'
local lx = require'lx'

local out = function(s) io.stdout:write(s) end
local printf = function(...) out(string.format(...)) end

local function test_speed_for(filename)
	local f = assert(fs.open(filename))
	local fs = assert(f:stream'rb')
	local ls = lx.lexer(fs, filename)

	local out = glue.noop
	local printf = glue.noop

	local t0 = clock()
	ls:luastats()
	local n = ls:token_count()
	local ln = ls:line()
	local d = clock() - t0

	ls:free()
	fs:close()
	f:close()

	return d, n, ln
end

local function test_speed()
	local d, n, l = 0, 0, 0
	for i=1,20 do
		local d1, n1, l1 = test_speed_for'ui.lua'
		d = d + d1
		n = n + n1
		l = l + l1
	end
	print(string.format(
		'%.1fs %.1f Mtokens/s %.1f Mlines/s', d, n / d / 1e6, l / d / 1e6))
end
test_speed()

local function test_import()

	local s = [[
		do
			import 'test1'
			do
				import 'test2'
				key2
			end
			key1
			key2
		end
	]]

	local s = [[

		if 1 then end
		do return end

	]]

	local ls = lx.lexer(s)

	function ls:import(lang)
		if lang == 'test1' then
			return {entrypoints = {'key1'}}
		elseif lang == 'test2' then
			return {entrypoints = {'key2'}}
		end
	end

	local st = ls:luastats()

end
--test_import()
