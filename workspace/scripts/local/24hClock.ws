// clock near minimap
@replaceMethod(CR4HudModuleMinimap2) function GetCurrentTimeString() : string
{
	var gameTime : GameTime = theGame.GetGameTime();
	var hours : int;
	var minutes : int;
	var timeString : string = "";

	hours = GameTimeHours( gameTime );
	minutes = GameTimeMinutes( gameTime );

	if (hours < 10)
	{
		timeString += "0";
	}
	timeString += hours + ":";

	if (minutes < 10)
	{
		timeString += "0";
	}
	timeString += minutes;

	return timeString;
}

// clock in mediation menu
@wrapMethod(CR4MeditationClockMenu) function OnConfigUI()
{
	wrappedMethod();
	m_fxSet24HRFormat.InvokeSelfOneArg(FlashArgBool(true));
}
