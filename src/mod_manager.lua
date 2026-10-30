love.filesystem.setIdentity("minesweeperInfinity")
love.filesystem.createDirectory("mods")

local function get_mod_info(mod, builtin)
    local info = {}

    local info_location = (builtin and "src/builtin_mods/" or "mods/") .. mod .. "/info.lua"
    local load_ok, chunk, err = pcall(love.filesystem.load, info_location)
    if load_ok and chunk then
        local call_ok, returned = pcall(chunk)
        if call_ok then
            info = returned
        end
    else
        info = { load_failed = true, error = err }
    end
    info.builtin = builtin
    return info
end

local function get_mods_info()
    local mods = {}
    for _, v in pairs(love.filesystem.getDirectoryItems("mods")) do
        mods[v] = get_mod_info(v)
    end

    for _, v in pairs(love.filesystem.getDirectoryItems("src/builtin_mods")) do
        mods[v] = get_mod_info(v, true)
    end

    for k, v in pairs(mods) do
        if (not v.name) or (not v.author) then
            v.load_failed = true
            v.error = "Missing name or author."
        end

        if not v.load_failed then
            v.main_file_path = (v.builtin and "src/builtin_mods/" or "mods/") .. k .. "/" .. (v.main_file or "main.lua")
        end
    end
    return mods
end

local function load_mods(mods)
    for k, v in pairs(mods) do
        if v.main_file_path then
            local chunk, err = load(love.filesystem.read(v.main_file_path), k)
            if chunk then
                CURRENT_MOD = v
                local _, run_err = pcall(chunk)
                CURRENT_MOD = nil
                if run_err then
                    v.load_failed = true
                    v.exec_failed = true
                    v.err = run_err
                end
            else
                v.load_failed = true
                v.exec_failed = true
                v.err = err
            end
        end
    end
end

local function generate_error(mod)
    local str = ""
    if mod.exec_failed then
        str = mod.name .. " execution failed. "
    else
        str = mod.name .. " load failed. "
    end
    str = str .. "Error: \n " .. mod.err
    return str
end

local mods = get_mods_info()
load_mods(mods)

-- print_table(mods)

for k, v in pairs(mods) do
    if v.load_failed then
        print(generate_error(v))
    else
        print(v.name .. " load success!")
    end
end

return mods
