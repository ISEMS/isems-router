m = Map("ffopenmppt", "Freifunk-Open-MPPT")

s = m:section(TypedSection, "ffopenmppt", "Solar controller setup")

p = s:option(Value, "powersave", "Powersave Level")
p:value("0", "Normal operation")
p:value("1", "No LAN")
p:value("2", "No LAN, no secondary WLAN")
p:value("3", "On/off at night via crond")
p:value("4", "5min on/off on demand")

p = s:option(Value, "solar_module_capacity", "Solar module power in Watt")
p = s:option(Value, "maximum_power_consumption", "Maximum power consumption of router in Ampere")
p = s:option(Value, "rated_batt_capacity", "Rated battery capacity in Amperehours (Ah)")
p = s:option(Value, "serial_port", "Serial communication port")
p = s:option(Value, "powersave_interface", "First radio interface")

return m

