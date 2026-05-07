$ErrorActionPreference = "Stop"

$target = "Y:\STATIONEERS_LOGIC_DB"
New-Item -ItemType Directory -Force -Path $target | Out-Null

function New-Obj($h) {
    [pscustomobject]$h
}

$sourceDate = "2026-05-06"
$sources = @(
    [pscustomobject]@{
        id = "stationeers_wiki_ic10"
        url = "https://stationeers-wiki.com/IC10"
        role = "Primary IC10 behavior, addressing, data-network channels, device variables, slot variables"
        observed_last_modified = "2026-04-05"
    },
    [pscustomobject]@{
        id = "stationeers_wiki_ic10_instructions"
        url = "https://stationeers-wiki.com/IC10/instructions"
        role = "Instruction signatures and instruction set descriptions"
        observed_last_modified = "2026-01-17"
    },
    [pscustomobject]@{
        id = "stationeers_wiki_module_ic10"
        url = "https://stationeers-wiki.com/Module:IC10"
        role = "Current wiki syntax highlighter opcode list and LogicType token list"
        observed_last_modified = "2026-03-27"
    },
    [pscustomobject]@{
        id = "stationeers_wiki_data_network_category"
        url = "https://stationeers-wiki.com/Category:Data_Network"
        role = "Data Network page index"
        observed_last_modified = "2018-04-08"
    }
)

$opcodes = @(
    "alias","define","hcf","sleep","yield",
    "abs","add","ceil","div","pow","exp","floor","log","max","min","mod","move","mul","rand","round","sqrt","sub","trunc","lerp",
    "acos","asin","atan","atan2","cos","sin","tan",
    "clr","clrd","get","getd","peek","poke","pop","push","put","putd",
    "l","lr","ls","s","ss","rmap","ld","sd",
    "lb","lbn","lbns","lbs","sb","sbn","sbs",
    "and","nor","not","or","sla","sll","sra","srl","xor","ext","ins",
    "select","sdns","sdse","sap","sapz","seq","seqz","sge","sgez","sgt","sgtz","sle","slez","slt","sltz","sna","snan","snanz","snaz","sne","snez",
    "j","jal","jr",
    "bdnvl","bdnvs","bdns","bdnsal","bdse","bdseal","brdns","brdse",
    "bap","brap","bapal","bapz","brapz","bapzal",
    "beq","breq","beqal","beqz","breqz","beqzal",
    "bge","brge","bgeal","bgez","brgez","bgezal",
    "bgt","brgt","bgtal","bgtz","brgtz","bgtzal",
    "ble","brle","bleal","blez","brlez","blezal",
    "blt","brlt","bltal","bltz","brltz","bltzal",
    "bna","brna","bnaal","bnan","brnan","bnaz","brnaz","bnazal",
    "bne","brne","bneal","bnez","brnez","bnezal"
)

