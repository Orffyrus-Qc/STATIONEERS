using System;
using System.Collections.Generic;
using System.Reflection.Emit;
using System.Linq;
using System.Xml.Serialization;
using System.IO;
using System.Threading;
using HarmonyLib;
using UnityEngine;
using Assets.Scripts;
using Assets.Scripts.Atmospherics;
using Assets.Scripts.Objects;
using Assets.Scripts.Networking;
using Assets.Scripts.GridSystem;
using Assets.Scripts.Serialization;
using static Assets.Scripts.Atmospherics.Chemistry;
using TerraformingMod.Tools;
using System.Reflection;
using Assets.Scripts.Objects.Items;

namespace TerraformingMod
{
    [HarmonyPatch]
    public class AtmosphereLerpAtmospherePatch
    {
        [HarmonyTargetMethod]
        public static MethodBase TargetMethod()
        {
            return typeof(Atmosphere).GetMethod("LerpAtmosphere", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        }

        [HarmonyPrepare]
        public static bool Prepare()
        {
            return TargetMethod() != null;
        }

        [HarmonyPrefix]
        public static void Prefix(Atmosphere __instance, Atmosphere targetAtmos, ref GasMixture __state)
        {
            if (!NetworkManager.IsClient && targetAtmos.IsGlobalAtmosphere)
            {
                __state = new GasMixture(__instance.GasMixture);
                return;
            }

            __state = GasMixtureHelper.Invalid;
        }

        [HarmonyPostfix]
        public static void Postfix(Atmosphere __instance, Atmosphere targetAtmos, GasMixture __state)
        {
            if (TerraformingFunctions.ThisGlobalPrecise == null)
                return;

            if (!NetworkManager.IsClient && targetAtmos.IsGlobalAtmosphere)
            {
                var change = TerraformingFunctions.GasMixCompair(__instance.GasMixture, __state);
                TerraformingFunctions.ThisGlobalPrecise.UpdateGlobalAtmosphereChange(change);
            }
        }
    }

    [HarmonyPatch(typeof(Atmosphere), "TakeAtmospherePortion")]
    public class AtmospherTakeAtmospherePortionPatch
    {
        [HarmonyPrefix]
        public static void Prefix(Atmosphere __instance, Atmosphere atmosphere, ref GasMixture __state, GasMixture ____totalMixInWorldGasMix)
        {
            if (!NetworkManager.IsClient && atmosphere.IsGlobalAtmosphere)
            {
                __state = new GasMixture(____totalMixInWorldGasMix);
                return;
            }

            __state = GasMixtureHelper.Invalid;
        }

        [HarmonyPostfix]
        public static void Postfix(Atmosphere __instance, Atmosphere atmosphere, GasMixture __state, GasMixture ____totalMixInWorldGasMix)
        {
            if (TerraformingFunctions.ThisGlobalPrecise == null)
                return;

            if (!NetworkManager.IsClient && atmosphere.IsGlobalAtmosphere)
            {
                var change = TerraformingFunctions.GasMixCompair(____totalMixInWorldGasMix, __state);
                TerraformingFunctions.ThisGlobalPrecise.UpdateGlobalAtmosphereChange(change);
            }
        }
    }

    [HarmonyPatch(typeof(Atmosphere), "GiveAtmospheresMixInWorld")]
    public class AtmospherGiveAtmospheresMixInWorldPatch
    {
        [HarmonyPrefix]
        public static void Prefix(Atmosphere __instance, object ____mixingAtmos, float ____totalMixInWorldGiveWeight, GasMixture ____totalMixInWorldGasMix)
        {
            if (NetworkManager.IsClient || TerraformingFunctions.ThisGlobalPrecise == null)
                return;

            var atmoList = ____mixingAtmos as System.Collections.IEnumerable;
            if (atmoList == null)
                return;

            foreach (var entry in atmoList)
            {
                var traverse = Traverse.Create(entry);
                var atmo = traverse.Field("atmos").GetValue() as Atmosphere;
                float giveWeight = traverse.Field("GiveWeight").GetValue<float>();

                if (atmo != null && atmo.IsGlobalAtmosphere)
                {
                    float ratio = giveWeight / ____totalMixInWorldGiveWeight;
                    var gasMixture = new SimpleGasMixture(____totalMixInWorldGasMix);
                    gasMixture.Scale(ratio);

                    TerraformingFunctions.ThisGlobalPrecise.UpdateGlobalAtmosphereChange(gasMixture);
                }
            }
        }
    }

