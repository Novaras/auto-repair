-- prototype table for any 'repairer' ship (we can combine prototypes as we see fit)
repairers_proto = {
	attribs = function (c, p, s)
		return {
			family_weights = { -- custom families (just an example list :])
				corvette = 1,
				frigate = 1.5,
				resource = 4,
				-- ...etc...
			}
		};
	end
};

-- makes the repairer repair the target
function repairers_proto:repair(target)
	self._rescan_after = Universe_GameTime() + 5; -- at least 5s into the future, meaning we spend at least 5s on this target
	SobGroup_RepairSobGroup(self.own_group, target.own_group);
end

-- our own priority algorithm (based on weights):
-- (distance_weight * missing_health) + family_weight + lost_since_last_weight
function repairers_proto:targetPriority(target)
	local distance_weight = 1 - max(0, self:distanceTo(target) / 10000); -- range, 0 = 1 --> 10000 = 0
	local missing_health_weight = (1 - target:HP());

	return distance_weight * missing_health_weight;
end

-- returns whether or not we should perform a rescan for new targets
-- this is important to control; since distance is a part of the weight function and we call update()
-- every second, we need to make sure we dont flit between targets whose weights might be swapping
-- in order.
function repairers_proto:shouldRescan()
	return self._rescan_after and Universe_GameTime() > self._rescan_after;
end

-- update hook, called every second (in .ship file)
function repairers_proto:update()
	if (self:shouldRescan()) then
		self._rescan_after = nil; -- if we need to rescan, remove the guard to the following if
	end
	if (self._rescan_after == nil) then
		-- get all damaged ships belonging to us
		local damaged_ships = modkit.table.pack(modkit.table.filter(
			GLOBAL_REGISTER:all(),
			function (ship)
				return ship:HP() < 1 and ship.player == %self.player;
			end
		));

		modkit.table.printTbl(modkit.table.first(damaged_ships), "Top priority ship:");

		-- if any found, sort them by our prio algorithm, repair the top result (heaviest weighted target):
		if (modkit.table.length(damaged_ships) > 0) then
			if (modkit.table.length(damaged_ships) > 1) then
				sort(
					damaged_ships,
					function (ship_a, ship_b)
						return %self:targetPriority(ship_a) > %self:targetPriority(ship_b);
					end
				);
			end

			local top_result = modkit.table.first(damaged_ships);
			self:repair(top_result); -- repair the top result
		end
	end
end