$logicTypes = @(
    "None","Power","Open","Mode","Error",
    "Pressure","Temperature","PressureExternal","PressureInternal",
    "Activate","Lock","Charge","Setting",
    "Reagents",
    "RatioOxygen","RatioCarbonDioxide","RatioNitrogen","RatioPollutant","RatioVolatiles","RatioWater",
    "Horizontal","Vertical","SolarAngle","Maximum",
    "Ratio",
    "PowerPotential","PowerActual",
    "Quantity",
    "On",
    "ImportQuantity","ImportSlotOccupant","ExportQuantity","ExportSlotOccupant",
    "RequiredPower",
    "HorizontalRatio","VerticalRatio",
    "PowerRequired","Idle",
    "Color",
    "ElevatorSpeed","ElevatorLevel",
    "RecipeHash",
    "ExportSlotHash","ImportSlotHash",
    "PlantHealth1","PlantHealth2","PlantHealth3","PlantHealth4",
    "PlantGrowth1","PlantGrowth2","PlantGrowth3","PlantGrowth4",
    "PlantEfficiency1","PlantEfficiency2","PlantEfficiency3","PlantEfficiency4",
    "PlantHash1","PlantHash2","PlantHash3","PlantHash4",
    "RequestHash","CompletionRatio","ClearMemory","ExportCount","ImportCount",
    "PowerGeneration",
    "TotalMoles","Volume",
    "Plant","Harvest","Output",
    "PressureSetting","TemperatureSetting","TemperatureExternal","Filtration","AirRelease",
    "PositionX","PositionY","PositionZ",
    "VelocityMagnitude","VelocityRelativeX","VelocityRelativeY","VelocityRelativeZ",
    "RatioNitrousOxide",
    "PrefabHash",
    "ForceWrite",
    "SignalStrength","SignalID","TargetX","TargetY","TargetZ","SettingInput","SettingOutput",
    "CurrentResearchPodType","ManualResearchRequiredPod",
    "MineablesInVicinity","MineablesInQueue",
    "NextWeatherEventTime",
    "Combustion",
    "Fuel","ReturnFuelCost","CollectableGoods",
    "Time","Bpm",
    "EnvironmentEfficiency","WorkingGasEfficiency",
    "PressureInput","TemperatureInput",
    "RatioOxygenInput","RatioCarbonDioxideInput","RatioNitrogenInput","RatioPollutantInput","RatioVolatilesInput","RatioWaterInput","RatioNitrousOxideInput",
    "TotalMolesInput",
    "PressureInput2","TemperatureInput2",
    "RatioOxygenInput2","RatioCarbonDioxideInput2","RatioNitrogenInput2","RatioPollutantInput2","RatioVolatilesInput2","RatioWaterInput2","RatioNitrousOxideInput2",
    "TotalMolesInput2",
    "PressureOutput","TemperatureOutput",
    "RatioOxygenOutput","RatioCarbonDioxideOutput","RatioNitrogenOutput","RatioPollutantOutput","RatioVolatilesOutput","RatioWaterOutput","RatioNitrousOxideOutput",
    "TotalMolesOutput",
    "PressureOutput2","TemperatureOutput2",
    "RatioOxygenOutput2","RatioCarbonDioxideOutput2","RatioNitrogenOutput2","RatioPollutantOutput2","RatioVolatilesOutput2","RatioWaterOutput2","RatioNitrousOxideOutput2",
    "TotalMolesOutput2",
    "CombustionInput","CombustionInput2","CombustionOutput","CombustionOutput2",
    "OperationalTemperatureEfficiency","TemperatureDifferentialEfficiency","PressureEfficiency",
    "CombustionLimiter","Throttle","Rpm","Stress",
    "InterrogationProgress","TargetPadIndex","SizeX","SizeY","SizeZ","MinimumWattsToContact","WattsReachingContact",
    "Channel0","Channel1","Channel2","Channel3","Channel4","Channel5","Channel6","Channel7",
    "LineNumber",
    "Flush","SoundAlert",
    "SolarIrradiance",
    "RatioLiquidNitrogen","RatioLiquidNitrogenInput","RatioLiquidNitrogenInput2","RatioLiquidNitrogenOutput","RatioLiquidNitrogenOutput2",
    "VolumeOfLiquid",
    "RatioLiquidOxygen","RatioLiquidOxygenInput","RatioLiquidOxygenInput2","RatioLiquidOxygenOutput","RatioLiquidOxygenOutput2",
    "RatioLiquidVolatiles","RatioLiquidVolatilesInput","RatioLiquidVolatilesInput2","RatioLiquidVolatilesOutput","RatioLiquidVolatilesOutput2",
    "RatioSteam","RatioSteamInput","RatioSteamInput2","RatioSteamOutput","RatioSteamOutput2",
    "ContactTypeId",
    "RatioLiquidCarbonDioxide","RatioLiquidCarbonDioxideInput","RatioLiquidCarbonDioxideInput2","RatioLiquidCarbonDioxideOutput","RatioLiquidCarbonDioxideOutput2",
    "RatioLiquidPollutant","RatioLiquidPollutantInput","RatioLiquidPollutantInput2","RatioLiquidPollutantOutput","RatioLiquidPollutantOutput2",
    "RatioLiquidNitrousOxide","RatioLiquidNitrousOxideInput","RatioLiquidNitrousOxideInput2","RatioLiquidNitrousOxideOutput","RatioLiquidNitrousOxideOutput2",
    "Progress","DestinationCode","Acceleration","ReferenceId","AutoShutOff","Mass","DryMass","Thrust","Weight","ThrustToWeight","TimeToDestination","BurnTimeRemaining",
    "AutoLand","ForwardX","ForwardY","ForwardZ","Orientation","VelocityX","VelocityY","VelocityZ",
    "PassedMoles","ExhaustVelocity",
    "FlightControlRule","ReEntryAltitude","Apex",
    "EntityState","DrillCondition",
    "Index","CelestialHash","AlignmentError","DistanceAu","OrbitPeriod","Inclination","Eccentricity","SemiMajorAxis","DistanceKm","CelestialParentHash","TrueAnomaly",
    "RatioHydrogen","RatioLiquidHydrogen","RatioPollutedWater",
    "Discover","Chart","Survey","NavPoints","ChartedNavPoints","Sites","CurrentCode","Density","Richness","Size","TotalQuantity","MinedQuantity",
    "BestContactFilter",
    "NameHash",
    "Altitude",
    "TargetSlotIndex","TargetPrefabHash",
    "Extended",
    "NetworkFault",
    "ProportionalGain","IntegralGain","DerivativeGain","Minimum","Setpoint","Reset",
    "StackSize",
    "NextWeatherHash",
    "ContactSlotIndex",
    "RatioHydrazine","RatioLiquidHydrazine","RatioLiquidAlcohol","RatioHelium","RatioLiquidSodiumChloride","RatioSilanol","RatioLiquidSilanol",
    "RatioHydrochloricAcid","RatioLiquidHydrochloricAcid","RatioOzone","RatioLiquidOzone",
    "RatioHydrogenInput","RatioHydrogenInput2","RatioHydrogenOutput","RatioHydrogenOutput2",
    "RatioLiquidHydrogenInput","RatioLiquidHydrogenInput2","RatioLiquidHydrogenOutput","RatioLiquidHydrogenOutput2",
    "RatioPollutedWaterInput","RatioPollutedWaterInput2","RatioPollutedWaterOutput","RatioPollutedWaterOutput2",
    "RatioHydrazineInput","RatioHydrazineInput2","RatioHydrazineOutput","RatioHydrazineOutput2",
    "RatioLiquidHydrazineInput","RatioLiquidHydrazineInput2","RatioLiquidHydrazineOutput","RatioLiquidHydrazineOutput2",
    "RatioLiquidAlcoholInput","RatioLiquidAlcoholInput2","RatioLiquidAlcoholOutput","RatioLiquidAlcoholOutput2",
    "RatioHeliumInput","RatioHeliumInput2","RatioHeliumOutput","RatioHeliumOutput2",
    "RatioLiquidSodiumChlorideInput","RatioLiquidSodiumChlorideInput2","RatioLiquidSodiumChlorideOutput","RatioLiquidSodiumChlorideOutput2",
    "RatioSilanolInput","RatioSilanolInput2","RatioSilanolOutput","RatioSilanolOutput2",
    "RatioHydrochloricAcidInput","RatioHydrochloricAcidInput2","RatioHydrochloricAcidOutput","RatioHydrochloricAcidOutput2",
    "RatioLiquidHydrochloricAcidInput","RatioLiquidHydrochloricAcidInput2","RatioLiquidHydrochloricAcidOutput","RatioLiquidHydrochloricAcidOutput2",
    "RatioOzoneInput","RatioOzoneInput2","RatioOzoneOutput","RatioOzoneOutput2",
    "RatioLiquidOzoneInput","RatioLiquidOzoneInput2","RatioLiquidOzoneOutput","RatioLiquidOzoneOutput2"
)

function Get-LogicTypeRole([string]$name) {
    if ($name -like "Channel?") { return "volatile_network_channel" }
    if ($name -in @("On","Open","Activate","Lock","Mode","Setting","Output","Plant","Harvest","ClearMemory","ForceWrite","Flush","SoundAlert","Reset","Discover","Chart","Survey","AutoShutOff","AutoLand","Extended")) { return "actuator_or_control" }
    if ($name -in @("PrefabHash","ReferenceId","NameHash","RecipeHash","RequestHash","TargetPrefabHash","CelestialHash","NextWeatherHash","ContactTypeId","ContactSlotIndex","TargetSlotIndex")) { return "identity_hash_or_reference" }
    if ($name -match "Pressure|Temperature|TotalMoles|Combustion|Volume|Ratio") { return "atmosphere_liquid_or_chemistry" }
    if ($name -match "Power|Watts|Charge|Fuel|Throttle|Rpm|Stress|Thrust|Weight") { return "power_energy_or_engine" }
    if ($name -match "Position|Velocity|Target|Forward|Altitude|Distance|Orbit|Alignment|Apex|Destination") { return "position_navigation_or_motion" }
    if ($name -match "Plant|Growth|Health|Efficiency|Mature") { return "plant_or_agriculture" }
    return "general_device_value"
}

