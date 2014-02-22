module game;
import core.dgame, core.gameobjectcollection;
import components;
import utility.output, utility.input;

@Game!RobotGhosts class RobotGhosts : DGame
{
	public GameObjectCollection goc;
	
	override void onInitialize()
	{
		Output.printMessage( OutputType.Info, "Initializing..." );
		
		Input.addKeyDownEvent( Keyboard.Escape, ( uint kc ) { currentState = GameState.Quit; } );
		Input.addKeyDownEvent( Keyboard.F5, ( uint kc ) { currentState = GameState.Reset; } );
		
		goc = new GameObjectCollection;
		goc.loadObjects( "" );
	}
	
	override void onUpdate()
	{
		goc.apply( go => go.update() );
	}
	
	override void onDraw()
	{
		goc.apply( go => go.draw() );
	}
	
	override void onShutdown()
	{
		Output.printMessage( OutputType.Info, "Shutting down..." );
		goc.apply( go => go.shutdown() );
		goc.clearObjects();
	}
	
	override void onSaveState()
	{
		Output.printMessage( OutputType.Info, "Resetting..." );
	}
}
