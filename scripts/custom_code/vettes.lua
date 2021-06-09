-- vette related protos

dofilepath("data:scripts/custom_code/lib/repairer.lua");

-- we have no custom stuff for repair vette so just use repairer template directly
modkit.compose:addShipProto("kus_repaircorvette", repairers_proto);
modkit.compose:addShipProto("tai_repaircorvette", repairers_proto);