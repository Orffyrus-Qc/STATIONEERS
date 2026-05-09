using System;
using System.Globalization;
using System.IO;
using System.Text;
using BepInEx;
using BepInEx.Configuration;
using Assets.Scripts;
using Assets.Scripts.Atmospherics;
using Assets.Scripts.Networking;
using static Assets.Scripts.Atmospherics.Chemistry;

namespace TerraformingMod
{
    public static class TerraformingTestHarness
    {
        private static ConfigEntry<bool> _enabled;
        private static ConfigEntry<double> _changeMultiplier;
        private static ConfigEntry<float> _commandPollSeconds;
        private static ConfigEntry<float> _statusPollSeconds;

        private static DateTime _nextCommandPollUtc = DateTime.MinValue;
        private static DateTime _nextStatusWriteUtc = DateTime.MinValue;
        private static double _runtimeChangeMultiplier = double.NaN;
        private static float? _forcedTemperatureKelvin;
        private static string _lastResult = "No test commands processed yet.";

        public static void Configure(ConfigEntry<bool> enabled, ConfigEntry<double> changeMultiplier, ConfigEntry<float> commandPollSeconds, ConfigEntry<float> statusPollSeconds)
        {
            _enabled = enabled;
            _changeMultiplier = changeMultiplier;
            _commandPollSeconds = commandPollSeconds;
            _statusPollSeconds = statusPollSeconds;
        }

        public static double GetChangeMultiplier()
        {
            if (!IsEnabled())
                return 1.0;

            if (!double.IsNaN(_runtimeChangeMultiplier))
                return Math.Max(0.0, _runtimeChangeMultiplier);

            return _changeMultiplier == null ? 1.0 : Math.Max(0.0, _changeMultiplier.Value);
        }

        public static bool TryGetForcedTemperature(out float kelvin)
        {
            if (IsEnabled() && _forcedTemperatureKelvin.HasValue)
            {
                kelvin = _forcedTemperatureKelvin.Value;
                return true;
            }

            kelvin = 0;
            return false;
        }

        public static void Tick(Atmosphere globalAtmosphere)
        {
            if (!IsEnabled() || NetworkManager.IsClient || TerraformingFunctions.ThisGlobalPrecise == null || globalAtmosphere == null)
                return;

            EnsureExampleFile();

            var now = DateTime.UtcNow;
            if (now >= _nextCommandPollUtc)
            {
                _nextCommandPollUtc = now.AddSeconds(Math.Max(0.25f, _commandPollSeconds == null ? 2f : _commandPollSeconds.Value));
                ProcessCommandFile(globalAtmosphere);
            }

            if (now >= _nextStatusWriteUtc)
            {
                _nextStatusWriteUtc = now.AddSeconds(Math.Max(1f, _statusPollSeconds == null ? 10f : _statusPollSeconds.Value));
                WriteStatus(globalAtmosphere, _lastResult);
            }
        }

        public static void TickCurrentGlobal()
        {
            if (!IsEnabled() || NetworkManager.IsClient || TerraformingFunctions.ThisGlobalPrecise == null)
                return;

            var globalAtmosphere = TerraformingFunctions.GlobalAtmosphere;
            if (globalAtmosphere == null)
            {
                TerraformingFunctions.ReloadGlobalAtmosphere();
                globalAtmosphere = TerraformingFunctions.GlobalAtmosphere;
            }

            Tick(globalAtmosphere);
        }

        private static bool IsEnabled()
        {
            return _enabled != null && _enabled.Value;
        }

        private static string CommandFilePath
        {
            get { return Path.Combine(Paths.ConfigPath, "TerraformingMod.TestCommands.txt"); }
        }

        private static string LastCommandFilePath
        {
            get { return Path.Combine(Paths.ConfigPath, "TerraformingMod.TestCommands.last.txt"); }
        }

        private static string ExampleFilePath
        {
            get { return Path.Combine(Paths.ConfigPath, "TerraformingMod.TestCommands.example.txt"); }
        }

        private static string StatusFilePath
        {
            get { return Path.Combine(Paths.ConfigPath, "TerraformingMod.TestStatus.txt"); }
        }