$logicTypeObjects = for ($i = 0; $i -lt $logicTypes.Count; $i++) {
    [pscustomobject]@{
        name = $logicTypes[$i]
        ordinal_from_wiki_order = $i
        token = $logicTypes[$i]
        constant_token = "LogicType.$($logicTypes[$i])"
        role = Get-LogicTypeRole $logicTypes[$i]
        codex_rule = "Prefer the symbolic token in code. Use numeric ordinal only when a script deliberately iterates LogicType constants."
    }
}

$slotTypeRows = @(
    @("Occupied","bool","read","1 if slot has an occupant; 0 if empty."),
    @("OccupantHash","int","read","Prefab hash of the item in the slot; 0 if empty."),
    @("Quantity","number","read","Stack quantity or device-specific quantity for the slot."),
    @("Damage","number","read","Damage/durability state for slotted item."),
    @("Efficiency","number","read","Efficiency value for slotted item/plant/device context."),
    @("FilterType","bitmask","read","Installed filter gas/liquid type bitmask; useful for filtration devices."),
    @("Health","number","read","Health for slotted organism/item when exposed by device."),
    @("Growth","number","read","Plant growth stage/value when exposed by hydroponics or plant slots."),
    @("Pressure","number","read","Pressure related to slotted container/device context."),
    @("Temperature","number","read","Temperature related to slotted container/device context."),
    @("Charge","number","read","Charge value for battery/tool/robot slots."),
    @("ChargeRatio","ratio","read","Charge as 0..1 ratio when exposed by slot."),
    @("Class","int","read","Class id used by sorters and slot comparisons."),
    @("SortingClass","int","read","Observed in sorter slot docs; class group for sorting behavior."),
    @("PressureWaste","number","read","Waste pressure for suit/tank/device slots."),
    @("PressureAir","number","read","Air pressure for suit/tank/device slots."),
    @("MaxQuantity","int","read","Maximum stack size or maximum slot quantity."),
    @("Mature","tri_bool","read","Plant maturity status; commonly 1 mature, 0 immature, -1 empty/not applicable."),
    @("Seeding","tri_bool","read","Plant seeding status observed in hydroponics examples; device-specific."),
    @("PrefabHash","int","read","Observed in some device slot tables; item prefab hash in slot."),
    @("ReferenceId","int","read","Unique reference id where exposed by slot/device context.")
)

$logicSlotTypes = foreach ($row in $slotTypeRows) {
    [pscustomobject]@{
        name = $row[0]
        value_type = $row[1]
        default_access = $row[2]
        summary = $row[3]
        command_tokens = @("ls","lbs","lbns","ss","sbs")
        codex_rule = "Only use this LogicSlotType when Stationpedia/wiki says the target slot exposes it; slot index is device-specific."
    }
}

$instructions = @()
function Add-Instruction($opcode,$category,$syntax,$effect,$args=@(),$returns=$null,$tags=@(),$notes=@(),$sourceIds=@("stationeers_wiki_ic10_instructions")) {
    $script:instructions += [pscustomobject]@{
        opcode = $opcode
        category = $category
        syntax = $syntax
        effect = $effect
        args = $args
        returns = $returns
        tags = $tags
        notes = $notes
        source_ids = $sourceIds
    }
}

Add-Instruction "alias" "utility" "alias name r?|d?" "Names a register or device pin for clearer scripts; device aliases also label screw selections on the IC housing." @("name","register_or_device") $null @("readability","install_config")
Add-Instruction "define" "utility" "define name num" "Compile-time constant replacement." @("name","number") $null @("constant")
Add-Instruction "hcf" "utility" "hcf" "Halts script execution." @() $null @("debug","halt")
Add-Instruction "sleep" "utility" "sleep seconds(r?|num)" "Pauses execution for a time in seconds." @("seconds") $null @("timing")
Add-Instruction "yield" "utility" "yield" "Pauses execution for one tick; put inside long-running control loops." @() $null @("timing","loop")

$mathRows = @(
    @("abs","abs r? a","dst = abs(a)"),
    @("add","add r? a b","dst = a + b"),
    @("ceil","ceil r? a","dst = smallest integer >= a"),
    @("div","div r? a b","dst = a / b"),
    @("pow","pow r? a b","dst = a raised to b"),
    @("exp","exp r? a","dst = e^a"),
    @("floor","floor r? a","dst = greatest integer <= a"),
    @("log","log r? a","dst = natural log of a"),
    @("max","max r? a b","dst = max(a,b)"),
    @("min","min r? a b","dst = min(a,b)"),
    @("mod","mod r? a b","dst = mathematical modulo of a by b"),
    @("move","move r? a","dst = a"),
    @("mul","mul r? a b","dst = a * b"),
    @("rand","rand r?","dst = random number where 0 <= x < 1"),
    @("round","round r? a","dst = nearest integer to a"),
    @("sqrt","sqrt r? a","dst = sqrt(a)"),
    @("sub","sub r? a b","dst = a - b"),
    @("trunc","trunc r? a","dst = a with fractional part removed"),
    @("lerp","lerp r? a b c","dst = linear interpolation from a to b by c clamped to 0..1"),
    @("acos","acos r? a","dst = arccos(a) radians"),
    @("asin","asin r? a","dst = arcsin(a) radians"),
    @("atan","atan r? a","dst = arctan(a) radians"),
    @("atan2","atan2 r? y x","dst = atan2(y,x) radians"),
    @("cos","cos r? a","dst = cosine of radian angle a"),
    @("sin","sin r? a","dst = sine of radian angle a"),
    @("tan","tan r? a","dst = tangent of radian angle a")
)
foreach ($m in $mathRows) { Add-Instruction $m[0] "math" $m[1] $m[2] @("dst","a","b_or_c_optional") "register" @("numeric") }

$stackRows = @(
    @("clr","clr d?","Clear stack memory for a device pin."),
    @("clrd","clrd id","Clear stack memory for a device by ReferenceId."),
    @("get","get r? device address","Read stack value at address from device into register."),
    @("getd","getd r? id address","Read stack value at address from device ReferenceId into register."),
    @("peek","peek r?","Read current top-of-stack into register."),
    @("poke","poke address value","Write value to IC stack at address."),
    @("pop","pop r?","Read top-of-stack into register and decrement sp."),
    @("push","push value","Write value at sp and increment sp."),
    @("put","put device address value","Write value to stack address on device."),
    @("putd","putd id address value","Write value to stack address on device ReferenceId.")
)
foreach ($s in $stackRows) { Add-Instruction $s[0] "stack" $s[1] $s[2] @("varies") $null @("stack","device_memory") }

