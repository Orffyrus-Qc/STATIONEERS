# Reacteur batch de CO2

`CO2_BATCH_REACTOR.ic10` et `CO2_BATCH_REACTOR_EXHAUST.ic10` produisent de
petits lots de CO2 en remplissant une chambre de combustion isolee avec du CH4
et de l'O2, en envoyant une impulsion a un allumeur nomme, puis en pompant le
resultat vers un reservoir de stockage de CO2. Le travail est separe sur deux IC
afin que chaque script reste sous la limite IC10 de 128 lignes.

## Configuration

Nommez les appareils:

| Etiquette | Type d'appareil | Role |
| --- | --- | --- |
| `CO2_REACTOR_SENSOR` | `StructureGasSensor` ou `StructurePipeAnalysizer` | Lit la pression de la chambre, les ratios de gaz et l'etat de combustion. |
| `CO2_TANK_SENSOR` | `StructureGasSensor` ou `StructurePipeAnalysizer` | Lit la pression du reservoir de stockage. |
| `CO2_REACTOR_PHASE` | `StructureLogicMemory` | Signal de phase partage entre l'IC de remplissage/allumage et l'IC d'evacuation. |
| `CH4_VALVE` | `StructureDigitalValve` | Ajoute du CH4 a la chambre de combustion. |
| `O2_VALVE` | `StructureDigitalValve` | Ajoute de l'O2 a la chambre de combustion. |
| `CO2_OUTPUT_PUMP` | Pompe volumetrique ou pompe volumetrique turbo | Transfere le gaz de la chambre vers la ligne de stockage de CO2. |
| `CO2_IGNITER` | `StructureIgniter` | Demarre la combustion une fois la chambre remplie. |

Chargez `CO2_BATCH_REACTOR.ic10` dans un IC housing et
`CO2_BATCH_REACTOR_EXHAUST.ic10` dans un deuxieme IC housing sur le meme reseau
de donnees que la Logic Memory partagee.

La pompe de sortie peut etre une `StructureVolumePump` ou une
`StructureTurboVolumePump`. L'IC d'evacuation l'utilise comme etape
d'evacuation par defaut avant de permettre le remplissage.

## Comportement

Valeurs par defaut:

```ic10
define TARGET_CH4_KPA 2
define TARGET_O2_KPA 1
define EMPTY_KPA 0.25
define TANK_MAX_KPA 9000
define OUTPUT_PUMP_RATE 10
```

L'IC de remplissage/allumage commence par demander le mode evacuation afin que
l'IC d'evacuation puisse vider la chambre vers la ligne de stockage avec
`CO2_OUTPUT_PUMP`. Il ouvre ensuite `CH4_VALVE` et `O2_VALVE` seulement jusqu'a
environ `2 kPa` de CH4 et `1 kPa` d'O2, en utilisant la pression partielle lue
par le capteur de la chambre afin que le lot reste proportionnel meme lorsque la
pression totale change.

Apres le remplissage, l'IC de remplissage/allumage envoie une impulsion a
`CO2_IGNITER`, attend la fin de `Combustion`, puis ecrit le mode evacuation dans
`CO2_REACTOR_PHASE`. L'IC d'evacuation lance la pompe de sortie CO2 jusqu'a ce
que la chambre descende sous `0.25 kPa`, puis ecrit le mode pret
afin que le prochain lot puisse commencer. Si le capteur du reservoir indique
plus de `9000 kPa`, la pompe de sortie reste eteinte jusqu'a ce que la pression
du reservoir baisse.

Les valeurs de `CO2_REACTOR_PHASE` sont `0` pret/vide, `1`
remplissage/allumage/combustion et `2` evacuation.

## Notes

Le script lit CH4/methane avec `RatioMethane`.

Gardez la chambre de combustion petite et isolee. Les scripts controlent `On`
des valves, ainsi que `On` et `Setting` de la pompe de sortie. Si une tres
petite chambre casse encore les fenetres
proches, baissez `TARGET_CH4_KPA` et `TARGET_O2_KPA` ensemble pour garder le
meme ratio de gaz 2:1.
