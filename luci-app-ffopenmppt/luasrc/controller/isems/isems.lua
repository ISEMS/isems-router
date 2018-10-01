-- Copyright 2018 Elektra Wagenrad <onelektra gmx net>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.isems.isems", package.seeall)

function index()
	--local e=require"luci.model.uci"()
	entry({"admin", "isems"}, cbi("isems/isems"), "Solar-Power", 40).dependent=false
end

--module("luci.controller.myapp.mymodule", package.seeall)

--function index()
--    entry({"click", "here", "now"}, call("action_tryme"), "Click here", 10).dependent=false
--end
 
--function action_tryme()
--    luci.http.prepare_content("text/plain")
--    luci.http.write("Haha, rebooting now...")
--    luci.sys.reboot()
--end


--module("luci.controller.admin.filebrowser",package.seeall)
--function index()
--entry({"admin","filebrowser"},template("cbi/filebrowser")).leaf=true
--end