    [HarmonyPatch(typeof(AtmosphericsManager), "Deregister", new Type[] { typeof(Atmosphere) })]
    public class AtmosphericsControllerDeregisterPatch
    {
        [HarmonyPrefix]
        public static void Prefix(Atmosphere atmosphere)
        {
            if (!NetworkManager.IsClient && atmosphere != null && atmosphere.Mode == AtmosphereHelper.AtmosphereMode.World && atmosphere.Room == null && atmosphere.IsCloseToGlobal(new PressurekPa(AtmosphereHelper.GlobalAtmosphereNeighbourThreshold / 6f * AtmosphereHelper.NewAtmosSupressionMultiplier())))
            {
                // scale the volume up to the size of the global atmosphere, or the values will be off
                var mixture = GasMixtureHelper.Create();
                mixture.Add(atmosphere.GasMixture, AtmosphereHelper.MatterState.Gas);
                double volumeRatio = TerraformingFunctions.GlobalAtmosphere.Volume.ToDouble() / atmosphere.Volume.ToDouble();
                mixture.Scale(volumeRatio, AtmosphereHelper.MatterState.Gas);

                // check the difference to global and compensate for it
                var change = TerraformingFunctions.GasMixCompair(TerraformingFunctions.GlobalAtmosphere.GasMixture, mixture);
                TerraformingFunctions.ThisGlobalPrecise.UpdateGlobalAtmosphereChange(change);
            }
        }
    }

    [HarmonyPatch(typeof(WorldManager), "StartWorld")]
    public class WorldManagerStartWorldPatch
    {
        [HarmonyPostfix]
        public static void Postfix()
        {
            try
            {
                if (NetworkManager.IsClient) // on clients, bail out here, settings are not loaded yet.
                    return;

                TerraformingFunctions.InitialiseGlobalPrecise("server");
            }
            catch (Exception ex)
            {
                ConsoleWindow.Print("Terraforming: Failed to initialise on world start: " + ex.Message, ConsoleColor.Red);
                TerraformingMod.Log(ex.ToString());
            }
        }
    }

    [HarmonyPatch]
    public class GameManagerUpdatePatch
    {
        [HarmonyTargetMethod]
        public static MethodBase TargetMethod()
        {
            return typeof(GameManager).GetMethod("Update", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        }

        [HarmonyPrepare]
        public static bool Prepare()
        {
            return TargetMethod() != null;
        }

        [HarmonyPostfix]
        public static void Postfix()
        {
            try
            {
                TerraformingTestHarness.TickCurrentGlobal();
            }
            catch (Exception ex)
            {
                TerraformingMod.Log("GameManager test harness tick failed: " + ex);
            }
        }
    }

    public static class TerraformingInitialisation
    {
        public static void LoadSavedAtmosphereIfAvailable()
        {
            if (XmlSaveLoad.Instance?.CurrentWorldSave != null)
            {
                var fileName = TerraformingSaveFile.GetCurrentSaveFileName();

                ConsoleWindow.Print("Terraforming: Loading from: " + fileName, ConsoleColor.Yellow);
                object obj = XmlSerialization.Deserialize(TerraformingFunctions.AtmoSerializer, fileName);
                if (!(obj is TerraformingAtmosphere terraformingAtmosphere))
                {
                    ConsoleWindow.Print("Terraforming: Failed to load the terraforming_atmosphere.xml: " + fileName, ConsoleColor.Red);
                }
                else
                {
                    if (terraformingAtmosphere.GasMix != null)
                        TerraformingFunctions.ThisGlobalPrecise.OnLoadMix = terraformingAtmosphere.GasMix.Apply();
                    else
                        ConsoleWindow.Print("Terraforming: No stored GasMix found");
                }
            }
        }
    }

    [HarmonyPatch(typeof(NetworkClient), "ProcessJoinData")]
    public class NetworkClientProcessJoinDataPatch
    {
        [HarmonyPostfix]
        public static void Postfix()
        {
            try
            {
                if (!NetworkManager.IsClient) // on server, this should not fire
                    return;

                TerraformingFunctions.InitialiseGlobalPrecise("client");
            }
            catch (Exception ex)
            {
                ConsoleWindow.Print("Terraforming: Failed to initialise on join: " + ex.Message, ConsoleColor.Red);
                TerraformingMod.Log(ex.ToString());
            }
        }
    }

