repairers_proto = {
	attribs = function (c, p, s)
		return {
			family_weights = { -- custom families
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
	self._rescan_after = Universe_GameTime() + 5; -- at least 10s into the future, meaning we spend at least 5s on this target
	SobGroup_RepairSobGroup(self.own_group, target.own_group);
end

-- our own priority algorithm (based on weights):
-- (distance_weight * missing_health) + family_weight + lost_since_last_weight
function repairers_proto:targetPriority(target)
	local distance_weight = 1 - max(0, self:distanceTo(target) / 10000); -- range, 0 = 1 --> 10000 = 0
	local missing_health_weight = (1 - target:HP());

	return distance_weight * missing_health_weight;
end

function repairers_proto:update()
	if (self._rescan_after) then
		print("rescan after: " .. self._rescan_after);
		print("cgt: " .. Universe_GameTime());
	end
	if (self._rescan_after and Universe_GameTime() > self._rescan_after) then
		self._rescan_after = nil;
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

		-- if any found, sort them by our prio algorithm, repair the top result (heaviest weighted target)
		if (modkit.table.length(damaged_ships) > 0) then
			if (modkit.table.length(damaged_ships) > 1) then
				sort(
					damaged_ships,
					function (ship_a, ship_b)
						return %self:targetPriority(ship_a) > %self:targetPriority(ship_b);
					end
				);
			end

			self:repair(modkit.table.first(damaged_ships)); -- repair the top result
		end
	end
end
