
--[[

Lua source code for ISEMS (Independent Solar Energy Mesh System)
Copyright (C) 2018  by Corinna 'Elektra' Aichele 

This file is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.
 
This source code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this source file. If not, see http://www.gnu.org/licenses/. 
    
This is the Lua companion app that reads, analyzes and prepares the data from the Freifunk-Open-MPPT-Solarcontroller.
The output is a CSV file, seperated by semicolon, a simple HTML page and a JSON data set stored in /tmp/ISEMS of 
the router.

The communication and storage data output revision 1 uses the following format:

Data fields
===========

01 Node-ID = nodeid;
02 ISEMS-Paket-Format-Revision = packetrev;
03 Epoch-Timestamp = timestamp;
04 FREIFUNK-OPEN-MPPT-Firmware-Version and controller type = firmware_type;
05 Time-until-next-scheduled-power-shutdown (in minutes) = nextreboot;
06 Power-save-mode-of-Router On=1/Off=0;
07 Measured Solarmodule-Open-Circuit-Voltage V_oc, Value Volt DC;
08 Measured Solar-MPP-Voltage V_in, Value Volt DC ;
09 Battery voltage V_out, Value Volt DC;
10 Battery Charge State estimate (in percent);
11 Battery Health estimate (in percent);
12 Battery temperature in Celsius;
13 Low Voltage Disconnect Voltage, Value Volt DC;
14 Temperature corrected charge end Voltage, Value Volt DC;
15 Rated Battery_Capacity in Amperehours Ah;
16 Rated Solar module capacity in W;
17 Latitude;
18 Longitude;
19 Status code
    

    
ISEMS bit error codes, big endian.
##################################
     
     Bit_0: 1 = Charging
            0 = 
   
     Bit_1: 1 = Discharging
            0 = 
     
     Bit_2: 1 = Fully charged
            0 = 
   
     Bit_3: 1 = Healthy
            0 = 

     Bit_4: 1 = Warning: Battery level low. Increased battery wear.
            0 = 
   
     Bit_5: 1 = Error: Energy storage capacity too small. Check battery size and/or wear.
            0 = 
        
     Bit_6: 1 = Warning: Temperature sensor not connected.
            0 = 
            
     Bit_7: 1 = Error: No communication with solar controller.
            0 = 
   
     Bit_8: 1 = Battery overheating.
            0 = 
   
     Bit_9: 1 = Low battery temperature.
            0 =
   
     Bit_10: 1 = Firmware upgrade not allowed
             0 = 
   
     Bit_11: 1 = 
             0 = 

]]

charge_state = 0

Bit_0  = 0
Bit_1  = 0
Bit_2  = 0
Bit_3  = 0
Bit_4  = 0
Bit_5  = 0
Bit_6  = 0
Bit_7  = 0
Bit_8  = 0
Bit_9  = 0
Bit_10 = 0
Bit_11 = 0

-- Read measurement data from files

function collect_measurement_data (search_numeric_data_string, searchfile, result) 
    local result = 0
    file = io.open(searchfile, "r")
    if file == nil then return 0 end
    io.input(file)
    t = io.read("*all")
    v = string.match(t, search_numeric_data_string)
    if v == nil or v == ''
    then v = 0
    end
    result = string.match(v, "%d+")
    io.close(file)
    return result
end

function collect_char_data (search_char_data_string, i, searchfile, result) 
    local result = "" 
    file = io.open(searchfile, "r")
    if file == nil then return 0 end
    io.input(file)
    t = io.read("*all")
    v = string.match(t, search_char_data_string)
    if v == nil or v == ''
    then v ="0.0"
    end
    result = string.sub(v, i)
    io.close(file)
    return result
end

-- Read configuration data using uci.

local f = io.popen("uci get system.@system[0].hostname", "r")
for entry in f:lines() do    
nodeid = entry
end

packetrev = "1" 

-- Get timestamp

local f = io.popen("date +%s", "r")
for entry in f:lines() do
timestamp = entry
end