Add-Instruction "l" "slot_logic" "l r? device(d?|r?|id|d?:connection) logicType" "Load a device LogicType into a register. Device operand can be pin, alias, register/id reference, db, or connection reference for channels." @("dst","device","logicType") "register" @("network_read","device_io")
Add-Instruction "lr" "slot_logic" "lr r? device(d?|r?|id) reagentMode reagentHash" "Load reagent quantity/value for Contents, Required, or Recipe reagent mode." @("dst","device","reagentMode","reagentHash") "register" @("chemistry","reagent")
Add-Instruction "ls" "slot_logic" "ls r? device(d?|r?|id) slotIndex logicSlotType" "Load a LogicSlotType from a device slot into a register." @("dst","device","slotIndex","logicSlotType") "register" @("network_read","slot")
Add-Instruction "s" "slot_logic" "s device(d?|r?|id|d?:connection) logicType value(r?|num)" "Store value to a writable device LogicType. Use with d0-d5, db, aliases, ReferenceId/register references, or connection channels." @("device","logicType","value") $null @("network_write","device_io")
Add-Instruction "ss" "slot_logic" "ss device(d?|r?|id) slotIndex logicSlotType value(r?|num)" "Store value to a writable slot LogicSlotType; support is device/slot-specific." @("device","slotIndex","logicSlotType","value") $null @("network_write","slot")
Add-Instruction "rmap" "slot_logic" "rmap r? d? reagentHash(r?|num)" "Map a reagent hash to the prefab hash expected by a production device." @("dst","device","reagentHash") "prefab_hash" @("chemistry","recipe")
Add-Instruction "ld" "slot_logic_legacy" "ld r? referenceId(r?|num) logicType" "Legacy/direct-reference load by ReferenceId. Current l syntax can also take id/register device operands." @("dst","referenceId","logicType") "register" @("reference_id","compat") @("Listed on IC10 page direct-reference section; prefer l when current IC editor accepts id/register operand.") @("stationeers_wiki_ic10")
Add-Instruction "sd" "slot_logic_legacy" "sd referenceId(r?|num) logicType value(r?|num)" "Legacy/direct-reference store by ReferenceId. Current s syntax can also take id/register device operands." @("referenceId","logicType","value") $null @("reference_id","compat") @("Listed on IC10 page direct-reference section; prefer s when current IC editor accepts id/register operand.") @("stationeers_wiki_ic10")

Add-Instruction "lb" "batch_io" "lb r? deviceHash logicType batchMode" "Batch-load LogicType from all output-network devices with matching prefab hash using Average, Sum, Minimum, or Maximum." @("dst","deviceHash","logicType","batchMode") "register" @("batch_read")
Add-Instruction "lbn" "batch_io" "lbn r? deviceHash nameHash logicType batchMode" "Batch-load LogicType from matching prefab hash and name hash." @("dst","deviceHash","nameHash","logicType","batchMode") "register" @("batch_read","name_hash")
Add-Instruction "lbs" "batch_io" "lbs r? deviceHash slotIndex logicSlotType batchMode" "Batch-load slot LogicSlotType from all matching prefab hash devices." @("dst","deviceHash","slotIndex","logicSlotType","batchMode") "register" @("batch_read","slot")
Add-Instruction "lbns" "batch_io" "lbns r? deviceHash nameHash slotIndex logicSlotType batchMode" "Batch-load slot LogicSlotType from matching prefab hash and name hash." @("dst","deviceHash","nameHash","slotIndex","logicSlotType","batchMode") "register" @("batch_read","slot","name_hash")
Add-Instruction "sb" "batch_io" "sb deviceHash logicType value(r?|num)" "Store value to LogicType on every output-network device matching prefab hash." @("deviceHash","logicType","value") $null @("batch_write")
Add-Instruction "sbn" "batch_io" "sbn deviceHash nameHash logicType value(r?|num)" "Store value to LogicType on every matching prefab hash and name hash device." @("deviceHash","nameHash","logicType","value") $null @("batch_write","name_hash")
Add-Instruction "sbs" "batch_io" "sbs deviceHash slotIndex logicSlotType value(r?|num)" "Store value to a slot LogicSlotType on every matching prefab hash device." @("deviceHash","slotIndex","logicSlotType","value") $null @("batch_write","slot")

$bitRows = @(
    @("and","and r? a b","bitwise AND"),
    @("nor","nor r? a b","bitwise NOR"),
    @("not","not r? a","bitwise complement; use seqz for logical not of 0/1 values"),
    @("or","or r? a b","bitwise OR"),
    @("sla","sla r? a b","arithmetic left shift; currently effectively same as sll"),
    @("sll","sll r? a b","logical left shift"),
    @("sra","sra r? a b","arithmetic right shift"),
    @("srl","srl r? a b","logical right shift"),
    @("xor","xor r? a b","bitwise XOR"),
    @("ext","ext r? source offset length","extract bit field"),
    @("ins","ins r? field offset length","insert bit field into dst; verify stable-version argument order if targeting old builds")
)
foreach ($b in $bitRows) { Add-Instruction $b[0] "bitwise" $b[1] $b[2] @("dst","a","b") "register" @("bitwise") }

$cmpRows = @(
    @("select","select r? condition trueValue falseValue","dst = trueValue if condition nonzero else falseValue"),
    @("sdns","sdns r? device","dst = 1 if device is not set else 0"),
    @("sdse","sdse r? device","dst = 1 if device is set else 0"),
    @("sap","sap r? a b tolerance","approx-equal comparison"),
    @("sapz","sapz r? a tolerance","approx-zero comparison"),
    @("seq","seq r? a b","dst = 1 if a == b else 0"),
    @("seqz","seqz r? a","dst = 1 if a == 0 else 0"),
    @("sge","sge r? a b","dst = 1 if a >= b else 0"),
    @("sgez","sgez r? a","dst = 1 if a >= 0 else 0"),
    @("sgt","sgt r? a b","dst = 1 if a > b else 0"),
    @("sgtz","sgtz r? a","dst = 1 if a > 0 else 0"),
    @("sle","sle r? a b","dst = 1 if a <= b else 0"),
    @("slez","slez r? a","dst = 1 if a <= 0 else 0"),
    @("slt","slt r? a b","dst = 1 if a < b else 0"),
    @("sltz","sltz r? a","dst = 1 if a < 0 else 0"),
    @("sna","sna r? a b tolerance","approx-not-equal comparison"),
    @("snan","snan r? a","dst = 1 if a is NaN else 0"),
    @("snanz","snanz r? a","dst = 0 if a is NaN else 1"),
    @("snaz","snaz r? a tolerance","not-approx-zero comparison"),
    @("sne","sne r? a b","dst = 1 if a != b else 0"),
    @("snez","snez r? a","dst = 1 if a != 0 else 0")
)
foreach ($c in $cmpRows) { Add-Instruction $c[0] "comparison" $c[1] $c[2] @("dst","a","b_or_tolerance_optional") "register_bool" @("comparison") }