    [HarmonyPatch(typeof(AtmosphereHelper), "IsValidForNetworkSend")]
    public class AtmosphereHelperIsValidForNetworkSendPatch
    {
        [HarmonyPrefix]
        public static bool Prefix(Atmosphere atmos, ref bool __result)
        {
            if (atmos != null && !atmos.BeingDestroyed && !atmos.IsNaN() && atmos == TerraformingFunctions.GlobalAtmosphere)
            {
                // only send the global atmosphere if the gas quantities changed, or a join is in progress
                __result = (atmos.GasMixture.GasQuantitiesDirtied() != 0) || TerraformingFunctions.JoinInProgress;
                return false;
            }

            return true;
        }
    }


    [HarmonyPatch(typeof(AtmosphericsManager), "SerialiseOnJoin")]
    public class AtmosphericsManagerSerialiseOnJoin
    {
        [HarmonyPrefix]
        public static void Prefix()
        {
            TerraformingFunctions.JoinInProgress = true;
        }

        [HarmonyPostfix]
        public static void Postfix()
        {
            TerraformingFunctions.JoinInProgress = false;
        }
    }

    [HarmonyPatch(typeof(AtmosphereHelper), "ReadStatic")]
    public class AtmosphereHelperReadStaticPatch
    {
        [HarmonyTranspiler]
        public static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> instructions, ILGenerator il)
        {
            var codes = instructions.ToList();

            // hash to ensure the function didnt change and we might do bad things
            if (codes.HashInstructionsHex() != "cbeeb1b5")
            {
                ConsoleWindow.Print($"TerraformingMod: Code change detected ({codes.HashInstructionsHex()}), AtmosphereHelper ReadStatic patch disabled", ConsoleColor.Red);
                return codes.AsEnumerable();
            }

            System.Reflection.Emit.Label skipGlobalLabel = il.DefineLabel();

            // the end of the function should look like this, which we're adapting:
            /*
	            IL_0145: ldloc.3
	            IL_0146: ldarg.0
	            IL_0147: ldloc.1
	            IL_0148: callvirt instance void Assets.Scripts.Atmospherics.Atmosphere::Read(class Assets.Scripts.Networking.RocketBinaryReader, uint8)
	            IL_014d: ret

                Local index 1 = Network Flags ("b")
                Local index 2 = Atmosphere Mode
                Local index 3 = Atmosphere
            */

            // insert a branch before the call to the Read function
            int Index = codes.Count - 5;
            codes[Index].labels.Add(skipGlobalLabel); // store a skip label at the old instruction

            // Add a branch before the reading of the atmosphere, which will set the current GasMix to the atmosphere
            // this ensures we can detect any changes to the atmosphere properly
            codes.Insert(Index++, new CodeInstruction(OpCodes.Ldloc, 2)); // load atmosphereMode
            codes.Insert(Index++, new CodeInstruction(OpCodes.Ldc_I4, 3)); // load Mode=Global
            codes.Insert(Index++, new CodeInstruction(OpCodes.Bne_Un_S, skipGlobalLabel)); // skip branch if not equal

            codes.Insert(Index++, new CodeInstruction(OpCodes.Ldloc, 3)); // load Atmosphere
            codes.Insert(Index++, new CodeInstruction(OpCodes.Ldloc, 1)); // load network flags ("b")
            codes.Insert(Index++, CodeInstruction.Call(typeof(AtmosphereHelperReadStaticPatch), "PrepareReadingGlobalAtmosphere"));

            // jump to last instruction
            // at the end of the function, take the now updated Atmosphere, and update the GlobalAtmosphere with its values
            Index = codes.Count - 1;
            codes.Insert(Index++, new CodeInstruction(OpCodes.Ldloc, 3)); // load Atmosphere
            codes.Insert(Index++, new CodeInstruction(OpCodes.Ldloc, 1)); // load network flags ("b")
            codes.Insert(Index++, CodeInstruction.Call(typeof(AtmosphereHelperReadStaticPatch), "ProcessGlobalAtmosphere"));

            return codes.AsEnumerable();
        }