        private static void ProcessCommandFile(Atmosphere globalAtmosphere)
        {
            if (!File.Exists(CommandFilePath))
                return;

            string[] lines;
            try
            {
                if (File.Exists(LastCommandFilePath))
                    File.Delete(LastCommandFilePath);

                File.Move(CommandFilePath, LastCommandFilePath);
                lines = File.ReadAllLines(LastCommandFilePath);
            }
            catch (IOException)
            {
                return;
            }
            catch (UnauthorizedAccessException)
            {
                return;
            }

            var result = new StringBuilder();
            foreach (var rawLine in lines)
            {
                var line = StripComment(rawLine).Trim();
                if (string.IsNullOrWhiteSpace(line))
                    continue;

                try
                {
                    result.AppendLine("> " + line);
                    result.AppendLine(ExecuteCommand(line, globalAtmosphere));
                }
                catch (Exception ex)
                {
                    result.AppendLine("ERROR: " + ex.Message);
                    TerraformingMod.Log("Test command failed: " + line + Environment.NewLine + ex);
                }
            }

            _lastResult = result.Length == 0 ? "Command file contained no executable commands." : result.ToString().TrimEnd();
            ApplyCurrentState(globalAtmosphere);
            WriteStatus(globalAtmosphere, _lastResult);
        }