Add-Instruction "j" "branch" "j target" "Absolute jump to line number, label, or register such as ra." @("target") $null @("branch")
Add-Instruction "jal" "branch" "jal target" "Jump and store next line in ra for subroutine return." @("target") $null @("branch","call")
Add-Instruction "jr" "branch" "jr relativeOffset" "Relative jump by offset." @("relativeOffset") $null @("branch","relative")
Add-Instruction "bdnvl" "branch_device" "bdnvl device logicType target" "Branch if device is not valid for loading the LogicType." @("device","logicType","target") $null @("guard","device_io")
Add-Instruction "bdnvs" "branch_device" "bdnvs device logicType target" "Branch if device is not valid for storing the LogicType." @("device","logicType","target") $null @("guard","device_io")
Add-Instruction "bdns" "branch_device" "bdns d? target" "Branch if device pin is not set." @("device","target") $null @("guard")
Add-Instruction "bdnsal" "branch_device" "bdnsal d? target" "Branch-and-link if device pin is not set." @("device","target") $null @("guard","call")
Add-Instruction "bdse" "branch_device" "bdse d? target" "Branch if device pin is set." @("device","target") $null @("guard")
Add-Instruction "bdseal" "branch_device" "bdseal d? target" "Branch-and-link if device pin is set." @("device","target") $null @("guard","call")
Add-Instruction "brdns" "branch_device" "brdns d? relativeOffset" "Relative branch if device pin is not set." @("device","relativeOffset") $null @("guard","relative")
Add-Instruction "brdse" "branch_device" "brdse d? relativeOffset" "Relative branch if device pin is set." @("device","relativeOffset") $null @("guard","relative")

$branchFamilies = @(
    [pscustomobject]@{ root="ap"; condition="approx_equal(a,b,tolerance)"; arity="a b tolerance target"; zeroArity="a tolerance target" },
    [pscustomobject]@{ root="eq"; condition="a == b"; arity="a b target"; zeroArity="a target" },
    [pscustomobject]@{ root="ge"; condition="a >= b"; arity="a b target"; zeroArity="a target" },
    [pscustomobject]@{ root="gt"; condition="a > b"; arity="a b target"; zeroArity="a target" },
    [pscustomobject]@{ root="le"; condition="a <= b"; arity="a b target"; zeroArity="a target" },
    [pscustomobject]@{ root="lt"; condition="a < b"; arity="a b target"; zeroArity="a target" },
    [pscustomobject]@{ root="na"; condition="not approx_equal(a,b,tolerance)"; arity="a b tolerance target"; zeroArity="a tolerance target" },
    [pscustomobject]@{ root="ne"; condition="a != b"; arity="a b target"; zeroArity="a target" }
)
foreach ($f in $branchFamilies) {
    $base = "b$($f.root)"
    Add-Instruction $base "branch_compare" "$base $($f.arity)" "Branch to absolute target if $($f.condition)." @("a","b","target") $null @("branch","comparison")
    $br = "br$($f.root)"
    Add-Instruction $br "branch_compare" "$br $($f.arity)" "Relative branch if $($f.condition)." @("a","b","relativeTarget") $null @("branch","comparison","relative")
    $al = "b$($f.root)al"
    Add-Instruction $al "branch_compare" "$al $($f.arity)" "Branch and store next line in ra if $($f.condition)." @("a","b","target") $null @("branch","comparison","call")
    $z = "b$($f.root)z"
    Add-Instruction $z "branch_compare" "$z $($f.zeroArity)" "Branch to absolute target if zero-form condition for $($f.root) is true." @("a","target") $null @("branch","comparison","zero")
    $brz = "br$($f.root)z"
    Add-Instruction $brz "branch_compare" "$brz $($f.zeroArity)" "Relative branch if zero-form condition for $($f.root) is true." @("a","relativeTarget") $null @("branch","comparison","zero","relative")
    $zal = "b$($f.root)zal"
    Add-Instruction $zal "branch_compare" "$zal $($f.zeroArity)" "Branch and store next line in ra if zero-form condition for $($f.root) is true." @("a","target") $null @("branch","comparison","zero","call")
}
Add-Instruction "bnan" "branch_compare" "bnan a target" "Branch if a is NaN." @("a","target") $null @("branch","nan")
Add-Instruction "brnan" "branch_compare" "brnan a relativeTarget" "Relative branch if a is NaN." @("a","relativeTarget") $null @("branch","nan","relative")

$batchModes = @(
    [pscustomobject]@{ name="Average"; value=0; aliases=@("0"); use="Mean value across matching devices." },
    [pscustomobject]@{ name="Sum"; value=1; aliases=@("1"); use="Sum values across matching devices." },
    [pscustomobject]@{ name="Minimum"; value=2; aliases=@("Min","2"); use="Lowest value across matching devices. Useful to detect missing ReferenceId with ninf guard." },
    [pscustomobject]@{ name="Maximum"; value=3; aliases=@("Max","3"); use="Highest value across matching devices. Useful for picking a single ReferenceId." }
)

$reagentModes = @(
    [pscustomobject]@{ name="Contents"; value=0; use="Current contents in device reagent storage." },
    [pscustomobject]@{ name="Required"; value=1; use="Required reagents for current request." },
    [pscustomobject]@{ name="Recipe"; value=2; use="Recipe reagent quantities." }
)

$filterTypeBitmask = @(
    [pscustomobject]@{ name="Oxygen"; value=1 },
    [pscustomobject]@{ name="Nitrogen"; value=2 },
    [pscustomobject]@{ name="CarbonDioxide"; value=4 },
    [pscustomobject]@{ name="Volatiles"; value=8 },
    [pscustomobject]@{ name="Pollutants"; value=16 },
    [pscustomobject]@{ name="Water"; value=32 },
    [pscustomobject]@{ name="NitrousOxide"; value=64 },
    [pscustomobject]@{ name="Hydrogen"; value=16384 },
    [pscustomobject]@{ name="PollutedWater"; value=65536 },
    [pscustomobject]@{ name="Hydrazine"; value=131072 },
    [pscustomobject]@{ name="Alcohol"; value=524288 },
    [pscustomobject]@{ name="Helium"; value=1048576 },
    [pscustomobject]@{ name="LiquidSodiumChloride"; value=2097152 },
    [pscustomobject]@{ name="Silanol"; value=4194304 },
    [pscustomobject]@{ name="HydrochloricAcid"; value=16777216 },
    [pscustomobject]@{ name="Ozone"; value=67108864 }
)

