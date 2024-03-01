#pragma semicolon 1
#include <sourcemod>

ConVar noChatBlockListHandle;
char loadedBlockList[32][32];

public Plugin:myinfo = {
	name = "nochat",
	author = "Icewind",
	description = "Prevent specific users from chatting",
	version = "0.1",
	url = "https://spire.tf"
};

public OnPluginStart() {
	noChatBlockListHandle = CreateConVar("sm_nochat_blocklist", "", "comma seperated list of steamid64", FCVAR_PROTECTED);
	if (noChatBlockListHandle != null) {
		noChatBlockListHandle.AddChangeHook(onBlockList);
		decl String:blockList[512];
		GetConVarString(noChatBlockListHandle, blockList, sizeof(blockList));
		LoadBlockList(blockList);
	}

	RegConsoleCmd("say", Command_SayChat);
}

public Action:Command_SayChat(client, args) {
	new String:steam_id[32];
	GetClientAuthId(client, AuthId_SteamID64, steam_id, sizeof(steam_id));

	for (int x = 0; x < sizeof(loadedBlockList); x++) {
		if (StrEqual(steam_id, loadedBlockList[x])) {
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public void onBlockList(ConVar convar, const char[] oldValue, const char[] newValue) {
	LoadBlockList(newValue);
}

public void LoadBlockList(const char[] value) {
	for (int x = 0; x < sizeof(loadedBlockList); x++) {
		loadedBlockList[x][0] = EOS;
	}
	ExplodeString(value, ",", loadedBlockList, sizeof(loadedBlockList), sizeof(loadedBlockList[]), false);
}