state("wolf2")
{
    string255 map : 0x952884, 0x4;
    float appTimeMS : 0xAF7380, 0x100, 0x36C;
    bool loading : "gamex86.dll", 0x875C6C;
    bool playingMovie : "binkw32.dll", 0x25438;
    bool missionComplete : "gamex86.dll", 0x875E8C, 0x268;
}

startup
{
    settings.Add("splits", true, "Using splits");
    settings.SetToolTip("splits", "Disable if you don't use splits and only want automatic start, stop and reset");

    settings.Add("splitHubs", true, "Split hub travel", "splits");
    settings.SetToolTip("splitHubs", "Disable if you only use splits when completing a level");

    settings.Add("midMapSplit", true, "Mid level splits", "splits");
    settings.SetToolTip("midMapSplit", "Disable if you don't have mid level splits. i.e. Castle -> Castle Top");
}

init
{
    vars.startTime = 0;
    vars.menuName = "/game/menu/menu.mpk";
    vars.tavernName = "/game/tavern/tavern.mpk";
    vars.zeppelinName = "/game/zeppelin/zeppelin.mpk";
    vars.blackSunName = "/game/blacksun/blacksun.mpk";
    vars.hubMaps = new [] {"/game/mtw/mtw.mpk", "/game/mte/mte.mpk", "/game/downtown/downtown.mpk", "/game/downtown/downtown_west.mpk"};
}

start
{
    if (current.map == vars.menuName && current.playingMovie)
    {
        vars.startTime = current.appTimeMS;
        return true;
    }
}

reset
{
    // don't reset during intro cutscene
    if (old.map == vars.menuName)
        return false;

    return current.map == vars.menuName;
}

split
{
    // split when timing ends
    if (current.map == vars.blackSunName && current.missionComplete)
        return true;

    if (!settings["splits"])
        return false;

    // dossier split
    if (current.map == old.map)
        return current.missionComplete && !old.missionComplete;

    // don't split on tavern
    if (current.map == vars.tavernName || old.map == vars.tavernName)
        return false;

    // don't split on main menu
    if (current.map == vars.menuName || old.map == vars.menuName)
        return false;

    // zeppelin and blacksun are special since there's no hub between level ends
    if (current.map == vars.zeppelinName || current.map == vars.blackSunName)
        return false;

    bool enteringHub = false;
    bool leavingHub = false;
    foreach (string hubMap in vars.hubMaps)
    {
        if (!enteringHub && current.map == hubMap)
            enteringHub = true;

        if (!leavingHub && old.map == hubMap)
            leavingHub = true;
    }

    if (settings["splitHubs"] && leavingHub)
        return true;

    if (settings["midMapSplit"] && !(enteringHub || leavingHub))
        return true;
}

isLoading
{
    return current.loading;
}

gameTime
{
    return TimeSpan.FromMilliseconds(current.appTimeMS - vars.startTime);
}