$dataNetwork = [pscustomobject]@{
    device_registers = [pscustomobject]@{
        pins = @("d0","d1","d2","d3","d4","d5")
        mounted_device = "db"
        register_count = 16
        general_rule = "Use d0-d5 when installer selects devices with IC housing screws. Use db for the device the IC is inserted into."
        defensive_rule = "Use bdns/bdse to guard missing pins and bdnvl/bdnvs to guard unsupported LogicType load/store before touching optional devices."
    }
    addressing = @(
        [pscustomobject]@{ kind="pin"; example="l r0 d0 Temperature"; when_to_use="Small reusable controllers configured by screwdriver." },
        [pscustomobject]@{ kind="mounted_device"; example="s db Setting r0"; when_to_use="IC Housing self I/O or motherboard/embedded IC on device." },
        [pscustomobject]@{ kind="reference_id"; example="l r0 rId On"; when_to_use="A register or literal stores a device ReferenceId found by lbn/lb or Stationpedia." },
        [pscustomobject]@{ kind="batch_prefab"; example='sb HASH("StructureWallLight") On 1'; when_to_use="Control all devices of one prefab on output network." },
        [pscustomobject]@{ kind="batch_prefab_and_name"; example='sbn HASH("StructureLogicSorter") HASH("Sorter Corn") Mode 1'; when_to_use="Control named groups after labeling devices." },
        [pscustomobject]@{ kind="connection_channel"; example="s db:1 Channel0 r0"; when_to_use="Read/write volatile cable-network Channel0..Channel7 through a specific device connection." }
    )
    channels = [pscustomobject]@{
        names = @("Channel0","Channel1","Channel2","Channel3","Channel4","Channel5","Channel6","Channel7")
        scope = "Cable-network connection values accessed as LogicTypes through device:connection syntax."
        volatile = $true
        defaults_to = "NaN"
        lost_when = @("world exit","any part of cable network changed, removed, or added")
        codex_rule = "Use channels for transient inter-network messaging, not durable memory. Guard NaN with snan/snanz before using a channel value."
    }
    hashing = [pscustomobject]@{
        macro = 'HASH("Name")'
        hashes = "Signed 32-bit integers. PrefabHash identifies structure/item prefab; NameHash identifies label text."
        discovery = @(
            "l rHash d0 PrefabHash",
            "l rName d0 NameHash",
            'lbn rId HASH("StructureLogicSorter") HASH("Sorter Corn") ReferenceId Maximum'
        )
    }
    batch_write_missing = "There is no documented sbns instruction; name-filtered slot batch write is not available in the normal instruction set."
    stationpedia_rule = "For exact per-device writable/readable LogicType and slot support, Stationpedia is authoritative; this database stores global commands and high-signal common patterns."
}

$generationRules = @(
    "Prefer symbolic LogicType names such as On, Open, Setting, Temperature. Use LogicType.Name numeric constants only for dynamic iteration.",
    "Most automation scripts should loop with yield to avoid single-run behavior.",
    "Never assume every device supports On, Open, Setting, or Temperature. Use Stationpedia/device profile data, or guard with bdnvl/bdnvs.",
    "Use aliases for every r? and d? in generated scripts.",
    "Use batch commands for groups and named devices; use pins for installer-configurable scripts.",
    "When controlling a value from sensors, implement hysteresis with two thresholds when possible, not a single noisy threshold.",
    "Use seqz instead of bitwise not when flipping Boolean 0/1 values.",
    "Use ReferenceId after discovering it with batch lbn/lb when one named device must be controlled without consuming a pin.",
    "Use NaN guards for channels and missing batch ReferenceId results.",
    "If a write is optional or uncertain, branch around it with bdnvs device LogicType target."
)

$deviceProfiles = @(
    [pscustomobject]@{
        name = "Generic powered machine"
        prefab_names = @()
        common_write = @("On","Lock","Activate","Setting","Mode")
        common_read = @("Power","Error","On","Lock","RequiredPower","PrefabHash","ReferenceId","NameHash")
        codex_rule = "Do not emit all common fields blindly; verify exact support or guard store/load validity."
    },
    [pscustomobject]@{
        name = "IC Housing"
        prefab_names = @("StructureICHousing")
        write = @("Activate","Setting","On")
        read = @("Error","Activate","Setting","RequiredPower","PrefabHash","LineNumber","Power","On")
        codex_rule = "Use db Setting as a simple numeric I/O variable between IC and network; db addresses the housing when the chip is mounted there."
    },
    [pscustomobject]@{
        name = "Electrolyzer"
        write = @("Lock","On")
        read = @("Power","Error","Lock","On","RequiredPower")
        codex_rule = "Basic start/stop and lock automation."
    },
    [pscustomobject]@{
        name = "Pipe Heater"
        prefab_names = @("StructurePipeHeater")
        write = @("Lock","On")
        read = @("Error","Lock","On","Power","PrefabHash","RequiredPower")
        codex_rule = "Use with temperature hysteresis; remember physical device limits still apply."
    },
    [pscustomobject]@{
        name = "Furnace"
        write = @("Activate","ClearMemory","Lock","Mode","Open","Setting")
        read = @("Power","Error","Open","Mode","Pressure","Temperature","Reagents","ExportCount","ImportCount","PrefabHash","ReferenceId","NameHash")
        codex_rule = "Furnace control is stateful; avoid repeated Activate/Open pulses without branch conditions."
    },
    [pscustomobject]@{
        name = "Logic switch / lever / button / dial"
        write = @("Open","Lock","Activate","Setting","Mode","On")
        read = @("Open","Lock","Activate","Setting","Mode","Ratio","PrefabHash")
        codex_rule = "Switches are useful as user inputs; buttons pulse Activate; dials expose Setting and Ratio."
    },
    [pscustomobject]@{
        name = "Sensor"
        write = @()
        read = @("Activate","Quantity","Pressure","Temperature","RatioOxygen","RatioCarbonDioxide","RatioNitrogen","RatioPollutant","RatioVolatiles","RatioWater","PrefabHash","ReferenceId","NameHash")
        codex_rule = "Treat sensors as read-only unless a specific sensor Stationpedia page says otherwise."
    },
    [pscustomobject]@{
        name = "Logic Sorter"
        prefab_names = @("StructureLogicSorter")
        write = @("On","Mode","Output","ClearMemory")
        read = @("Power","On","Mode","Output","RequiredPower","ExportCount","ImportCount","PrefabHash","ReferenceId","NameHash")
        slots = @("MaxQuantity","Damage","Class","SortingClass","Quantity","PrefabHash","Occupied","OccupantHash")
        codex_rule = "For exact sorter logic modes and memory instructions, consult Stationpedia/wiki page before generating stack programs."
    },
    [pscustomobject]@{
        name = "Hydroponics / Harvie pattern"
        write = @("Plant","Harvest","On")
        read = @("PrefabHash","ReferenceId","NameHash")
        slots = @("Occupied","Mature","Seeding","Growth","Health","Efficiency","OccupantHash")
        codex_rule = "Read crop state from tray/hydroponic slots; Plant/Harvest writes are commonly batchable to Harvies."
    },
    [pscustomobject]@{
        name = "Solar tracking pattern"
        write = @("Horizontal","Vertical","On")
        read = @("Horizontal","Vertical","HorizontalRatio","VerticalRatio","SolarAngle","SolarIrradiance","Power","PowerPotential","PowerActual","PrefabHash")
        codex_rule = "Read daylight sensor orientation/activation, then sb Horizontal/Vertical to all target panel prefab hashes."
    },
    [pscustomobject]@{
        name = "Logic Transmitter"
        prefab_names = @("StructureLogicTransmitter")
        write = @("On","Setting","Mode")
        read = @("On","Setting","Mode","Power","RequiredPower","PrefabHash","ReferenceId","NameHash")
        codex_rule = "Use Setting for transmitted values when the transmitter is configured correctly in-game."
    },
    [pscustomobject]@{
        name = "Elevator"
        write = @("On","Open","Lock","ElevatorSpeed","ElevatorLevel")
        read = @("Power","Open","Error","Lock","On","RequiredPower","ElevatorSpeed","ElevatorLevel")
        codex_rule = "Use ElevatorLevel for destination commands and guard door/open state separately."
    }
)

