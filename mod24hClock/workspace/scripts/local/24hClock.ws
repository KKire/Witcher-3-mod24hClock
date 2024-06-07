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

@replaceMethod(CR4MeditationClockMenu) function OnConfigUI()
{	
	var commonMenu : CR4CommonMenu;
	var locCode : string;
	var initData : W3SingleMenuInitData;
	
	super.OnConfigUI();
	
	GetWitcherPlayer().MeditationClockStart(this);
	SendCurrentTimeToAS();
	m_fxSetBlockMeditation = m_flashModule.GetMemberFlashFunction( "SetBlockMeditation" );
	m_fxSet24HRFormat = m_flashModule.GetMemberFlashFunction( "Set24HRFormat" );
	m_fxSetGeraltBackgroundVisible = m_flashModule.GetMemberFlashFunction( "setGeraltBackgroundVisible" );
	m_fxSetBonusMeditationTime = m_flashModule.GetMemberFlashFunction( "setBonusMeditationTime" );
	
	m_fxSetBonusMeditationTime.InvokeSelfOneArg( FlashArgInt( BONUS_MEDITATION_TIME ) );
	
	theGame.Unpause("menus");		
	
	initData = (W3SingleMenuInitData)GetMenuInitData();
	
	if( initData && initData.isBonusMeditationAvailable )
	{
		SetMeditationBonuses();
	}
	
	if(GetWitcherPlayer().CanMeditate() && GetWitcherPlayer().CanMeditateWait(true) || ( initData && initData.ignoreMeditationCheck ) )
	{
		canMeditateWait = true;
		isGameTimePaused = false;			
	}
	else if(theGame.IsGameTimePaused())
	{
		canMeditateWait = false;
		isGameTimePaused = true;
	}
	
	if (canMeditateWait) 
	{
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if (commonMenu)
		{
			commonMenu.SetMeditationMode(true);
		}
		
		m_fxSetGeraltBackgroundVisible.InvokeSelfOneArg(FlashArgBool(false)); 
	}
	
	m_fxSetBlockMeditation.InvokeSelfOneArg( FlashArgBool( !canMeditateWait ) );
	
	//locCode = GetCurrentTextLocCode(); // mod24hClock
	m_fxSet24HRFormat.InvokeSelfOneArg(FlashArgBool(true));
	
	if(GameplayFactsQuerySum("GamePausedNotByUI") > 0 && !thePlayer.IsInCombat())
	{
		GetWitcherPlayer().MeditationRestoring(0);				
	}	
	
	theGame.Pause("menus");
}
