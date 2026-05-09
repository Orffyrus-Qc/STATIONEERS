using HarmonyLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BepInEx.Configuration;
using UnityEngine;

namespace TerraformingMod
{
    #region BepInEx
    [BepInEx.BepInPlugin(pluginGuid, pluginName, pluginVersion)]
    public class TerraformingMod : BepInEx.BaseUnityPlugin
    {
        public const string pluginGuid = "net.elmo.stationeers.Terraforming";
        public const string pluginName = "Terraforming Mod";
        public const string pluginVersion = "0.24.9";

        internal static ConfigEntry<bool> EnableTestCommands;
        internal static ConfigEntry<double> TestChangeMultiplier;
        internal static ConfigEntry<float> TestCommandPollSeconds;
        internal static ConfigEntry<float> TestStatusPollSeconds;

        public static void Log(string line)
        {
            Debug.Log("[" + pluginName + "]: " + line);
        }
        void Awake()
        {
            try
            {
                EnableTestCommands = Config.Bind("Testing", "EnableTestCommands", false, "Enables server-only file-driven terraforming test commands.");
                TestChangeMultiplier = Config.Bind("Testing", "ChangeMultiplier", 1.0, "Multiplies terraforming atmosphere changes while test commands are enabled.");
                TestCommandPollSeconds = Config.Bind("Testing", "CommandPollSeconds", 2f, "Seconds between checks for TerraformingMod.TestCommands.txt.");
                TestStatusPollSeconds = Config.Bind("Testing", "StatusPollSeconds", 10f, "Seconds between automatic writes to TerraformingMod.TestStatus.txt.");
                TerraformingTestHarness.Configure(EnableTestCommands, TestChangeMultiplier, TestCommandPollSeconds, TestStatusPollSeconds);

                var harmony = new Harmony(pluginGuid);
                harmony.PatchAll();
                Log("Patch succeeded");
            }
            catch (Exception e)
            {
                Log("Patch Failed");
                Log(e.ToString());
            }
        }

        void Update()
        {
            try
            {
                TerraformingTestHarness.TickCurrentGlobal();
            }
            catch (Exception e)
            {
                Log("Test harness update failed");
                Log(e.ToString());
            }
        }
    }
    #endregion
}
