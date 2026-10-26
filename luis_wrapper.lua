local lw = {}
local new_element_bindings = {
    newLabel = {"text", "width", "height", "y", "x", "align", "theme"},
    newButton = {"text", "width", "height", "on_click", "on_release", "y", "x", "theme"},
    newSlider = {"min", "max", "value", "width", "height", "on_change", "y", "x", "theme"},
    newSwitch = {"value", "width", "height", "on_change", "y", "x", "theme"}
}

for k,v in pairs(new_element_bindings) do
    lw[k] = function(args)
        local in_order = {}
        for i, key in ipairs(v) do
            in_order[i] = args[key]
        end
        local element = luis[k](unpack(in_order, 1, table.maxn(in_order)))
        if args.layer then
            luis.createElement(args.layer, element.type, element)
        end
    end
end

return lw