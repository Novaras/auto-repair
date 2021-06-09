-- for frigs...

dofilepath("data:scripts/custom_code/lib/repairer.lua");

-- we have no custom stuff for support frigs so just use repairer template directly
modkit.compose:addShipProto("kus_supportfrigate", repairers_proto);
modkit.compose:addShipProto("tai_supportfrigate", repairers_proto);