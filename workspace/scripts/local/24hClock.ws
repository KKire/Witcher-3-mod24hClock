// clock near minimap
@wrapMethod(CR4HudModuleMinimap2)
function OnConfigUI()
{
	wrappedMethod();
	b24HRFormat = true;
}

// clock near minimap - leading zero
@replaceMethod(CR4HudModuleMinimap2)
function GetCurrentTimeString() : string
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

// clock in meditation menu
@wrapMethod(CR4MeditationClockMenu)
function OnConfigUI()
{
	wrappedMethod();
	m_fxSet24HRFormat.InvokeSelfOneArg(FlashArgBool(true));
}

@wrapMethod(CR4MeditationClockMenu)
function SendCurrentTimeToAS()
{
	var set24HRFormat : CScriptedFlashFunction;
	if ( m_flashModule )
	{
		set24HRFormat = m_flashModule.GetMemberFlashFunction( "Set24HRFormat" );
		if ( set24HRFormat )
		{
			set24HRFormat.InvokeSelfOneArg( FlashArgBool( true ) );
		}
	}

	wrappedMethod();
}

// clock in photomode
@replaceMethod(CR4PhotomodeMenu)
function GetTimesStrings(out stringsArray : array<string>)
{
	var hour, min : int;
	var timeText : string;
	var hourString : string;

	for(hour = 0; hour < 24; hour+=1)
	{
		if (hour < 10)
		{
			hourString = "0" + hour;
		}
		else
		{
			hourString = hour;
		}

		for(min = 0; min < 60; min+=1)
		{
			timeText = "" + hourString + ":";
			if(min < 10)
				timeText += "0";
			timeText += min;
		
			stringsArray.PushBack(timeText);
		}
	}
}

// savegame list
// will also change the date format
@wrapMethod(CCommonGame)
function GetDisplayNameForSavedGame( savegame : SSavegameInfo ) : string
{
	var rawName, questPart, dtPart : string;
	var dashIndex : int;
	var tokens : array<string>;
	var dayOfWeek, month, day, year, timePart, ampm : string;
	var timeTokens : array<string>;
	var hour, minute, second : int;
	var hourStr : string;

	rawName = wrappedMethod(savegame);

	dashIndex = StrFindLast(rawName, " - ");
	if (dashIndex == -1)
	{
		return rawName;
	}

	questPart = StrLeft(rawName, dashIndex);
	dtPart    = StrMid(rawName, dashIndex + 3);

	dtPart = StrReplace(dtPart, ",", "");
	tokens = StrSplit(dtPart, " ");

	// Expecting 6 tokens:
	// [0] "Thursday"
	// [1] "October"
	// [2] "1"
	// [3] "2026"
	// [4] "10:25:59"
	// [5] "PM"
	if (tokens.Size() >= 6)
	{
		dayOfWeek = StrReplace(tokens[0], ",", "");
		timePart  = tokens[4];
		ampm      = StrUpper(tokens[5]);

		month = StrReplace(tokens[1], ",", "");
		day   = StrReplace(tokens[2], ",", "");
		year = StrReplace(tokens[3], ",", "");

		// Convert time to 24-hour format
		timeTokens = StrSplit(timePart, ":");
		hour   = StringToInt(timeTokens[0]);
		minute = StringToInt(timeTokens[1]);
		second = StringToInt(timeTokens[2]);

		if (ampm == "PM" && hour < 12)
		{
			hour += 12;
		}
		else if (ampm == "AM" && hour == 12)
		{
			hour = 0;
		}

		if (hour < 10)
		{
			hourStr = "0" + IntToString(hour);
		}
		else
		{
			hourStr = IntToString(hour);
		}

		timePart = hourStr + ":" + timeTokens[1] + ":" + timeTokens[2];

		// Returns: "Quest Name - Thursday, 1 October 2026 22:25:59"
		return questPart + " - " + dayOfWeek + ", " + day + " " + month + " " + year + " " + timePart;
	}

	return rawName;
}