        public static void PrepareReadingGlobalAtmosphere(Atmosphere atmosphere, byte networkUpdateFlags)
        {
            if (atmosphere != null && atmosphere.Mode == AtmosphereHelper.AtmosphereMode.Global)
            {
                if (AtmosphereHelper.IsNetworkUpdateRequired(64, networkUpdateFlags))
                {
                    atmosphere.GasMixture.Set(TerraformingFunctions.CreateGasOnlyMixture(TerraformingFunctions.GlobalAtmosphere.GasMixture), AtmosphereHelper.MatterState.All);
                }
            }
        }

        public static void ProcessGlobalAtmosphere(Atmosphere atmosphere, byte networkUpdateFlags)
        {
            if (atmosphere != null && atmosphere.Mode == AtmosphereHelper.AtmosphereMode.Global)
            {
                if (AtmosphereHelper.IsNetworkUpdateRequired(64, networkUpdateFlags))
                {
                    // ConsoleWindow.Print("Updating global atmosphere GasMixture");
                    var globalAtmosphere = TerraformingFunctions.GlobalAtmosphere;
                    globalAtmosphere.GasMixture.SetReadOnly(false);
                    globalAtmosphere.GasMixture.Set(TerraformingFunctions.CreateGasOnlyMixture(atmosphere.GasMixture), AtmosphereHelper.MatterState.All);
                    globalAtmosphere.GasMixture.SetReadOnly(true);
                    globalAtmosphere.GasMixture.UpdateCache();
                }
            }
        }
    }
    [HarmonyPatch(typeof(SaveHelper), "Save", new Type[] { typeof(DirectoryInfo), typeof(string), typeof(bool), typeof(CancellationToken) })]
    public class SaveHelperSavePatch
    {
        [HarmonyPostfix]
        public static void Postfix(DirectoryInfo saveDirectory)
        {
            if (TerraformingFunctions.ThisGlobalPrecise != null && saveDirectory != null)
            {
                var tempFileName = TerraformingSaveFile.GetFullTempFileName(saveDirectory.FullName);

                // write out the global atmosphere
                var saveAtmosphere = new TerraformingAtmosphere();
                saveAtmosphere.GasMix = new GasMixSaveData(TerraformingFunctions.GlobalAtmosphere.GasMixture);
                if (!XmlSerialization.Serialization(TerraformingFunctions.AtmoSerializer, saveAtmosphere, tempFileName))
                {
                    ConsoleWindow.Print("Error Saving Terraforming Atmosphere: " + tempFileName, ConsoleColor.Red);
                    return;
                }
                // move file into the right place
                var realFileName = TerraformingSaveFile.GetFullSaveFileName(saveDirectory.FullName);
                try
                {
                    if (File.Exists(realFileName))
                    {
                        File.Delete(realFileName);
                    }
                    File.Move(tempFileName, realFileName);
                }
                catch (Exception ex)
                {
                    ConsoleWindow.Print("Error Renaming Temporary Save Files: " + ex.Message, ConsoleColor.Red);
                    return;
                }
                ConsoleWindow.Print("Exported Terraforming Atmosphere");
            }
        }
    }

    [HarmonyPatch(typeof(PlanetaryAtmosphereSimulation), "TickPlanetarySimulation")]
    public class PlanetaryAtmosphereSimulationTickPatch
    {
        [HarmonyPostfix]
        public static void Postfix()
        {
            if (TerraformingFunctions.ThisGlobalPrecise != null)
            {
                TerraformingFunctions.ReloadGlobalAtmosphere();
                var globalAtmosphere = TerraformingFunctions.GlobalAtmosphere;
                if (globalAtmosphere == null)
                    return;

                TerraformingTestHarness.Tick(globalAtmosphere);

                float temp;
                if (!TerraformingTestHarness.TryGetForcedTemperature(out temp))
                    temp = TerraformingFunctions.GetTemperature(OrbitalSimulation.TimeOfDay, globalAtmosphere.GasMixture);
                TerraformingFunctions.ThisGlobalPrecise.UpdateGlobalAtmosphere(temp, globalAtmosphere);
            }
        }
    }

    public class TerraformingFunctions
    {

        public static GlobalAtmospherePrecise ThisGlobalPrecise;

        [ThreadStatic]
        public static bool JoinInProgress = false;

        public static Atmosphere GlobalAtmosphere;

