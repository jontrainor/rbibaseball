package rbi.managers;

import rbi.managers.ItemManager;
import rbi.data.TeamData;

class DataManager
{
    public static var itemManager:ItemManager;

    public static var teams:Array<TeamData>;
    public static var playerTeam:TeamData;
    public static var currentOpponent:TeamData;

    public static var musicVolume:Float = 0.0;
}