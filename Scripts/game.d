module game;
import controller, grid, turn, action, ability, unit, camera, tile, gameMode;
import dash;

mixin( registerComponents!( "grid" ) );
mixin( registerComponents!( "unit" ) );
mixin( registerComponents!( "tile" ) );
mixin( registerComponents!( "camera" ) );

// An easier way to access the game instance
@property RobotGhosts Game()
{
  return cast(RobotGhosts)DGame.instance;
}

/// The base game class
class RobotGhosts : DGame
{
public:
  Controller gc;
  Scene level;
  Grid grid;
  Turn turn;
  Ability[ uint ] abilities;
  Unit[] units;
  shared Connection serverConn;
  GameMode gameMode;

  // Name that game
  @property override string title()
  {
    return "Spectral Robot Task Force";
  }

  override void onInitialize()
  {
    info( "Initializing ", title, "..." );

    // setup a couple helper keys
    Input.addButtonDownEvent( "QuitToDesktop", ( _ ) { currentState = EngineState.Quit; } );
    Input.addButtonDownEvent( "ResetGame", ( _ ) { currentState = EngineState.Reset; } );

    // setup some gamemode test keys
    Input.addButtonDownEvent( "LoadCTF", ( kc ) { loadLevel( "levelSRTF", "CTF" ); } );
    Input.addButtonDownEvent( "LoadDeathmatch", ( kc ) { loadLevel( "levelSRTF", "Deathmatch" ); } );

    stateFlags.autoRefresh = false;

    // initalize stuff
    level = new Scene();
    this.activeScene = level;
    auto g = new GameObject( new Grid );
    grid = g.getComponent!Grid;
    Game.level.addChild( g );
    turn = new Turn();
    gc = new Controller( "levelSRTF", "Deathmatch" );
    gameMode = GameMode.Deathmatch;

    // create a camera
    auto cam = level[ "Camera" ].getComponent!AdvancedCamera;
    cam.autoClamp();
    level.camera = cam.camera;
    turn.setCameraToRecord();

    // bind 'r' to server connect
    Input.addButtonDownEvent( "ConnectToServer", kc => connect() );

    // create the ui
    uint w = config.display.width;
    uint h = config.display.height;
    level.ui = new UserInterface( w, h, config.userInterface.filePath );
  }

  void loadLevel( string levelName, string gameModeName )
  {
    onShutdown();

    // initalize stuff
    level = new Scene();
    this.activeScene = level;
    auto g = new GameObject( new Grid );
    grid = g.getComponent!Grid;
    Game.level.addChild( g );
    turn = new Turn();
    gc = new Controller( levelName, gameModeName );
    gameMode = to!GameMode( gameModeName );

    // create a camera
    auto cam = level[ "Camera" ].getComponent!AdvancedCamera;
    cam.autoClamp();
    level.camera = cam.camera;

    // create the ui
    uint w = config.display.width;
    uint h = config.display.height;
    level.ui = new UserInterface( w, h, config.userInterface.filePath );
  }

  /// Connect to the server
  void connect()
  {
    if( serverConn )
      serverConn.close();
    serverConn = Connection.open( "localhost", false, ConnectionType.TCP );
    serverConn.onReceiveData!string ~= msg => info( "Server Message: ", msg );
    serverConn.onReceiveData!uint ~= numPlayers => turn.setTeam( numPlayers );
    serverConn.onReceiveData!Action ~= action => turn.doAction( action );
    serverConn.send!string( "New connection.", ConnectionType.TCP );
  }

  override void onUpdate()
  {
    try
    {
      if( serverConn )
        serverConn.update();
    }
    catch( Exception e )
    {
      info( "Error: ", e.msg );
    }
  }

  override void onDraw()
  {
  }

  override void onShutdown()
  {
    info( "Shutting down..." );
    if( serverConn )
      serverConn.close();
    level.destroy();
    grid.destroy();
    turn.destroy();
    units.destroy();
    abilities.destroy();
    gc.destroy();
  }

  override void onSaveState()
  {
    info( "Resetting..." );
  }
}
