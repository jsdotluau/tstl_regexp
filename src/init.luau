local polyfill = require("@pkg/polyfill")
local regex = require("@self/regex")

local RegExp = polyfill.__TS__Class()
RegExp.name = "RegExp"
RegExp.length = 2

local flagMap = {
	dotAll = "s",
	global = "g",
	hasIndices = "d",
	ignoreCase = "i",
	multiline = "m",
	sticky = "y",
	unicode = "u",
	unicodeSets = "v",
}

type RegExp = typeof(polyfill.__TS__New(RegExp))
function RegExp.prototype.____constructor(self: RegExp, pattern: (string | RegExp)?, flags: string?)
	if pattern == nil then
		pattern = "(?:)"
	end
	self.__regexp = regex.new(if type(pattern) == "string" then pattern else pattern.__regexp, flags)
	self.lastIndex = 0

	local flagArr = string.split(flags or "", "")
	table.sort(flagArr)
	self.flags = table.concat(flagArr, "")
	self.source = pattern -- does not escape newlines

	for property, flag in flagMap do
		self[property] = string.find(self.flags, flag :: any) ~= nil
	end
end

function RegExp.escape(pattern: string): string
	return regex.escape(pattern)
end

function RegExp.prototype.exec(
	self: RegExp,
	str: string
): ({ string } & { index: string, input: string, groups: { [string]: string }? })?
	local match = self.__regexp:match(str)
	if not match then
		self.lastIndex = 0
		return nil
	end

	local index, endIndex = match:span()
	local groups = match:grouparr()

	local matches = { groups[0] }
	matches.length = groups.n + 1
	for i = 1, groups.n do
		matches[i + 1] = groups[i]
	end

	matches.index = index
	matches.input = str

	local namedGroups = match:groupdict()
	if next(namedGroups) then
		matches.groups = {}
		for name, group in namedGroups do
			matches.groups[name] = group
		end
	end

	self.lastIndex = endIndex
	return matches
end

function RegExp.prototype.test(self: RegExp, str: string): boolean
	return self:exec(str) ~= nil
end

function RegExp.prototype.__tostring(self: RegExp): string
	return tostring(self.__regexp)
end

return RegExp