        public static void InitialiseGlobalPrecise(string side)
        {
            if (WorldSetting.Current == null)
            {
                ConsoleWindow.Print("Terraforming: WorldSetting.Current is not ready; initialisation skipped", ConsoleColor.Yellow);
                return;
            }

            LightManager.SunPathTraceWorldAtmos = true;
            ThisGlobalPrecise = new GlobalAtmospherePrecise(Mathf.Abs(WorldSetting.Current.Gravity));
            ThisGlobalPrecise.OnLoadMix = CreateWorldGlobalGasMixture();

            if (!NetworkManager.IsClient)
            {
                try
                {
                    TerraformingInitialisation.LoadSavedAtmosphereIfAvailable();
                }
                catch (Exception ex)
                {
                    ConsoleWindow.Print("Terraforming: Failed to load saved atmosphere, using world defaults: " + ex.Message, ConsoleColor.Yellow);
                    TerraformingMod.Log(ex.ToString());
                }
            }

            ReloadGlobalAtmosphere();
            var globalAtmo = GlobalAtmosphere;
            if (globalAtmo != null && AtmosphericsManager.AllAtmospheres != null)
                AtmosphericsManager.AllAtmospheres.Add(globalAtmo);
            else
                ConsoleWindow.Print("Terraforming: Global Atmosphere is not valid or atmospheres list is not ready", ConsoleColor.Yellow);

            RecalculateSolarIrradiance();
            ConsoleWindow.Print($"Terraforming: GlobalPrecise generated (Terraforming mod loaded on {side})");
        }

        private static void RecalculateSolarIrradiance()
        {
            if (OrbitalSimulation.System == null)
                return;

            var calculateSolarIrradiance = typeof(OrbitalSimulation).GetMethod("CalculateSolarIrradiance", BindingFlags.NonPublic | BindingFlags.Instance, null, new Type[0], null);
            if (calculateSolarIrradiance == null)
                return;

            var value = calculateSolarIrradiance.Invoke(OrbitalSimulation.System, null);
            Traverse.Create(typeof(OrbitalSimulation)).Property("SolarIrradiance").SetValue(value);
        }

        public static void ReloadGlobalAtmosphere()
        {
            GlobalAtmosphere = PlanetaryAtmosphereSimulation.ReadOnlyGlobal(new WorldGrid(new Grid3(0)));
        }

        public static GasMixture CreateWorldGlobalGasMixture()
        {
            var readOnlyGlobal = PlanetaryAtmosphereSimulation.ReadOnlyGlobal(new WorldGrid(new Grid3(0)));
            if (readOnlyGlobal != null)
                return CreateGasOnlyMixture(readOnlyGlobal.GasMixture);

            var data = WorldSetting.Current?.Data?.GlobalAtmosphereData;
            if (data != null)
                return CreateScaledWorldGasMixture(GlobalGasMix.Create(data));

            return GasMixtureHelper.Create();
        }

        private static GasMixture CreateScaledWorldGasMixture(GlobalGasMix globalMix)
        {
            var gasMixture = globalMix.ToInstancedGasMixture();
            double gasVolume = globalMix.VolumeForGas().ToDouble();
            if (gasVolume > double.Epsilon)
            {
                double scale = Chemistry.GridVolume.ToDouble() / gasVolume;
                gasMixture.Scale(scale, AtmosphereHelper.MatterState.Gas);
            }

            return CreateGasOnlyMixture(gasMixture);
        }

        public static GasMixture CreateGasOnlyMixture(GasMixture source)
        {
            var gasMixture = GasMixtureHelper.Create();
            gasMixture.Set(source, AtmosphereHelper.MatterState.Gas);

            gasMixture.UpdateCache(DirtyMoleTolerance.Precision);
            return gasMixture;
        }

