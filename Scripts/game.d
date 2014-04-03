module game;
import controller;

import core, graphics, components, utility;

@property RobotGhosts Game()
{
	return cast(RobotGhosts)DGame.instance;
}

shared class RobotGhosts : DGame
{
	public Controller gc;
	
	// Name that game
	@property override string title()
	{
		return "Spectral Robot Task Force";
	}
	
	override void onInitialize()
	{
		logInfo( "Initializing..." );
		
		// setup a couple helper keys
		Input.addKeyDownEvent( Keyboard.Escape, ( uint kc ) { currentState = GameState.Quit; } );
		Input.addKeyDownEvent( Keyboard.F5, ( uint kc ) { currentState = GameState.Reset; } );
		
		gc = new shared Controller();
		
		// create a camera
		gc.level.camera = gc.level["Camera"].camera;
	}
	
	override void onUpdate()
	{

	}
	
	override void onDraw()
	{

	}
	
	override void onShutdown()
	{
		logInfo( "Shutting down..." );
	}
	
	override void onSaveState()
	{
		logInfo( "Resetting..." );
	}
}
