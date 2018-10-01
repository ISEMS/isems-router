-- Copyright 2008 Freifunk Leipzig / Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

module("luci.statistics.rrdtool.definitions.OpenMPPT",package.seeall)

function rrdargs( graph, plugin, plugin_instance, dtype )
	return {{
		title = "%H: Freifunk-OpenMPPT",
		alt_autoscale_max = true,
		vlabel = "Volt",
		number_format = "%5.1lfV",
		data = {
			instances = { 
				voltage = { "in", "out", "idle", "mpp" }
			},

			options = {
				voltage_in   = {
					transform_rpn = "1000,/",
					color = "ffcc00",
					title = "U in",
					overlay = true,
					noarea = true,
					weight = 1
				},
				voltage_out  = {
					transform_rpn = "1000,/",
					color = "339900",
					title = "U out",
					overlay = true,
					noarea = true,
					weight = 4
				},
				voltage_idle = {
					transform_rpn = "1000,/",
					color = "0000ff",
					title = "U idle",
					overlay = true,
					noarea = true,
					weight = 3
				},
				voltage_mpp  = {
					transform_rpn = "1000,/",
					color = "ff0000",
					title = "U MPP",
					overlay = true,
					noarea = true,
					weight = 2
				}
			}
		}
	}



	, {
		title = "%H: Freifunk-OpenMPPT",
		alt_autoscale_max = true,
		vlabel = "Volt",
		number_format = "%5.1lfV",
		data = {
			instances = { 
				voltage = { "out" }
			},

			options = {
				voltage_out  = {
					transform_rpn = "1000,/",
					color = "339900",
					title = "U out",
					overlay = true,
					weight = 4
				}
			}
		}
	}

}

end

