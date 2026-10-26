love.filesystem.setIdentity("minesweeperInfinity")
love.filesystem.createDirectory("mods")

local function get_mod_info()
    local mods = {}
    for _, v in pairs(love.filesystem.getDirectoryItems("mods")) do
        local info_location = "mods/" .. v .. "/info.lua"
        local load_ok, chunk, err = pcall(love.filesystem.load, info_location)
        if load_ok and chunk then
            local call_ok, info = pcall(chunk)
            if call_ok then
                mods[v] = info
            end
        else
            mods[v] = {load_failed = true, error = err}
        end
    end

    for k,v in pairs(mods) do
        if (not v.name) or (not v.author) then
            v.load_failed = true
            v.error = "Missing name or author."
        end

        if not v.load_failed then
            v.main_file_path = "mods/" .. k .. "/" .. (v.main_file or "main.lua")
        end
    end
    return mods
end

local function load_mods(mods)
    for k,v in pairs(mods) do
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
    str = str ..  "Error: \n " .. mod.err
    return str
end

local mods = get_mod_info()
load_mods(mods)

-- print_table(mods)

for k,v in pairs(mods) do
    if v.load_failed then
        print(generate_error(v))
    else
        print(v.name .. " load success!")
    end
end

return mods