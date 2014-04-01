﻿module controller;
import unit, ability, grid;
import core, utility;
import yaml;
import std.path;

final shared class Controller
{
public:
	Action[] lastTurn; //Gets cleared after a turn
	Action[] currentTurn; //Gets populated as the user makes actions
	GameObjectCollection gameObjects; //Abstract this to a GameState class or something? Idk yet
	Ability[string] abilities; //The instantiated units for this instance of the game
	
	this()
	{
		gameObjects = new shared GameObjectCollection();
		// So we'll first load all the objects
		gameObjects.loadObjects("Base");
		
		auto grid = new shared Grid();
		grid.transform.position.z = -50;
		grid.transform.updateMatrix();
		gameObjects["Grid"] = grid;
		
		loadAbilities();
		loadUnits();
		loadLevel();
	}

	
	void loadAbilities()
	{
		//Add the ability to the Ability array by loading it from yaml, just like in loadUnits
		foreach( abilityNode; loadYamlDocuments( buildNormalizedPath( FilePath.Resources.Objects, "Abilities" ) ) )
		{
			string name = abilityNode["Name"].as!string;
			abilities[name] = new shared Ability();
		}
	}
	
	void loadUnits()
	{
		// So we are going to parse the Units folder for the unit files
		// For those, we'll get the Name of the node, which will be how we call into the gameObjects
		
		foreach( unitNode; loadYamlDocuments( buildNormalizedPath( FilePath.Resources.Objects, "Units" ) ) )
		{
			string[shared GameObject] parents;
			string[][shared GameObject] children;

			auto unit = cast(shared Unit)Prefabs[ unitNode["InstanceOf"].as!string ].createInstance( parents, children );
			unit.name = unitNode["Name"].as!string;
			
			//Then for each variable, accessed by unitNode["varname"] or better off, a tryGet
			//Set the values
			int posX, posY, hp, sp, at, df = 0;
			string ability;
			shared Ability melee, ranged;
			Config.tryGet( "PosX", posX, unitNode );
			Config.tryGet( "PosY", posY, unitNode );
			Config.tryGet( "HP", hp, unitNode );
			Config.tryGet( "Speed", sp, unitNode );
			Config.tryGet( "Attack", at, unitNode );
			Config.tryGet( "Defense", df, unitNode );
			if( Config.tryGet( "MeleeAttack", ability, unitNode ) )
				melee = abilities[ ability ];
			if( Config.tryGet( "RangedAttack", ability, unitNode ) )
				ranged = abilities[ ability ];
			
			unit.init(posX, posY, hp, sp, at, df, melee, ranged, [ melee, ranged ] );
			
			gameObjects[unit.name] = unit;
		}
	}
	
	void loadLevel()
	{
		
	}
}

abstract class Action
{
public:
	uint originUnitId;
}

class MoveAction : Action
{
public:
	int x, y;
}

class AttackAction : Action
{
public:
	uint targetUnitID;
}

class AbilityAction : Action
{
public:
	uint targetUnitId;
	uint abilityID;
}