nextreboot = collect_measurement_data("Minutes until load off: %d+", "/tmp/mppt.log", result)

powersave = 0
local f = io.popen("uci get ffopenmppt.@ffopenmppt[0].powersave ", "r")
for entry in f:lines() do
powersave = entry
end



solar_module_capacity = 0
local f = io.popen("uci get ffopenmppt.@ffopenmppt[0].solar_module_capacity ", "r")
for entry in f:lines() do
solar_module_capacity = entry
end


rated_batt_capacity = 0
local f = io.popen("uci get ffopenmppt.@ffopenmppt[0].rated_batt_capacity ", "r")
for entry in f:lines() do
rated_batt_capacity = entry
end

lat = 0
local f = io.popen("uci get system.@system[0].latitude", "r")
for entry in f:lines() do
lat = entry
end

long = 0
local f = io.popen("uci get system.@system[0].longitude", "r")
for entry in f:lines() do
long = entry
end

V_oc = collect_measurement_data ("V_in_idle.%d+", "/tmp/mppt.log", result)
V_oc = V_oc/1000

V_in = collect_measurement_data ("V_in.%d+", "/tmp/mppt.log", result)
V_in = V_in/1000

V_out = collect_measurement_data ("V_out.%d+", "/tmp/mppt.log", result)
V_out = V_out/1000


firmware_type = collect_char_data ("Firmware:.%w+_%a+_%d+", 11, "/tmp/mppt.log", result)


temp_corr_V_end = collect_measurement_data ("Adjusted charge end..%d+", "/tmp/mppt.log", result)
temp_corr_V_end = temp_corr_V_end/1000

battery_temperature_in = collect_measurement_data ("Temperature.%d+.%d", "/tmp/mppt.log", result)


battery_temperature = tonumber(battery_temperature_in)

low_voltage_disconnect = collect_measurement_data ("F=Load oFF.......%d+", "/tmp/mppt.log", result)

low_voltage_disconnect = low_voltage_disconnect / 1000


if V_in >= V_out and V_out ~= 0 then charge_status = "Charging" Bit_0 = 1 end

if V_in < V_out then charge_status = "Discharging" Bit_1 = 1 end
                    
if V_out > V_in then V_oc = 0.0 end

if V_out == 0.0 and V_in == 0.0 then charge_status = "No information" end

if V_oc == 0.0 and V_in > V_out then V_oc = V_in end

if temp_corr_V_end == 0.0 then temp_corr_V_end = 14.2 end 
                    
if V_in < V_out then V_in = 0.0 end

file = io.open("/tmp/v_out", "r")

if file then
    io.input(file) 
    V_out_old = io.read("*n")
    io.close(file)
else
    V_out_old = V_out
end

-- Charge state estimate

-- To estimate charge state when discharging is relatively simple, due to low and constant load.

if V_in < V_out and V_out > 12.60 then charge_state = (95 + ((V_out - 12.6) * 20)) end 

if V_in < V_out and V_out < 12.60 and V_out > 11.6 then charge_state = (10 + ((V_out - 11.6) * 85)) end

if V_in < V_out and V_out < 11.60 and V_out > 8.00 then charge_state = ((V_out - 10.6) * 10) end 

-- Estimate while charging without measuring current – tricky!

-- Detect and handle charge end
-- At charge end, the battery can no longer take the full energy offered by the solar module. 

if V_out >= (temp_corr_V_end - 0.05) then charge_state = (((V_out - 12.0) / ((temp_corr_V_end - 12.0) /100)) * (V_in / (V_oc - 0.5) )) end


-- Detect and handle very low charge current
-- At very low charge current, the V_oc versus V_mpp ratio is smaller than the MPP controller calculates.

if V_out < (temp_corr_V_end - 0.05) and V_in > V_out and 1.22 > (V_oc / V_in) and V_out > 12.6 and V_out > V_out_old then charge_state = (85 + ((V_out - 12.6) * 30)) end
                    
