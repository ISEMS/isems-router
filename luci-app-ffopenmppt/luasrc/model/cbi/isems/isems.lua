m = Map("ffopenmppt", "Freifunk-Open-MPPT")

s = m:section(TypedSection, "ffopenmppt", "Solar controller setup")

p = s:option(Value, "powersave", "Powersave Level")
p:value("0", "No energy saving")
p:value("1", "Set power_save in WiFi drivers")
p:value("2", "Stop secondary radio")
p:value("3", "2 min on/off on demand")
p:value("4", "5 min on/off on demand")
p:value("5", "WiFi 4h off at 00:00")
p:value("6", "Power 5h off at 00:00")

p = s:option(Value, "solar_module_capacity", "Solar module power in Watt")
p = s:option(Value, "maximum_power_consumption", "Maximum power consumption of router in Ampere")
p = s:option(Value, "rated_batt_capacity", "Rated battery capacity in Amperehours (Ah)")
p = s:option(Value, "serial_port", "Serial communication port")
p = s:option(Value, "powersave_interface", "Secondary radio phy number")

return m