        public static float GetTemperature(float timeOfDay, GasMixture gasMix)
        {
            double rootIrridiance = Math.Sqrt(OrbitalSimulation.SolarIrradiance);

            float temperatureBase = ThisGlobalPrecise.GetWorldBaseTemperature(rootIrridiance, gasMix);
            float temperatureDelta = ThisGlobalPrecise.GetWorldDeltaTemperature(temperatureBase, rootIrridiance, gasMix);
            float temp = temperatureBase + Mathf.Sin(timeOfDay * 2f * Mathf.PI - Mathf.PI / 4) * temperatureDelta / 2;
            return temp;
        }
        public static List<SpawnGas> UpdateWorldSetting(GasMixture globalGasMixture)
        {
            List<SpawnGas> currentSpawnGas = new List<SpawnGas>();
            foreach (GasType type in GlobalAtmospherePrecise.gasTypes)
            {
                currentSpawnGas.Add(new SpawnGas(type, globalGasMixture.GetMoleValue(type).Quantity.ToFloat(), globalGasMixture.Temperature));
            }
            return currentSpawnGas;
        }
        public static SimpleGasMixture GasMixCompair(GasMixture original1, GasMixture original2)
        {
            SimpleGasMixture result = new SimpleGasMixture();
            foreach (GasType type in GlobalAtmospherePrecise.gasTypes)
            {
                double num = original2.GetMoleValue(type).Quantity.ToDouble() - original1.GetMoleValue(type).Quantity.ToDouble();
                result.SetType(type, num);
            }

            return result;
        }
        private static XmlSerializer _atmoSerializer = null;
        public static XmlSerializer AtmoSerializer
        {
            get
            {
                if (_atmoSerializer != null)
                {
                    return _atmoSerializer;
                }

                _atmoSerializer = new XmlSerializer(typeof(TerraformingAtmosphere), XmlSaveLoad.ExtraTypes);
                return _atmoSerializer;
            }
        }
    }
    public class SimpleGasMixture
    {
        private readonly Dictionary<GasType, double> _additionalGases = new Dictionary<GasType, double>();

        public SimpleGasMixture() {}
        public SimpleGasMixture(GasMixture gasMixture)
        {
            foreach (GasType type in GlobalAtmospherePrecise.gasTypes)
            {
                SetType(type, gasMixture.GetMoleValue(type).Quantity.ToDouble());
            }
        }

        public double Pollutant { get; set; }
        public double LiquidPollutant { get; set; }
        public double CarbonDioxide { get; set; }
        public double LiquidCarbonDioxide { get; set; }
        public double Oxygen { get; set; }
        public double LiquidOxygen { get; set; }
        public double Volatiles { get; set; }
        public double LiquidVolatiles { get; set; }
        public double Nitrogen { get; set; }
        public double LiquidNitrogen { get; set; }
        public double NitrousOxide { get; set; }
        public double LiquidNitrousOxide { get; set; }
        public double Water { get; set; }
        public double Steam { get; set; }
        public double PollutedWater { get; set; }

        public void Reset()
        {
            Pollutant = 0;
            LiquidPollutant = 0;
            CarbonDioxide = 0;
            LiquidCarbonDioxide = 0;
            Oxygen = 0;
            LiquidOxygen = 0;
            Volatiles = 0;
            LiquidVolatiles = 0;
            Nitrogen = 0;
            LiquidNitrogen = 0;
            NitrousOxide = 0;
            LiquidNitrousOxide = 0;
            Water = 0;
            Steam = 0;
            PollutedWater = 0;
            _additionalGases.Clear();
        }

        public void Scale(double scale)
        {
            Pollutant *= scale;
            LiquidPollutant *= scale;
            CarbonDioxide *= scale;
            LiquidCarbonDioxide *= scale;
            Oxygen *= scale;
            LiquidOxygen *= scale;
            Volatiles *= scale;
            LiquidVolatiles *= scale;
            Nitrogen *= scale;
            LiquidNitrogen *= scale;
            NitrousOxide *= scale;
            LiquidNitrousOxide *= scale;
            Water *= scale;
            Steam *= scale;
            PollutedWater *= scale;
            foreach (var key in _additionalGases.Keys.ToList())
            {
                _additionalGases[key] *= scale;
            }
        }

        public double Add(SimpleGasMixture gasMix)
        {
            double AddedMoles = 0;
            foreach (GasType type in GlobalAtmospherePrecise.gasTypes)
            {
                var add = gasMix.GetType(type);
                SetType(type, GetType(type) + add);
                AddedMoles += add;
            }

            return AddedMoles;
        }