if V_out < (temp_corr_V_end - 0.05) and V_in > V_out and 1.22 > (V_oc / V_in) and V_out > 12.6 and V_out <= V_out_old then charge_state = (90 + ((V_out - 12.6) * 20)) end
                    
if V_out < (temp_corr_V_end - 0.05) and V_in > V_out and 1.22 > (V_oc / V_in) and V_out < 12.6 and V_out <= V_out_old then charge_state = (10 + ((V_out - 11.6) * 80)) end

-- Detect and handle considerable charge current
-- At considerable charge current, the V_oc versus V_mpp ratio matches the ratio the MPP controller calculates.

if V_out < (temp_corr_V_end - 0.05) and 1.22 < (V_oc / V_in) and V_in > V_out then charge_state = (V_out - (temp_corr_V_end * 0.85)) / ((temp_corr_V_end - (temp_corr_V_end * 0.85)) / 90) end

-- Read previously recorded charge state
file = io.open("/tmp/charge_state_float", "r")

if file then
    io.input(file) 
    charge_state_float = io.read("*n")
    io.close(file)
else
    charge_state_float = charge_state
end

--[[ Handle the corner case when the router has spent time running without serial data from the controller.
     Kickstart from charge state estimate, as soon as the controller is connected again.]]

if (charge_state_float < (charge_state - 30)) then charge_state_float = charge_state
print("Debug: Kickstart battery gauge from charge state estimate")
end 

if charge_state > charge_state_float and  Bit_0 == 1 then charge_state = charge_state_float + 0.25 end

if charge_state > charge_state_float and  Bit_0 == 0 then charge_state = charge_state_float end

if charge_state < charge_state_float and V_out > 0 and  Bit_1 == 1 then charge_state = charge_state_float - 0.25 end

if charge_state < charge_state_float and V_out > 0 and  Bit_1 == 0 then charge_state = charge_state_float end
                    
charge_state_float = charge_state 

charge_state_int = math.ceil(charge_state)

if charge_state_int > 100 then charge_state_int = 100 end

if charge_state_int == 100 then charge_status = "Fully charged" Bit_2 = 1 Bit_0 = 0 end 

if charge_state_int < 0 then charge_state_int = 0 end

file = io.open("/tmp/charge_state_float", "w")

io.output(file)

io.write(charge_state_float)

io.close(file)


file = io.open("/tmp/v_out", "w")

io.output(file)

io.write(V_out)

io.close(file)
                
maximum_power_consumption = 0

local f = io.popen("uci get ffopenmppt.@ffopenmppt[0].maximum_power_consumption", "r")
for entry in f:lines() do
maximum_power_consumption = tonumber(entry)
end

-- Battery health estimate calculation

file = io.open("/tmp/battery_health_estimate", "r")

if file then
    io.input(file) 
    health_estimate = io.read("*n")
    io.close(file)
else
    health_estimate = 100
end
                    
battery_gauge_begin = collect_char_data("%d+.%d+", 0, "/tmp/battery-gauge-start.log", result)
battery_gauge_end = collect_char_data("%d+.%d+", 0, "/tmp/battery-gauge-stop.log", result)

battery_gauge_start = tonumber(battery_gauge_begin)
battery_gauge_stop = tonumber(battery_gauge_end)
                    
if battery_gauge_start > 100 then battery_gauge_start = 100 end

if (battery_gauge_start > 0 and battery_gauge_stop > 0 and maximum_power_consumption > 0) then health_estimate = (((6 * maximum_power_consumption) / (((battery_gauge_start - battery_gauge_stop) / 100) * rated_batt_capacity)) * 100) end

health_estimate = math.ceil(health_estimate)

if health_estimate > 100 then health_estimate = 100 end

file = io.open("/tmp/battery_health_estimate", "w")

io.output(file)

io.write(health_estimate)

io.close(file)

-- System health report

critical_storage_charge_ratio = 2.5

storage_charge_ratio =  (rated_batt_capacity * (health_estimate / 100)) / (solar_module_capacity / 15)

system_status = ""