$dataNetworkPages = @(
    "Active Vent","Advanced Composter","Advanced Furnace","AIMEe","Air Conditioner","Airlock (Structure)","Automated Hydroponics",
    "Back Pressure Regulator","Basic Chutes","Basket Hoop","Battery Charger","Battery Charger Small","Beacon","Blast Doors",
    "Circuitboard","Circuitboard (Advanced Airlock)","Circuitboard (Air Control)","Circuitboard (Airlock Control)","Circuitboard (Camera Display)","Circuitboard (Door Control)","Circuitboard (Gas Display)","Circuitboard (Graph Display)","Circuitboard (Power Control)","Circuitboard (Solar Control)","Combustion Centrifuge","Composite Door","Composite Roll Cover","Computer","Console","Control Chair","Cryo Tube",
    "Data Network Colors","Dock Port Side","Electrolyzer","Electronics Printer","Elevator","Fabricator","Filtration","Flashing Light","Furnace",
    "Gas Mask","Gas Tank Storage","Glass Door","Hardsuit","Hardsuit Helmet","Hardsuit Jetpack","Hydroponics Device","Hydroponics Station","IC Housing","IC10","Ice Crusher","Igniter",
    "Kit (Advanced Composter)","Kit (Airlock Gate)","Kit (Arc Furnace)","Kit (Atmospherics) Electrolyzer","Kit (Automated Rocket Automation)","Kit (Automated Rocket Ice Mining)","Kit (Automated Rocket Ore Mining)","Kit (Automated Rocket Salvage)","Kit (Automated Rocket Silo)","Kit (Autominer Small)","Kit (Cable Analyzer)","Kit (Centrifuge)","Kit (Grow Light)","Kit (Harvie)","Kit (Heat Exchanger)","Kit (Launch Pad)","Kit (Lights)","Kit (Liquid Pipe Analyzer)","Kit (Liquid Tank Storage)","Kit (Liquid Volume Pump)","Kit (Liquid Wall Cooler)","Kit (Modular Rocket Fueltank)","Kit (Pressure Regulator)","Kit (Rocket Gas Fuel Tank)","Kit (Rocket Liquid Fuel Tank)","Kit (Satellite Dish)","Kit (SDB Hopper)","Kit (SDB Silo)","Kit (Speaker)","Kit (Switch)","Kit (Vending Machine Refrigerated)",
    "Large Extendable Radiator","LArRE","Linear Rail Door","Liquid Digital Valve","Liquid Filtration","Liquid Fuel Tank","Logic Sorter","Logic Transmitter","Logic Uplink",
    "Organics Printer","Pipe Analyzer","Pipe Digital Valve","Pipe Gas Mixer","Pipe Heater","Pipe Heater (Liquid)","Pipe Volume Pump","Power Controller","Powered Bench","Powered Chutes","Powered Vent","Pressurant Valve","Pressure Regulator","Purge Valve",
    "Rocket Engine","Rocket Engine (Small)","Rocket Engine (Tiny)","Sensors","Solar Panel","Sorter","Stacker","Station Battery","Stellar Anchor","Stirling Engine","Tank","Turbine Generator","Turbo Volume Pump (Gas)","Upright Wind Turbine","Vending Machine","Wall Cooler","Wall Heater","Weather Station","Wind Turbine"
)
$pageIndex = foreach ($p in $dataNetworkPages) {
    $slug = [uri]::EscapeDataString($p.Replace(" ","_"))
    [pscustomobject]@{ title=$p; wiki_url="https://stationeers-wiki.com/$slug" }
}

$scriptTemplates = @(
    [pscustomobject]@{
        id = "boolean_sensor_controls_device"
        purpose = "Turn one device on/off from a Boolean sensor."
        variables = @("sensor:d0","device:d1","readLogic:Activate","writeLogic:On")
        body = @(
            "alias sensor d0",
            "alias device d1",
            "loop:",
            "yield",
            "l r0 sensor Activate",
            "s device On r0",
            "j loop"
        )
    },
    [pscustomobject]@{
        id = "hysteresis_temperature_control"
        purpose = "Avoid chatter by using low/high thresholds."
        variables = @("sensor:d0","device:d1","lowK","highK")
        body = @(
            "alias sensor d0",
            "alias device d1",
            "define lowK 293.15",
            "define highK 298.15",
            "loop:",
            "yield",
            "l r0 sensor Temperature",
            "blt r0 lowK turnOn",
            "bgt r0 highK turnOff",
            "j loop",
            "turnOn:",
            "s device On 1",
            "j loop",
            "turnOff:",
            "s device On 0",
            "j loop"
        )
    },
    [pscustomobject]@{
        id = "batch_named_reference_control"
        purpose = "Find a named device by prefab/name and control it by ReferenceId."
        variables = @("prefabHash","nameHash","logicType","value")
        body = @(
            'define TargetPrefab HASH("StructureLogicSorter")',
            'define TargetName HASH("Sorter Corn")',
            "loop:",
            "yield",
            "lbn r15 TargetPrefab TargetName ReferenceId Maximum",
            "ble r15 ninf loop",
            "s r15 Mode 1",
            "j loop"
        )
    },
    [pscustomobject]@{
        id = "network_channel_bridge"
        purpose = "Copy a value to a volatile network channel through a connection."
        variables = @("source:d0","housing:db","channel:Channel0")
        body = @(
            "alias source d0",
            "loop:",
            "yield",
            "l r0 source Temperature",
            "s db:1 Channel0 r0",
            "j loop"
        )
    }
)

