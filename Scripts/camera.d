﻿module camera;
import core, utility;

/// Temporary class to move the camera around
shared class Camera : GameObject
{
	this()
	{
	}
	
	override void onUpdate()
	{	
		// 4-directional movement
		if( Input.getState( "LookUp" ) )
		{
			this.transform.position.z -= 0.05;
		}
		else if( Input.getState( "LookDown" ) )
		{
			this.transform.position.z += 0.05;
		}
		
		if( Input.getState( "LookLeft" ) )
		{
			this.transform.position.x -= 0.05;
		}
		else if( Input.getState( "LookRight" ) )
		{
			this.transform.position.x += 0.05;
		}

		// change distance from floor
		if( Input.getState( "ZoomUp" ) )
		{
			this.transform.position.y -= 0.05;
		}
		else if( Input.getState( "ZoomDown" ) )
		{
			this.transform.position.y += 0.05;
		}
	}
}