if storage_charge_ratio > critical_storage_charge_ratio and charge_state > 50 then system_status = "Healthy. " Bit_3 = 1 end

if storage_charge_ratio > critical_storage_charge_ratio and charge_state <= 30 then system_status = "Warning: Battery level low. Increased battery wear. "  Bit_4 = 1 end

if storage_charge_ratio <= critical_storage_charge_ratio then system_status = system_status .. "Warning: Energy storage capacity too small. Check battery size and/or wear. "  Bit_5 = 1 end

if temp_corr_V_end == 14.2 and battery_temperature == 0 then system_status = system_status .. "Warning: Temperature sensor not connected. " Bit_6 = 1 end


if V_out == 0.0 then system_status = "Error: No communication with solar controller." Bit_7 = 1 temp_corr_V_end = 0 health_estimate = 0 end

if battery_temperature >= 40.0 then system_status = system_status .. "Battery overheating. " Bit_8 = 1 end

if battery_temperature <= -10.0 then system_status = system_status .. "Low battery temperature. " Bit_9 = 1 end

-- Check if the conditions for a router firmware update are met.
-- We can't do it when either the low voltage disconnect or the
-- watchdog are about to cut the routers power supply.
-- This could brick the router device.                    
                    
if 0.2 > V_out - low_voltage_disconnect or tonumber(nextreboot) < 15 then Bit_10 = 1 end
                    
file = io.open("/tmp/is_sysupgrade_allowed", "w")
io.output(file)
if Bit_10 == 1 then io.write("0") else io.write("1") end
io.close(file)


bit_string_0 = (Bit_0 .. Bit_1 .. Bit_2 .. Bit_3)
bit_string_1 = (Bit_4 .. Bit_5 .. Bit_6 .. Bit_7)
bit_string_2 = (Bit_8 .. Bit_9 .. Bit_10 .. Bit_11)



bin2hextable = {
	["0000"] = "0",
	["0001"] = "1",
	["0010"] = "2",
	["0011"] = "3",
	["0100"] = "4",
	["0101"] = "5",
	["0110"] = "6",
	["0111"] = "7",
	["1000"] = "8",
	["1001"] = "9",
	["1010"] = "A",
    ["1011"] = "B",
    ["1100"] = "C",
    ["1101"] = "D",
    ["1110"] = "E",
    ["1111"] = "F"
	}



statuscode_json = ("0x" .. bin2hextable[bit_string_0] .. bin2hextable[bit_string_1] .. bin2hextable[bit_string_2])
statuscode = (bin2hextable[bit_string_0] .. bin2hextable[bit_string_1] .. bin2hextable[bit_string_2])

-- Create CSV data set

file = io.open("/tmp/ISEMS/ffopenmppt.log", "a+")

io.output(file)


io.write(nodeid, ";", packetrev, ";", timestamp, ";", firmware_type, ";", nextreboot, ";", powersave, ";", V_oc, ";", V_in, ";", V_out, ";", charge_state_int, ";", health_estimate, ";", battery_temperature, ";", low_voltage_disconnect, ";", temp_corr_V_end, ";", rated_batt_capacity, ";", solar_module_capacity, ";", lat, ";", long, ";", statuscode, "\n")

io.close(file)

-- Create JSON single data set

file = io.open("/tmp/ISEMS/ffopenmppt.json", "w")

io.output(file)

