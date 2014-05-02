module game;
import controller, grid, turn, action, ability, unit, camera;
import core, graphics, components, utility;
import speed;

// An easier way to access the game instance
@property RobotGhosts Game()
{
	return cast(RobotGhosts)DGame.instance;
}

/// The base game class
class RobotGhosts : DGame
{
public:
	Controller gc; // the game controller
	Scene level; // The active scene in the engine
	Grid grid; // The grid in the level
	Turn turn; // The turn controller
	Ability[ uint ] abilities; // The abilities
	Unit[] units; // The units
	shared Connection serverConn; // the server connection
	GameState gameState;
	//UserInterface ui;

	// Name that game
	@property override string title()
	{
		return "Spectral Robot Task Force";
	}
	
	override void onInitialize()
	{
		logInfo( "Initializing ", title, "..." );
		
		// setup a couple helper keys
		Input.addKeyDownEvent( Keyboard.Escape, ( uint kc ) { currentState = EngineState.Quit; } );
		Input.addKeyDownEvent( Keyboard.F5, ( uint kc ) { currentState = EngineState.Reset; } );
		
		// initalize stuff
		level = new Scene();
		this.activeScene = level;
		auto g = GameObject.createWithBehavior!Grid;
		grid = g[ 1 ];
		Game.level.addChild( g[ 0 ] );
		turn = new Turn();
		gc = new Controller();
		
		// create a camera
		auto cam = level[ "Camera" ].behaviors.get!AdvancedCamera;
		cam.autoClamp();
		level.camera = cam.camera;
		
		// bind 'r' to server connect
		Input.addKeyDownEvent( Keyboard.R, kc => connect() );
		
		// create the ui
		/*ui = new UserInterface( Config.get!uint( "Display.Width" ),
		 Config.get!uint( "Display.Height" ), 
		 Config.getPath( "UserInterface.FilePath" ) 
		 );*/

		gameState = GameState.InGame;
	}
	
	/// Connect to the server
	void connect()
	{
		if( serverConn )
			serverConn.close();
		serverConn = Connection.open( config.find!string( "Game.ServerIP" ), false, ConnectionType.TCP );
		serverConn.onReceiveData!string ~= msg => logInfo( "Server Message: ", msg );
		serverConn.onReceiveData!uint ~= numPlayers => turn.setTeam( numPlayers );
		serverConn.onReceiveData!Action ~= action => turn.doAction( action );
		serverConn.send!string( "New connection.", ConnectionType.TCP );
	}
	
	override void onUpdate()
	{
		//ui.update();
		try
		{
			if( serverConn )
				serverConn.update();
		}
		catch( Exception e )
		{
			logInfo( "Error: ", e.msg );
		}
	}
	
	override void onDraw()
	{
		//ui.draw();
		final switch( gameState )
		{
			case GameState.InGame:
				Game.stateFlags.updateScene = true;
				Game.stateFlags.updateTasks = true;
				break;
			case GameState.Menu:
				Game.stateFlags.updateScene = false;
				Game.stateFlags.updateTasks = false;
				break;
		}
	}
	
	override void onShutdown()
	{
		logInfo( "Shutting down..." );
		if( serverConn )
			serverConn.close();
		level.destroy();
		grid.destroy();
		turn.destroy();
		units.destroy();
		abilities.destroy();
		gc.destroy();
		//ui.destroy();
	}
	
	override void onSaveState()
	{
		logInfo( "Resetting..." );
	}
}

enum GameState
{
	InGame,
	Menu,
}
