mp.observe_property("pause", "bool", function(_, val)
    if val ~= nil then
        mp.osd_message(val and "󰏤" or "󰐊", 1.5)
    end
end)

mp.observe_property("volume", "number", function(_, val)
    if val ~= nil then
        mp.osd_message("󰕾 " .. val .. "%", 1.5)
    end
end)

mp.observe_property("mute", "bool", function(_, val)
    if val ~= nil then
        mp.osd_message(val and "󰖁" or "󰕾", 1.5)
    end
end)

mp.observe_property("sub-visibility", "bool", function(_, val)
    if val ~= nil then
        mp.osd_message("󰨖 " .. (val and "visible" or "hidden"), 1.5)
    end
end)