io.write("{", "\n", "\"Node-ID\"", ": ", " \"", nodeid,  "\"", ",", "\n", 
                    "\"Timestamp\"", ": ", timestamp, ",", "\n", 
                    "\"System status summary\"", ": ", "\"", charge_status, ". ", system_status, "\"", ",", "\n",
                    "\"µC firmware and controller type\"", ": ", "\"", firmware_type, "\"", ",", "\n",
                    "\"Next reboot\"", ": ", nextreboot, ",", "\n",
                    "\"Power save level\"", ": ", powersave, ",", "\n",
                    "\"Solar panel open circuit voltage\"", ": ", V_oc, ",", "\n",
                    "\"MPP-Tracking voltage\"", ": ", V_in, ",", "\n",
                    "\"Battery voltage\"", ": ", V_out, ",", "\n",
                    "\"Charge state (0-100%)\"", ": ", charge_state_int, ",", "\n",
                    "\"Battery temperature (Celsius)\"", ": ", battery_temperature, ",", "\n",
                    "\"Battery health estimate (0-100%)\"", ": ", health_estimate, ",", "\n",
                    "\"Low voltage disconnect voltage\"", ": ", low_voltage_disconnect, ",", "\n",
                    "\"Temperature corrected charge end voltage\"", ": ", temp_corr_V_end , ",", "\n",
                    "\"Rated battery capacity in Ah (when new)\"", ": ", rated_batt_capacity, ",", "\n",
                    "\"Rated solar module power in Watt\"", ": ", solar_module_capacity, ",", "\n",
                    "\"Latitude\"", ": ", lat, ",", "\n",
                    "\"Longitude\"", ": ", long, ",", "\n",
                    "\"Status code\"", ": ",  " \"", statuscode_json,  "\"", "\n","}", "\n") 

io.close(file)

-- Create simple HTML info page

file = io.open("/tmp/ISEMS/ffopenmppt.html", "w")

io.output(file)
                                        
if 0.2 > V_out - low_voltage_disconnect and V_out ~= 0 then io.write ("<h2>Warning:<br>Do not perform a router firmware upgrade now,<br>the battery is running too low!</h2>", "\n")  end
                    
                    
if tonumber(nextreboot) < 15 and V_out ~= 0  then  io.write ("<h2>Warning: Do not perform a router firmware upgrade now, the watchdog is scheduled to cut the power in ", nextreboot, " minutes! </h2>", "\n") end

                    
if Bit_7 == 1  then  io.write ("<h2>Warning: Do not perform a router firmware upgrade now,<br>there is no information from the solar controller!<br>Power supply can be cut anytime!</h2>", "\n") end
                    
io.write(
            --"<h2>Independent Solar Energy Mesh</h2>", "\n",
            "<h3>Status of ",nodeid, " (local node)</h3>", "\n",
            "<b>Summary: </b>", charge_status, ". ", system_status, "<br><br>", "\n",
            "<b>Charge state: </b>", charge_state_int, "%<br><br>", "\n",
            "<b>Next scheduled reboot by watchdog in: </b> ", nextreboot, " minutes<br><br>", "\n",
            "<b>Battery voltage: </b>", V_out, " Volt<br><br>", "\n",
            "<b>Temperature corrected charge end voltage:</b> ", temp_corr_V_end , " Volt<br><br>", "\n",
            "<b>Battery temperature: </b>", battery_temperature, "&deg;C<br><br>", "\n",
            "<b>Battery health estimate: </b>", health_estimate, "%<br><br>", "\n",
            "<b>Power save level: </b> ", powersave, "<br><br>", "\n",
            "<b>Solar panel open circuit voltage: </b>", V_oc, " Volt<br><br>", "\n",
            "<b>MPP-Tracking voltage:</b> ", V_in, " Volt<br><br>", "\n",
            "<b>Low voltage disconnect voltage:</b> ", low_voltage_disconnect, " Volt<br><br>", "\n",
            "<b>Rated battery capacity (when new):</b> ", rated_batt_capacity, " Ah<br><br>", "\n",
            "<b>Rated solar module power: </b> ", solar_module_capacity, " Watt<br><br>", "\n",
            -- "<b>Unix-Timestamp:</b> ", timestamp, " (local time)<br><br>", "\n", 
            "<b>Solar controller type and firmware:</b> ",  firmware_type, "<br><br>", "\n", 
            --"<b>Latitude:</b> ", lat, "<br><br>", "\n",
            --"<b>Longitude:</b> ", long, "<br><br>", "\n",
            "<b>Status code:</b> ", statuscode_json, "<br><br>", "\n") 

io.close(file)