        private static string ExecuteCommand(string line, Atmosphere globalAtmosphere)
        {
            var parts = line.Split(new[] { ' ', '\t', ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0)
                return "Ignored empty command.";

            string verb = parts[0].ToLowerInvariant();
            switch (verb)
            {
                case "help":
                    return HelpText();
                case "status":
                    ApplyCurrentState(globalAtmosphere);
                    WriteStatus(globalAtmosphere, "Manual status command.");
                    return "Wrote status.";
                case "add":
                    Require(parts.Length >= 3, "Usage: add <gas> <moles>");
                    return AddGas(parts[1], ParseDouble(parts[2]));
                case "set":
                    Require(parts.Length >= 3, "Usage: set <gas> <moles>");
                    return SetGas(parts[1], ParseDouble(parts[2]));
                case "clear":
                case "vacuum":
                    ClearAllGases();
                    return "Set all tracked global gases to zero.";
                case "reset":
                    TerraformingFunctions.ThisGlobalPrecise.Reset();
                    _forcedTemperatureKelvin = null;
                    _runtimeChangeMultiplier = double.NaN;
                    return "Reset test deltas, forced temperature, and runtime multiplier.";
                case "temp":
                case "temperature":
                    Require(parts.Length >= 2, "Usage: temp <kelvin|off>");
                    return SetTemperature(parts[1]);
                case "multiplier":
                case "speed":
                    Require(parts.Length >= 2, "Usage: multiplier <number|reset>");
                    return SetMultiplier(parts[1]);
                case "preset":
                    Require(parts.Length >= 2, "Usage: preset <mars|breathable|highpressure|co2>");
                    return ApplyPreset(parts[1]);
                default:
                    throw new InvalidOperationException("Unknown command '" + parts[0] + "'. Use 'help'.");
            }
        }

        private static void ApplyCurrentState(Atmosphere globalAtmosphere)
        {
            if (globalAtmosphere == null || TerraformingFunctions.ThisGlobalPrecise == null)
                return;

            float temp;
            if (!TryGetForcedTemperature(out temp))
                temp = TerraformingFunctions.GetTemperature(OrbitalSimulation.TimeOfDay, globalAtmosphere.GasMixture);

            TerraformingFunctions.ThisGlobalPrecise.UpdateGlobalAtmosphere(temp, globalAtmosphere);
        }

        private static string AddGas(string gasName, double moles)
        {
            GasType gasType = ParseGasType(gasName);
            double currentDelta = TerraformingFunctions.ThisGlobalPrecise.GetType(gasType);
            TerraformingFunctions.ThisGlobalPrecise.SetType(gasType, currentDelta + moles);
            return "Added " + moles.ToString("G", CultureInfo.InvariantCulture) + " moles of " + gasType + ".";
        }

        private static string SetGas(string gasName, double moles)
        {
            GasType gasType = ParseGasType(gasName);
            SetTotalGas(gasType, Math.Max(0.0, moles));
            return "Set " + gasType + " to " + moles.ToString("G", CultureInfo.InvariantCulture) + " total moles in the global world-cell atmosphere.";
        }

        private static void SetTotalGas(GasType gasType, double totalMoles)
        {
            double baseMoles = TerraformingFunctions.ThisGlobalPrecise.OnLoadMix.GetMoleValue(gasType).Quantity.ToDouble();
            TerraformingFunctions.ThisGlobalPrecise.SetType(gasType, totalMoles - baseMoles);
        }

        private static void ClearAllGases()
        {
            foreach (GasType gasType in GlobalAtmospherePrecise.gasTypes)
                SetTotalGas(gasType, 0.0);
        }

        private static string SetTemperature(string value)
        {
            if (IsOff(value))
            {
                _forcedTemperatureKelvin = null;
                return "Disabled forced temperature.";
            }

            float kelvin = (float)ParseDouble(value);
            Require(kelvin >= 0, "Temperature must be >= 0 K.");
            _forcedTemperatureKelvin = kelvin;
            return "Forced global temperature to " + kelvin.ToString("G", CultureInfo.InvariantCulture) + " K.";
        }

        private static string SetMultiplier(string value)
        {
            if (IsOff(value) || value.Equals("reset", StringComparison.OrdinalIgnoreCase))
            {
                _runtimeChangeMultiplier = double.NaN;
                return "Reset runtime change multiplier to config/default.";
            }

            double multiplier = ParseDouble(value);
            Require(multiplier >= 0, "Multiplier must be >= 0.");
            _runtimeChangeMultiplier = multiplier;
            return "Set runtime terraforming change multiplier to " + multiplier.ToString("G", CultureInfo.InvariantCulture) + ".";
        }

        private static string ApplyPreset(string presetName)
        {
            switch (presetName.ToLowerInvariant())
            {
                case "mars":
                case "default":
                    TerraformingFunctions.ThisGlobalPrecise.Reset();
                    _forcedTemperatureKelvin = null;
                    return "Returned to the loaded/default global atmosphere.";
                case "breathable":
                    ClearAllGases();
                    SetTotalGas(GasType.Oxygen, 70);
                    SetTotalGas(GasType.Nitrogen, 260);
                    SetTotalGas(GasType.CarbonDioxide, 0.15);
                    _forcedTemperatureKelvin = 293.15f;
                    return "Applied breathable test preset: O2=70, N2=260, CO2=0.15, temp=293.15 K.";
                case "highpressure":
                    ClearAllGases();
                    SetTotalGas(GasType.Oxygen, 200);
                    SetTotalGas(GasType.Nitrogen, 700);
                    SetTotalGas(GasType.CarbonDioxide, 25);
                    _forcedTemperatureKelvin = 293.15f;
                    return "Applied high-pressure test preset.";
                case "co2":
                case "co2heavy":
                    ClearAllGases();
                    SetTotalGas(GasType.CarbonDioxide, 120);
                    _forcedTemperatureKelvin = 273.15f;
                    return "Applied CO2-heavy test preset.";
                default:
                    throw new InvalidOperationException("Unknown preset '" + presetName + "'. Use mars, breathable, highpressure, or co2.");
            }
        }

        private static void WriteStatus(Atmosphere globalAtmosphere, string result)
        {
            try
            {
                File.WriteAllText(StatusFilePath, BuildStatus(globalAtmosphere, result));
            }
            catch (Exception ex)
            {
                TerraformingMod.Log("Failed to write test status: " + ex);
            }
        }

        private static string BuildStatus(Atmosphere globalAtmosphere, string result)
        {
            var mix = globalAtmosphere.GasMixture;
            var sb = new StringBuilder();
            sb.AppendLine("TerraformingMod Test Status");
            sb.AppendLine("UTC: " + DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture));
            sb.AppendLine("Enabled: " + IsEnabled());
            sb.AppendLine("CommandFile: " + CommandFilePath);
            sb.AppendLine("LastCommandFile: " + LastCommandFilePath);
            sb.AppendLine("ChangeMultiplier: " + GetChangeMultiplier().ToString("G", CultureInfo.InvariantCulture));
            sb.AppendLine("ForcedTemperatureK: " + (_forcedTemperatureKelvin.HasValue ? _forcedTemperatureKelvin.Value.ToString("G", CultureInfo.InvariantCulture) : "off"));
            sb.AppendLine("PressureGassesKPa: " + globalAtmosphere.PressureGasses.ToFloat().ToString("G", CultureInfo.InvariantCulture));
            sb.AppendLine("TemperatureK: " + mix.Temperature.ToFloat().ToString("G", CultureInfo.InvariantCulture));
            sb.AppendLine("VolumeLitres: " + globalAtmosphere.Volume.ToDouble().ToString("G", CultureInfo.InvariantCulture));
            sb.AppendLine("TotalGasMoles: " + mix.GetTotalMolesGasses.ToDouble().ToString("G", CultureInfo.InvariantCulture));
            sb.AppendLine();
            sb.AppendLine("Gases:");
            foreach (GasType gasType in GlobalAtmospherePrecise.gasTypes)
            {
                double quantity = mix.GetMoleValue(gasType).Quantity.ToDouble();
                if (Math.Abs(quantity) > 0.000001)
                    sb.AppendLine("  " + gasType + ": " + quantity.ToString("G", CultureInfo.InvariantCulture));
            }

            AppendLocalAtmosphereScan(sb);
            sb.AppendLine();
            sb.AppendLine("LastResult:");
            sb.AppendLine(result ?? string.Empty);
            sb.AppendLine();
            sb.AppendLine(HelpText());
            return sb.ToString();
        }

