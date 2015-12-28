if ( SERVER ) then
player_manager.AddValidModel( "Riot Soldier LR", "models/fallout_nv/nikout/LonesomeRoad/player/riotsoldier.mdl" );

end

list.Set( "PlayerOptionsModel", "Riot Soldier LR", "models/fallout_nv/nikout/LonesomeRoad/player/riotsoldier.mdl" );

local NPC =
{
	Name = "Riot Soldier Friendly",
	Class = "npc_citizen",
	KeyValues =
	{
		citizentype = 4
	},
	Model = "models/fallout_nv/nikout/LonesomeRoad/riotsoldier.mdl",
	Health = "200",
	Category = "NikouT's NPCs"
}

list.Set( "NPC", "npc_lrriotsoldier_f", NPC )

local NPC =
{
	Name = "Riot Soldier Hostile",
	Class = "npc_combine_s",
	Model = "models/fallout_nv/nikout/LonesomeRoad/riotsoldier.mdl",
	Health = "200",
	Category = "NikouT's NPCs"
}

list.Set( "NPC", "npc_lrriotsoldier_h", NPC )