        public void SetType(GasType gasType, double quantity)
        {
            switch (gasType)
            {
                case GasType.Undefined:
                    break;
                case GasType.Oxygen:
                    Oxygen = quantity;
                    break;
                case GasType.Nitrogen:
                    Nitrogen = quantity;
                    break;
                case GasType.CarbonDioxide:
                    CarbonDioxide = quantity;
                    break;
                case GasType.Methane:
                    Volatiles = quantity;
                    break;
                case GasType.Pollutant:
                    Pollutant = quantity;
                    break;
                case GasType.Water:
                    Water = quantity;
                    break;
                case GasType.NitrousOxide:
                    NitrousOxide = quantity;
                    break;
                case GasType.LiquidOxygen:
                    LiquidOxygen = quantity;
                    break;
                case GasType.LiquidNitrogen:
                    LiquidNitrogen = quantity;
                    break;
                case GasType.LiquidCarbonDioxide:
                    LiquidCarbonDioxide = quantity;
                    break;
                case GasType.LiquidMethane:
                    LiquidVolatiles = quantity;
                    break;
                case GasType.LiquidPollutant:
                    LiquidPollutant = quantity;
                    break;
                case GasType.Steam:
                    Steam = quantity;
                    break;
                case GasType.LiquidNitrousOxide:
                    LiquidNitrousOxide = quantity;
                    break;
                case GasType.PollutedWater:
                    PollutedWater = quantity;
                    break;
                default:
                    _additionalGases[gasType] = quantity;
                    break;
            }
        }

        public double GetType(GasType gasType)
        {
            switch (gasType)
            {
                case GasType.Undefined:
                    break;
                case GasType.Oxygen:
                    return Oxygen;
                case GasType.Nitrogen:
                    return Nitrogen;
                case GasType.CarbonDioxide:
                    return CarbonDioxide;
                case GasType.Methane:
                    return Volatiles;
                case GasType.Pollutant:
                    return Pollutant;
                case GasType.Water:
                    return Water;
                case GasType.NitrousOxide:
                    return NitrousOxide;
                case GasType.LiquidOxygen:
                    return LiquidOxygen;
                case GasType.LiquidNitrogen:
                    return LiquidNitrogen;
                case GasType.LiquidCarbonDioxide:
                    return LiquidCarbonDioxide;
                case GasType.LiquidMethane:
                    return LiquidVolatiles;
                case GasType.LiquidPollutant:
                    return LiquidPollutant;
                case GasType.Steam:
                    return Steam;
                case GasType.LiquidNitrousOxide:
                    return LiquidNitrousOxide;
                case GasType.PollutedWater:
                    return PollutedWater;
                default:
                    if (_additionalGases.TryGetValue(gasType, out double value))
                        return value;
                    break;
            }

            return 0.0;
        }
    }
    public class GlobalAtmospherePrecise : SimpleGasMixture
    {

        public static GasType[] gasTypes = new GasType[]
        {
            GasType.Pollutant, 
            GasType.CarbonDioxide,
            GasType.Oxygen,
            GasType.Methane,
            GasType.Nitrogen, 
            GasType.NitrousOxide, 
            GasType.Steam, 
            GasType.Hydrogen,
            GasType.Hydrazine,
            GasType.Helium,
            GasType.Silanol,
            GasType.HydrochloricAcid,
            GasType.Ozone
        };
        public static double worldSize;
        public static double[] baseFactors = new double[]
        {
            10.651413866149,
            1.00348304229291,
            0.202490458429832,
            8.55023708508486,
            -0.320563285816776,
            -1.288345881,
            -3.14159265359, //steam
            0,
            0,
            0,
            0,
            0,
            0
        };
        public static double[] deltaFactors = new double[]
        {
            1.03921006683661,
            -0.014557418735896,
            -0.0250754001733472,
            19.5280403386664,
            0.314249023692835,
            -0.987064019,
            -1.14159265359, //steam
            0,
            0,
            0,
            0,
            0,
            0
        };
        public static double baseSolarScale = 8.99241762372131;
        public static double deltaSolarScale = 3.21847718465672;
        public static double baseTQ = -0.0128394753903387;
        public static double deltaTQ = 0.0948443729002513;
        public static double deltaPa = -0.000838897191503017;
        public static double pressureGravityFactorInPa = 180 * 1000f;

        public GlobalAtmospherePrecise(float gravity)
        {
            worldSize = 7 * Math.Pow(10, 6);
            worldScale = 1 / worldSize;
            this.gravity = Mathf.Abs(gravity);
            rootGravity = Mathf.Sqrt(this.gravity);
        }

        private GasMixture _OnLoadMix;
        public GasMixture OnLoadMix
        {
            get { return _OnLoadMix; }
            set { _OnLoadMix = value; }
        }