$db = [pscustomobject]@{
    metadata = [pscustomobject]@{
        id = "stationeers_logic_command_database_for_codex"
        schema_version = "1.0.0"
        generated_at_local = (Get-Date).ToString("s")
        verified_date = $sourceDate
        target_consumer = "OpenAI Codex App"
        human_readability_priority = "low"
        source_summary = "Stationeers Community Wiki IC10, instruction, module, and data-network category pages verified 2026-05-06."
        source_ids = $sources.id
    }
    sources = $sources
    codex_usage_contract = [pscustomobject]@{
        purpose = "Generate Stationeers IC10/data-network scripts for controlling machines, sensors, slots, batches, ReferenceIds, and volatile network channels."
        generation_rules = $generationRules
        validation_strategy = @(
            "Use device profiles only as hints.",
            "Use Stationpedia or page-specific data for exact device fields.",
            "Emit guards for uncertain LogicType support.",
            "Prefer small scripts with aliases and comments only where needed."
        )
    }
    opcodes = $opcodes
    instructions = $instructions
    logic_types = $logicTypeObjects
    logic_slot_types = $logicSlotTypes
    constants = [pscustomobject]@{
        batch_modes = $batchModes
        reagent_modes = $reagentModes
        filter_type_bitmask_values = $filterTypeBitmask
        special_registers = @(
            [pscustomobject]@{ name="ra"; purpose="return address for jal and *al branch forms" },
            [pscustomobject]@{ name="sp"; purpose="stack pointer; changed by push/pop" }
        )
        special_numeric_tokens = @("nan","inf","ninf")
    }
    data_network = $dataNetwork
    device_profile_hints = $deviceProfiles
    data_network_page_index = $pageIndex
    script_templates = $scriptTemplates
}

$mainPath = Join-Path $target "stationeers_ic10_codex_db.json"
$manifestPath = Join-Path $target "manifest.codex.json"
$chunksPath = Join-Path $target "stationeers_ic10_codex_chunks.jsonl"

$json = $db | ConvertTo-Json -Depth 32
Set-Content -LiteralPath $mainPath -Value $json -Encoding UTF8

$manifest = [pscustomobject]@{
    database = "stationeers_ic10_codex_db.json"
    chunks = "stationeers_ic10_codex_chunks.jsonl"
    schema_version = $db.metadata.schema_version
    generated_at_local = $db.metadata.generated_at_local
    verified_date = $sourceDate
    sources = $sources
    counts = [pscustomobject]@{
        opcodes = $opcodes.Count
        instructions = $instructions.Count
        logic_types = $logicTypeObjects.Count
        logic_slot_types = $logicSlotTypes.Count
        data_network_pages = $pageIndex.Count
        device_profile_hints = $deviceProfiles.Count
        script_templates = $scriptTemplates.Count
    }
    recommended_codex_entrypoint = "Load stationeers_ic10_codex_db.json, then retrieve stationeers_ic10_codex_chunks.jsonl records by tag for prompt-local context."
}
Set-Content -LiteralPath $manifestPath -Value ($manifest | ConvertTo-Json -Depth 12) -Encoding UTF8

$chunks = @()
function Add-Chunk($id,$tags,$text,$data) {
    $script:chunks += [pscustomobject]@{
        id = $id
        tags = $tags
        text = $text
        data = $data
    }
}

Add-Chunk "ic10.network.core" @("ic10","network","device_io","l","s","db","d0") "Use l to load and s to store LogicType values on d0-d5/db, aliases, ReferenceId/register operands, or connection references. Guard uncertain devices with bdnvl/bdnvs. Use yield inside loops." $dataNetwork.device_registers
Add-Chunk "ic10.network.batch" @("ic10","batch","HASH","PrefabHash","NameHash") "Batch commands lb/lbn/lbs/lbns read groups; sb/sbn/sbs write groups. Use HASH(\"PrefabName\") and HASH(\"Label Name\"). There is no normal sbns. Batch modes are Average, Sum, Minimum, Maximum." $batchModes
Add-Chunk "ic10.network.channels" @("ic10","channels","Channel0","Channel7","NaN") "Cable networks expose volatile Channel0..Channel7 through device:connection syntax such as l r0 d0:0 Channel0 or s db:1 Channel0 r0. Values default to NaN and are lost when the cable network changes or world exits." $dataNetwork.channels
Add-Chunk "ic10.reference_id" @("ic10","ReferenceId","direct","lbn","sd","ld") "To control one named device without a pin, lbn ReferenceId with Maximum/Minimum, guard missing results, then use l/s with the ReferenceId register or legacy ld/sd if needed." $instructions | Where-Object { $_.opcode -in @("l","s","ld","sd","lbn") }
Add-Chunk "ic10.logic_types" @("ic10","LogicType","enum","dynamic") "LogicType tokens are symbolic values usable directly in l/s/lb/sb. For dynamic iteration, use LogicType.Name constants and increment through known contiguous ranges only when intended." $logicTypeObjects
Add-Chunk "ic10.slot_types" @("ic10","LogicSlotType","slots","ls","lbs","lbns") "Slot reads use ls/lbs/lbns with device-specific slot indexes. Common slot variables include Occupied, OccupantHash, Quantity, Damage, Efficiency, FilterType, Health, Growth, Charge, ChargeRatio, Class, MaxQuantity, Mature, Seeding, PrefabHash, ReferenceId." $logicSlotTypes
Add-Chunk "ic10.control_rules" @("ic10","rules","generation","codex") ($generationRules -join " ") $generationRules
Add-Chunk "ic10.templates" @("ic10","templates","examples","patterns") "Script templates cover Boolean sensor control, temperature hysteresis, named ReferenceId control, and network channel bridge." $scriptTemplates

$chunkLines = foreach ($chunk in $chunks) { $chunk | ConvertTo-Json -Depth 16 -Compress }
Set-Content -LiteralPath $chunksPath -Value $chunkLines -Encoding UTF8

[pscustomobject]@{
    Target = $target
    Main = $mainPath
    Manifest = $manifestPath
    Chunks = $chunksPath
    Opcodes = $opcodes.Count
    Instructions = $instructions.Count
    LogicTypes = $logicTypeObjects.Count
    LogicSlotTypes = $logicSlotTypes.Count
    Pages = $pageIndex.Count
} | Format-List

