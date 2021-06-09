# What is this demo?

This is a demo repo of a _working mod_ built using [`novaras/modkit`](https://github.com/Novaras/modkit).

Once cloned (or otherwise available on your machine), you can run this using `-moddatapath` as you would any other mod!

**In it, we define a single script which makes all repairer ships seek out ships from the players own fleet which are in need of repairs, and repair them automatically, prioritising ships according to a _custom priority algorithm_!**

---

## Technical details below! 🤖 
### Composing custom code:

This mod is a very good example of modkit code composition.

We can see a prototype defined _once_ in `custom_code/lib/repairer.lua`, which is trivial to apply to multiple ships:

```lua
-- frigs.lua

-- make sure the prototype is available
dofilepath("data:scripts/custom_code/lib/repairer.lua");

-- we have no custom stuff for support frigs so just use repairer template directly
modkit.compose:addShipProto("kus_supportfrigate", repairers_proto);
modkit.compose:addShipProto("tai_supportfrigate", repairers_proto);
```

Thats it!

You may notice that we make use of 'base prototypes' too (added with `addBaseProto` in the `modkit-*` files). These are _global_ prototypes for all ships, and all ships will have these properties available to use (such as `ship:HP()`, `ship:attackFamily()` etc.)!

This method of layering prototypes for ship types is _extremely_ flexible. **Pretty much any table can be passed to `addShipProto`**, and its keys will become the keys of that ship (plus the keys it already inherited from the `modkit-` base prototypes).

There is a reserved special key, `"attribs"`, which can be a function. If it is, it will be passed the regular three hook arguments (`CustomGroup`, `playerIndex`, `shipID`) and is expected to return a plain table (presumably making use of the arguments).

In this case, we don't have any attributes which rely on the hook arguments to work, so we actually don't make use of this functionality.

However the base prototypes do use this, and show us how it would work:

```lua
modkit_base = {
	attribs = function (g, p, s)
		return {
			id = s,
			type_group = g,
			own_group = SobGroup_Clone(g, g .. "-" .. s),
			player_index = p,
			_tick = 0,
			created_at = Universe_GameTime()
		};
	end
};
```

Although the names are contracted, `g`, `p`, and `s` are our three arguments, and ships will use these when attaching the attributes to themselves.

The resulting ship doesn't have an `"attribs"` value - it is flattened into the ship's table itself:

```lua
{
	foo = 10,
	attribs = function (ship_type, player_index, ship_id)
		return {
			bar = ship_id -- set 'bar' to the ship's id
		};
	end
}
```

If the ship's id was `64` when it was first created, we get:

```lua
{
	foo = 10,
	bar = 64
}
```