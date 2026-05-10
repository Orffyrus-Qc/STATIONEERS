using Assets.Scripts;
using Assets.Scripts.Atmospherics;
using static Assets.Scripts.Atmospherics.Chemistry;

namespace TerraformingMod
{
    public class GasMixSaveData
    {
        public GasQuantitySaveData Oxygen { get; set; }
        public GasQuantitySaveData Nitrogen { get; set; }
        public GasQuantitySaveData CarbonDioxide { get; set; }
        public GasQuantitySaveData Methane { get; set; }
        public GasQuantitySaveData Volatiles
        {
            get { return Methane; }
            set { Methane = value; }
        }
        public bool ShouldSerializeVolatiles()
        {
            return false;
        }
        public GasQuantitySaveData Pollutant { get; set; }
        public GasQuantitySaveData Water { get; set; }
        public GasQuantitySaveData PollutedWater { get; set; }
        public GasQuantitySaveData NitrousOxide { get; set; }
        public GasQuantitySaveData LiquidNitrogen { get; set; }
        public GasQuantitySaveData LiquidOxygen { get; set; }
        public GasQuantitySaveData LiquidMethane { get; set; }
        public GasQuantitySaveData LiquidVolatiles
        {
            get { return LiquidMethane; }
            set { LiquidMethane = value; }
        }
        public bool ShouldSerializeLiquidVolatiles()
        {
            return false;
        }
        public GasQuantitySaveData Steam { get; set; }
        public GasQuantitySaveData LiquidCarbonDioxide { get; set; }
        public GasQuantitySaveData LiquidPollutant { get; set; }
        public GasQuantitySaveData LiquidNitrousOxide { get; set; }
        public GasQuantitySaveData Hydrogen { get; set; }
        public GasQuantitySaveData LiquidHydrogen { get; set; }
        public GasQuantitySaveData Hydrazine { get; set; }
        public GasQuantitySaveData LiquidHydrazine { get; set; }
        public GasQuantitySaveData LiquidAlcohol { get; set; }
        public GasQuantitySaveData Helium { get; set; }
        public GasQuantitySaveData LiquidSodiumChloride { get; set; }
        public GasQuantitySaveData Silanol { get; set; }
        public GasQuantitySaveData LiquidSilanol { get; set; }
        public GasQuantitySaveData HydrochloricAcid { get; set; }
        public GasQuantitySaveData LiquidHydrochloricAcid { get; set; }
        public GasQuantitySaveData Ozone { get; set; }
        public GasQuantitySaveData LiquidOzone { get; set; }

        public GasMixSaveData() { }

        public GasMixSaveData(GasMixture gasMixture)
        {
            foreach (GasType type in GlobalAtmospherePrecise.gasTypes)
            {
                SetType(type, new GasQuantitySaveData(gasMixture.GetMoleValue(type)));
            }
        }

        public GasMixture Apply()
        {
            var gasMixture = GasMixtureHelper.Create();
            foreach (GasType type in GlobalAtmospherePrecise.gasTypes)
            {
                var gas = GetType(type);
                gasMixture.SetMoleValue(type, new MoleQuantity(gas.Quantity), new MoleEnergy(gas.Energy));
            }

            gasMixture.UpdateCache(DirtyMoleTolerance.Precision);
            return gasMixture;
        }

