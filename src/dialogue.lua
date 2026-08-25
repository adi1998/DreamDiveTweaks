local biomeStartVoiceLinesPatch =
{
    XLeft =
    {
        ["/VO/MelinoeField_5502"] = 0,
        ["/VO/MelinoeField_5503"] = 0,
        ["/VO/MelinoeField_5504"] = 0,
        ["/VO/MelinoeField_5505"] = 0,
        ["/VO/MelinoeField_5506"] = 0,
        ["/VO/MelinoeField_5507"] = 0,
        ["/VO/MelinoeField_5508"] = 0,
        ["/VO/MelinoeField_5509"] = 0,
        ["/VO/MelinoeField_5510"] = 0,
        ["/VO/MelinoeField_5511"] = 0,
        ["/VO/MelinoeField_5512"] = 0,
        ["/VO/MelinoeField_5513"] = 0,
        ["/VO/MelinoeField_5514"] = 0,
        ["/VO/MelinoeField_5515"] = 0,
        ["/VO/MelinoeField_5516"] = 0,
        ["/VO/MelinoeField_5517"] = 0,
        ["/VO/MelinoeField_5518"] = 0,
        ["/VO/MelinoeField_5519"] = 0,
        ["/VO/MelinoeField_5520"] = 0,
        ["/VO/MelinoeField_5521"] = 0,
        ["/VO/MelinoeField_5522"] = 0,
    }
}

local roomExitVoiceLinesPatch =
{
    OnlyFour =
    {
        ["/VO/MelinoeField_5467"] = true,
        ["/VO/MelinoeField_5471"] = true,
    },
    XLeft =
    {
        ["/VO/MelinoeField_5464"] = 3,
        ["/VO/MelinoeField_5469"] = 2,
        ["/VO/MelinoeField_5472"] = 1,
        ["/VO/MelinoeField_5473"] = 1,
        ["/VO/MelinoeField_5474"] = 1,
    }
}

local hypnosPostBossVoiceLinesPatch =
{
    XLeft =
    {
        ["/VO/Intercom_8272"] = 1,
    },
    XRatioLeft =
    {
        ["/VO/Intercom_8267"] = 1/4,
    }
}

function mod.CheckDreamBiomesLeft(source, functionArgs, args)
    game.CurrentRun.EnteredBiomes = game.CurrentRun.EnteredBiomes or 0
    local result = functionArgs.BiomesLeft == game.GameData.FullRunBiomeCount - game.CurrentRun.EnteredBiomes
    if functionArgs.Invert then
        return not result
    end
    return result
end

function mod.CheckDreamBiomesLeftRatio(source, functionArgs, args)
    game.CurrentRun.EnteredBiomes = game.CurrentRun.EnteredBiomes or 0
    local result = functionArgs.BiomesLeftRatio <= (game.GameData.FullRunBiomeCount - game.CurrentRun.EnteredBiomes)/game.GameData.FullRunBiomeCount and
        functionArgs.BiomesLeftRatio > (game.GameData.FullRunBiomeCount - game.CurrentRun.EnteredBiomes - 1)/game.GameData.FullRunBiomeCount
    if functionArgs.Invert then
        return not result
    end
    return result
end

function FindAndReplaceXLeftRequirement(requirements, xleft, invert)
    for index, requirement in ipairs(requirements) do
        if requirement.Path and table.concat(requirement.Path) == table.concat({"CurrentRun", "EnteredBiomes"}) and requirement.Comparison == "==" then
            requirements[index] = {
                FunctionName = _PLUGIN.guid .. "." .. "CheckDreamBiomesLeft",
                FunctionArgs = {
                    BiomesLeft = xleft,
                    Invert = invert,
                }
            }
        end
    end
end

function FindAndReplaceXRatioLeftRequirement(requirements, xleft, invert)
    for index, requirement in ipairs(requirements) do
        if requirement.Path and table.concat(requirement.Path) == table.concat({"CurrentRun", "EnteredBiomes"}) and requirement.Comparison == "==" then
            requirements[index] = {
                FunctionName = _PLUGIN.guid .. "." .. "CheckDreamBiomesLeftRatio",
                FunctionArgs = {
                    BiomesLeftRatio = xleft,
                    Invert = invert,
                }
            }
        end
    end
end

function PatchDreamRunVoiceLineRequirements_CueList(cueList, patchInfo)
    for _, cue in ipairs(cueList) do
        if patchInfo.XLeft and patchInfo.XLeft[cue.Cue] then
            local xleft = patchInfo.XLeft[cue.Cue]
            cue.GameStateRequirements = cue.GameStateRequirements or {}
            FindAndReplaceXLeftRequirement(cue.GameStateRequirements, xleft)
        end
        if patchInfo.OnlyFour and patchInfo.OnlyFour[cue.Cue] then
            table.insert(cue.GameStateRequirements, {
                Path = {"GameData", "FullRunBiomeCount"},
                Comparison = "==",
                Value = 4,
            })
        end
        if patchInfo.XRatioLeft and patchInfo.XRatioLeft[cue.Cue] then
            local xratioleft = patchInfo.XRatioLeft[cue.Cue]
            cue.GameStateRequirements = cue.GameStateRequirements or {}
            FindAndReplaceXRatioLeftRequirement(cue.GameStateRequirements, xratioleft)
        end
    end
end

function PatchDreamRunVoiceLineRequirements(cueListSet, patchInfo)
    for _, cueList in ipairs(cueListSet) do
        PatchDreamRunVoiceLineRequirements_CueList(cueList, patchInfo)
    end
end

PatchDreamRunVoiceLineRequirements(game.HeroVoiceLines.DreamBiomeStartVoiceLines, biomeStartVoiceLinesPatch)
PatchDreamRunVoiceLineRequirements(game.HeroVoiceLines.DreamRoomExitVoiceLines, roomExitVoiceLinesPatch)
PatchDreamRunVoiceLineRequirements_CueList(game.GlobalVoiceLines.HypnosPostBossVoiceLines, hypnosPostBossVoiceLinesPatch)

FindAndReplaceXLeftRequirement(game.GlobalVoiceLines.DreamRunFinalBossGreetingVoiceLines.GameStateRequirements or {}, 0)
FindAndReplaceXLeftRequirement(game.EnemyData.TyphonHead.DefeatedVoiceLines[2].GameStateRequirements or {}, 0, true)