        private float gravity;
        public float rootGravity;
        public double worldScale;

        private SimpleGasMixture GasMixAccumulater = new SimpleGasMixture();
        private double GasMixAccumulatorMoles = 0;

        public void UpdateGlobalAtmosphereChange(SimpleGasMixture change)
        {
            lock (this)
            {
                double testMultiplier = TerraformingTestHarness.GetChangeMultiplier();
                if (Math.Abs(testMultiplier - 1.0) > double.Epsilon)
                    change.Scale(testMultiplier);

                // add to accumulator, and only update the global atmosphere if there is a significant change
                GasMixAccumulatorMoles += GasMixAccumulater.Add(change);
                if (Math.Abs(GasMixAccumulatorMoles) <= 1)
                    return;

                // re-scale for world scale
                GasMixAccumulater.Scale(worldScale);

                // add to this mix
                Add(GasMixAccumulater);

                // reset
                GasMixAccumulater.Reset();
                GasMixAccumulatorMoles = 0;
            }
        }
        public void UpdateGlobalAtmosphere(float temp, Atmosphere GlobalAtmosphere)
        {
            var gasMixture = GlobalAtmosphere.GasMixture;
            gasMixture.SetReadOnly(false);
            if (!NetworkManager.IsClient) // clients only update temperature, servers controls atmosphere
            {
                gasMixture.Set(OnLoadMix, AtmosphereHelper.MatterState.All);
                foreach (GasType type in gasTypes)
                {
                    AddQuantity(ref gasMixture, type, GetType(type));
                }
            }
            if (!float.IsNaN(temp))
            {
                gasMixture.TotalEnergy = new MoleEnergy(gasMixture.HeatCapacity, new TemperatureKelvin(temp));
            }
            float gasPressureInPa = GlobalAtmosphere.PressureGasses.ToFloat() * 1000f;
            if (!NetworkManager.IsClient && gasPressureInPa > rootGravity * pressureGravityFactorInPa)
            {
                float num1 = (float)(rootGravity * pressureGravityFactorInPa / gasPressureInPa);
                _OnLoadMix.Scale(num1, AtmosphereHelper.MatterState.Gas);
                Scale(num1);
            }
            gasMixture.SetReadOnly(true);
            GlobalAtmosphere.GasMixture = gasMixture;
            GlobalAtmosphere.UpdateCache();
        }

        private static void AddQuantity(ref GasMixture gasMixture, GasType gasType, double quantity)
        {
            if (Math.Abs(quantity) <= double.Epsilon)
                return;

            var mole = gasMixture.GetMoleValue(gasType);
            double newQuantity = Math.Max(0, mole.Quantity.ToDouble() + quantity);
            gasMixture.SetMoleValue(gasType, new MoleQuantity(newQuantity), mole.Energy);
        }

        public float GetWorldBaseTemperature(double rootIrridiance, GasMixture globalMix)
        {
            double temperature = 0;
            temperature += baseSolarScale * rootIrridiance;
            for (int i = 0; i < gasTypes.Length; i++)
            {
                if (baseFactors[i] != 0)
                {
                    temperature += baseFactors[i] * Math.Sqrt(globalMix.GetGasTypeRatio(gasTypes[i])) * globalMix.GetMoleValue(gasTypes[i]).Quantity.ToDouble();
                }
            }
            temperature += baseTQ * globalMix.GetTotalMolesGasses.ToDouble();

            return (float)Math.Max(temperature, 0);
        }
        public float GetWorldDeltaTemperature(float baseTemp, double rootIrridiance, GasMixture globalMix)
        {
            double temperature = 0;
            temperature += deltaSolarScale * rootIrridiance;
            for (int i = 0; i < gasTypes.Length; i++)
            {
                if (deltaFactors[i] != 0)
                {
                    temperature += deltaFactors[i] * Math.Sqrt(globalMix.GetGasTypeRatio(gasTypes[i])) * globalMix.GetMoleValue(gasTypes[i]).Quantity.ToDouble();
                }
            }
            temperature += deltaTQ * globalMix.GetTotalMolesGasses.ToDouble();
            temperature += deltaPa * globalMix.GetTotalMolesGasses.ToDouble() * baseTemp;

            return (float)Math.Max(temperature, 0);
        }
    }
}