        private GasQuantitySaveData GetType(GasType gasType)
        {
            switch (gasType)
            {
                case GasType.Oxygen:
                    return Oxygen ?? GasQuantitySaveData.Empty;
                case GasType.Nitrogen:
                    return Nitrogen ?? GasQuantitySaveData.Empty;
                case GasType.CarbonDioxide:
                    return CarbonDioxide ?? GasQuantitySaveData.Empty;
                case GasType.Methane:
                    return Methane ?? GasQuantitySaveData.Empty;
                case GasType.Pollutant:
                    return Pollutant ?? GasQuantitySaveData.Empty;
                case GasType.Water:
                    return Water ?? GasQuantitySaveData.Empty;
                case GasType.PollutedWater:
                    return PollutedWater ?? GasQuantitySaveData.Empty;
                case GasType.NitrousOxide:
                    return NitrousOxide ?? GasQuantitySaveData.Empty;
                case GasType.LiquidNitrogen:
                    return LiquidNitrogen ?? GasQuantitySaveData.Empty;
                case GasType.LiquidOxygen:
                    return LiquidOxygen ?? GasQuantitySaveData.Empty;
                case GasType.LiquidMethane:
                    return LiquidMethane ?? GasQuantitySaveData.Empty;
                case GasType.Steam:
                    return Steam ?? GasQuantitySaveData.Empty;
                case GasType.LiquidCarbonDioxide:
                    return LiquidCarbonDioxide ?? GasQuantitySaveData.Empty;
                case GasType.LiquidPollutant:
                    return LiquidPollutant ?? GasQuantitySaveData.Empty;
                case GasType.LiquidNitrousOxide:
                    return LiquidNitrousOxide ?? GasQuantitySaveData.Empty;
                case GasType.Hydrogen:
                    return Hydrogen ?? GasQuantitySaveData.Empty;
                case GasType.LiquidHydrogen:
                    return LiquidHydrogen ?? GasQuantitySaveData.Empty;
                case GasType.Hydrazine:
                    return Hydrazine ?? GasQuantitySaveData.Empty;
                case GasType.LiquidHydrazine:
                    return LiquidHydrazine ?? GasQuantitySaveData.Empty;
                case GasType.LiquidAlcohol:
                    return LiquidAlcohol ?? GasQuantitySaveData.Empty;
                case GasType.Helium:
                    return Helium ?? GasQuantitySaveData.Empty;
                case GasType.LiquidSodiumChloride:
                    return LiquidSodiumChloride ?? GasQuantitySaveData.Empty;
                case GasType.Silanol:
                    return Silanol ?? GasQuantitySaveData.Empty;
                case GasType.LiquidSilanol:
                    return LiquidSilanol ?? GasQuantitySaveData.Empty;
                case GasType.HydrochloricAcid:
                    return HydrochloricAcid ?? GasQuantitySaveData.Empty;
                case GasType.LiquidHydrochloricAcid:
                    return LiquidHydrochloricAcid ?? GasQuantitySaveData.Empty;
                case GasType.Ozone:
                    return Ozone ?? GasQuantitySaveData.Empty;
                case GasType.LiquidOzone:
                    return LiquidOzone ?? GasQuantitySaveData.Empty;
                default:
                    return GasQuantitySaveData.Empty;
            }
        }

        private void SetType(GasType gasType, GasQuantitySaveData gas)
        {
            switch (gasType)
            {
                case GasType.Oxygen:
                    Oxygen = gas;
                    break;
                case GasType.Nitrogen:
                    Nitrogen = gas;
                    break;
                case GasType.CarbonDioxide:
                    CarbonDioxide = gas;
                    break;
                case GasType.Methane:
                    Methane = gas;
                    break;
                case GasType.Pollutant:
                    Pollutant = gas;
                    break;
                case GasType.Water:
                    Water = gas;
                    break;
                case GasType.PollutedWater:
                    PollutedWater = gas;
                    break;
                case GasType.NitrousOxide:
                    NitrousOxide = gas;
                    break;
                case GasType.LiquidNitrogen:
                    LiquidNitrogen = gas;
                    break;
                case GasType.LiquidOxygen:
                    LiquidOxygen = gas;
                    break;
                case GasType.LiquidMethane:
                    LiquidMethane = gas;
                    break;
                case GasType.Steam:
                    Steam = gas;
                    break;
                case GasType.LiquidCarbonDioxide:
                    LiquidCarbonDioxide = gas;
                    break;
                case GasType.LiquidPollutant:
                    LiquidPollutant = gas;
                    break;
                case GasType.LiquidNitrousOxide:
                    LiquidNitrousOxide = gas;
                    break;
                case GasType.Hydrogen:
                    Hydrogen = gas;
                    break;
                case GasType.LiquidHydrogen:
                    LiquidHydrogen = gas;
                    break;
                case GasType.Hydrazine:
                    Hydrazine = gas;
                    break;
                case GasType.LiquidHydrazine:
                    LiquidHydrazine = gas;
                    break;
                case GasType.LiquidAlcohol:
                    LiquidAlcohol = gas;
                    break;
                case GasType.Helium:
                    Helium = gas;
                    break;
                case GasType.LiquidSodiumChloride:
                    LiquidSodiumChloride = gas;
                    break;
                case GasType.Silanol:
                    Silanol = gas;
                    break;
                case GasType.LiquidSilanol:
                    LiquidSilanol = gas;
                    break;
                case GasType.HydrochloricAcid:
                    HydrochloricAcid = gas;
                    break;
                case GasType.LiquidHydrochloricAcid:
                    LiquidHydrochloricAcid = gas;
                    break;
                case GasType.Ozone:
                    Ozone = gas;
                    break;
                case GasType.LiquidOzone:
                    LiquidOzone = gas;
                    break;
            }
        }
    }

    public class GasQuantitySaveData
    {
        public static readonly GasQuantitySaveData Empty = new GasQuantitySaveData();

        public double Quantity { get; set; }
        public double Energy { get; set; }

        public GasQuantitySaveData() { }

        public GasQuantitySaveData(Mole mole)
        {
            Quantity = mole.Quantity.ToDouble();
            Energy = mole.Energy.ToDouble();
        }
    }
}
