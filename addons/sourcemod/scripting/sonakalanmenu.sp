#include <sourcemod>
#include <store>
#include <cstrike>
#include <sdktools>
#include <warden>

public Plugin myinfo = 
{
	name = "Sona Kalan Mahküm Menu", 
	author = "phiso", 
	description = "", 
	version = "1.0", 
	url = "phiso#3331"
};

#pragma semicolon 1
#pragma newdecls required

bool aktif;
int count = 0;

ConVar g_Kredi_Miktari = null;

public void OnPluginStart()
{
	HookEvent("player_death", DeathEvent);
	HookEvent("round_start", roundstartend);
	HookEvent("round_end", roundstartend);
	g_Kredi_Miktari = CreateConVar("sonakalan_kredi_miktari", "500", "Sona kalan menüden kredi seçildiginde kaç kredi verilsin.");
	AutoExecConfig(true, "SonaKalanMenu", "ByDexter");
	
}

public Action DeathEvent(Event event, const char[] name, bool dontBroadcast)
{
	count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
		{
			count++;
		}
	}
	for (int i = 1; i <= MaxClients; i++)
	{
		if (count == 1 && !aktif && warden_iswarden(i))
		{
			MenuVerilsinmi().Display(i, MENU_TIME_FOREVER);
		}
	}
}

Menu MenuVerilsinmi()
{
	Menu menu = new Menu(MenuWarden_Callback);
	menu.SetTitle("Sona Kalan - Menü Verilsin mi?\n ");
	menu.AddItem("1", "Evet");
	menu.AddItem("2", "Hayır");
	menu.ExitBackButton = false;
	menu.ExitButton = false;
	return menu;
}

public int MenuWarden_Callback(Menu menu, MenuAction action, int aptalkursat, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[8];
		menu.GetItem(Position, Item, sizeof(Item));
		if (StrEqual(Item, "1"))
		{
			int client = -1;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && count == 1 && !aktif)
				{
					client = i;
				}
			}
			Menu menu2 = new Menu(Menu_CallBack);
			menu2.SetTitle("Sona Kaldın - Ne İstiyorsun?\n ");
			menu2.AddItem("lr", "LR Atmak");
			menu2.AddItem("isyan", "İsyan Çıkarmak");
			char Kredi_Yazisi[32];
			Format(Kredi_Yazisi, sizeof(Kredi_Yazisi), "%d Kredi Kazanmak", g_Kredi_Miktari.IntValue);
			menu2.AddItem("kredi", Kredi_Yazisi);
			menu2.Display(client, MENU_TIME_FOREVER);
			aktif = true;
		}
		else if (StrEqual(Item, "2"))
		{
			delete menu;
			return;
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public int Menu_CallBack(Menu menu2, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[8];
		menu2.GetItem(Position, Item, sizeof(Item));
		if (StrEqual(Item, "lr"))
		{
			if (aktif)
			{
				count = 0;
				
				for (int i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
				{
					count++;
				}
				
				if (count == 1)
				{
					FakeClientCommand(client, "sm_lr");
					PrintToChatAll("[SM] Sona Kalan Mahkum LR Atmayı Seçti.");
					aktif = true;
					for (int i = 1; i <= MaxClients; i++)
					if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
					{
						Handle hHudText = CreateHudSynchronizer();
						SetHudTextParams(-1.0, -0.60, 3.0, 153, 51, 51, 0, 2, 1.0, 0.1, 0.2);
						ShowSyncHudText(i, hHudText, "Sona Kalan Mahkum LR Tercih etti.");
						delete hHudText;
					}
				}
				else
				{
					PrintToChat(client, "[SM] Bu Menü Şuanda Aktif Değil.");
				}
			}
			else
			{
				PrintToChat(client, "[SM] Bu Menü Şuanda Aktif Değil.");
			}
		}
		else if (StrEqual(Item, "isyan"))
		{
			if (aktif)
			{
				count = 0;
				
				for (int i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
				{
					count++;
				}
				
				if (count == 1)
				{
					GivePlayerItem(client, "weapon_negev");
					GivePlayerItem(client, "weapon_hegrenade");
					GivePlayerItem(client, "weapon_molotov");
					PrintToChatAll("[SM] Sona Kalan Mahkum İsyan Yapmayı Seçti.");
					aktif = true;
					for (int i = 1; i <= MaxClients; i++)
					if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
					{
						Handle hHudText = CreateHudSynchronizer();
						SetHudTextParams(-1.0, -0.60, 3.0, 153, 51, 51, 0, 2, 1.0, 0.1, 0.2);
						ShowSyncHudText(i, hHudText, "Sona Kalan Mahkum İsyan Tercih Etti.");
						delete hHudText;
					}
				}
				else
				{
					PrintToChat(client, "[SM] Bu Menü Şuanda Aktif Değil.");
				}
			}
			else
			{
				PrintToChat(client, "[SM] Bu Menü Şuanda Aktif Değil.");
			}
		}
		else if (StrEqual(Item, "kredi"))
		{
			
			if (aktif)
			{
				count = 0;
				
				for (int i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
				{
					count++;
				}
				
				if (count == 1)
				{
					Store_SetClientCredits(client, Store_GetClientCredits(client) + g_Kredi_Miktari.IntValue);
					ForcePlayerSuicide(client);
					PrintToChatAll("[SM] Sona Kalan Mahkum Kredi Seçti. Otomatik %d kredi verildi.", g_Kredi_Miktari.IntValue);
					aktif = true;
					for (int i = 1; i <= MaxClients; i++)
					if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
					{
						Handle hHudText = CreateHudSynchronizer();
						SetHudTextParams(-1.0, -0.60, 3.0, 153, 51, 51, 0, 2, 1.0, 0.1, 0.2);
						ShowSyncHudText(i, hHudText, "Sona Kalan Mahkum Kredi Tercih Etti. \nOtomatik %d kredi verildi.", GetConVarInt(g_Kredi_Miktari));
						delete hHudText;
					}
				}
				else
				{
					PrintToChat(client, "[SM] Bu Menü Şuanda Aktif Değil.");
				}
			}
			else
			{
				PrintToChat(client, "[SM] Bu Menü Şuanda Aktif Değil.");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu2;
		menu2 = null;
	}
}

public Action roundstartend(Event event, const char[] name, bool dontBroadcast)
{
	aktif = false;
}