        private static void AppendLocalAtmosphereScan(StringBuilder sb)
        {
            int worldCells = 0;
            int suspiciousCells = 0;
            double maxMoles = 0;

            if (AtmosphericsManager.AllAtmospheres != null)
            {
                AtmosphericsManager.AllAtmospheres.ForEach(atmosphere =>
                {
                    if (atmosphere == null || atmosphere.IsGlobalAtmosphere || atmosphere.Mode != AtmosphereHelper.AtmosphereMode.World || atmosphere.Room != null)
                        return;

                    worldCells++;
                    double moles = atmosphere.GasMixture.GetTotalMolesGasses.ToDouble();
                    maxMoles = Math.Max(maxMoles, moles);
                    if (moles > 10000)
                        suspiciousCells++;
                });
            }

            sb.AppendLine();
            sb.AppendLine("LocalWorldAtmosphereCells: " + worldCells.ToString(CultureInfo.InvariantCulture));
            sb.AppendLine("LargestLocalWorldCellGasMoles: " + maxMoles.ToString("G", CultureInfo.InvariantCulture));
            sb.AppendLine("SuspiciousLocalWorldCellsOver10000Moles: " + suspiciousCells.ToString(CultureInfo.InvariantCulture));
        }

        private static GasType ParseGasType(string value)
        {
            GasType gasType;
            string normalized = value.Trim().ToLowerInvariant();
            switch (normalized)
            {
                case "o2":
                case "oxygen":
                    return GasType.Oxygen;
                case "n2":
                case "nitrogen":
                    return GasType.Nitrogen;
                case "co2":
                case "carbondioxide":
                case "carbon_dioxide":
                    return GasType.CarbonDioxide;
                case "x":
                case "pollutant":
                case "pollutants":
                    return GasType.Pollutant;
                case "vol":
                case "volatile":
                case "volatiles":
                case "methane":
                case "ch4":
                    return GasType.Methane;
                case "n2o":
                case "nitrousoxide":
                case "nitrous_oxide":
                    return GasType.NitrousOxide;
                case "steam":
                    return GasType.Steam;
                case "h2":
                case "hydrogen":
                    return GasType.Hydrogen;
                case "helium":
                case "he":
                    return GasType.Helium;
                case "hydrazine":
                    return GasType.Hydrazine;
                case "silanol":
                    return GasType.Silanol;
                case "hcl":
                case "acid":
                case "hydrochloricacid":
                case "hydrochloric_acid":
                    return GasType.HydrochloricAcid;
                case "o3":
                case "ozone":
                    return GasType.Ozone;
            }

            if (Enum.TryParse(value, true, out gasType))
                return gasType;

            throw new InvalidOperationException("Unknown gas '" + value + "'.");
        }

        private static double ParseDouble(string value)
        {
            double result;
            if (!double.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out result))
                throw new InvalidOperationException("Expected number, got '" + value + "'.");

            return result;
        }

        private static void Require(bool condition, string message)
        {
            if (!condition)
                throw new InvalidOperationException(message);
        }

        private static bool IsOff(string value)
        {
            return value.Equals("off", StringComparison.OrdinalIgnoreCase) ||
                   value.Equals("none", StringComparison.OrdinalIgnoreCase) ||
                   value.Equals("false", StringComparison.OrdinalIgnoreCase);
        }

        private static string StripComment(string line)
        {
            int index = line.IndexOf('#');
            return index >= 0 ? line.Substring(0, index) : line;
        }

        private static void EnsureExampleFile()
        {
            if (File.Exists(ExampleFilePath))
                return;

            try
            {
                File.WriteAllText(ExampleFilePath, HelpText());
            }
            catch
            {
                // Non-critical; status still includes the same help text.
            }
        }

        private static string HelpText()
        {
            return
@"Commands: create BepInEx/config/TerraformingMod.TestCommands.txt with one command per line.
status
help
add <gas> <moles>          Example: add O2 10
set <gas> <moles>          Example: set CO2 0.5
clear                      Set tracked global gases to zero
reset                      Return to loaded/default atmosphere and clear test overrides
temp <kelvin|off>          Example: temp 293.15
multiplier <number|reset>  Multiplies future terraforming changes from gameplay
preset mars
preset breathable
preset highpressure
preset co2

Gas aliases: O2, N2, CO2, X/Pollutant, Volatiles/Methane, N2O, Steam, H2, Helium, Hydrazine, Silanol, HCl, O3.";
        }
    }
}
