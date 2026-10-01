local process = require("@lune/process")

local function run(program, args)
	local result = process.spawn(program, args)
	io.write(result.stdout)
	io.stderr:write(result.stderr)
	assert(result.ok, program .. " failed with exit code " .. tostring(result.code))
end

run("stylua", { "--check", "src", "tests", "scripts" })
run("selene", { "src" })
run("lune", { "run", "tests/Economy.spec.luau" })
run("mkdir", { "-p", "build" })
run("rojo", { "build", "default.project.json", "--output", "build/CrystalRush.rbxlx" })
print("Verification passed.")
