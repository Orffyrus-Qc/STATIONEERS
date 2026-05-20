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
| `CH4_PUMP` | Pompe volumetrique ou pompe volumetrique turbo | Ajoute du CH4 a la chambre de combustion. |
| `O2_PUMP` | Pompe volumetrique ou pompe volumetrique turbo | Ajoute de l'O2 a la chambre de combustion. |
| `CO2_OUTPUT_PUMP` | Pompe volumetrique ou pompe volumetrique turbo | Transfere le gaz final de la chambre vers le stockage. |
| `CO2_IGNITER` | `StructureIgniter` | Demarre la combustion une fois la chambre remplie. |

Chargez `CO2_BATCH_REACTOR.ic10` dans un IC housing et
`CO2_BATCH_REACTOR_EXHAUST.ic10` dans un deuxieme IC housing sur le meme reseau
de donnees que la Logic Memory partagee.

Les trois pompes peuvent etre des `StructureVolumePump` ou des
`StructureTurboVolumePump`. Les scripts ecrivent vers les deux hash de prefab, donc
seul l'appareil nomme correspondant repondra.

## Comportement

Valeurs par defaut:

```ic10
define TARGET_CH4_KPA 10
define TARGET_O2_KPA 5
define EMPTY_KPA 1
define TANK_MAX_KPA 9000
define INPUT_PUMP_RATE 5
define OUTPUT_PUMP_RATE 10
```

L'IC de remplissage/allumage commence par demander le mode evacuation afin que
l'IC d'evacuation puisse vider la chambre vers la ligne de stockage. Il remplit
ensuite la chambre jusqu'a environ `10 kPa` de CH4 et `5 kPa` d'O2, en utilisant
la pression partielle lue par le capteur de la chambre afin que le lot reste
proportionnel meme lorsque la pression totale change.

Apres le remplissage, l'IC de remplissage/allumage envoie une impulsion a
`CO2_IGNITER`, attend la fin de `Combustion`, puis ecrit le mode evacuation dans
`CO2_REACTOR_PHASE`. L'IC d'evacuation pompe le gaz final vers le reservoir de
CO2 jusqu'a ce que la chambre descende sous `1 kPa`, puis ecrit le mode pret
afin que le prochain lot puisse commencer. Si le capteur du reservoir indique
plus de `9000 kPa`, la pompe de sortie reste eteinte jusqu'a ce que la pression
du reservoir baisse.

Les valeurs de `CO2_REACTOR_PHASE` sont `0` pret/vide, `1`
remplissage/allumage/combustion et `2` evacuation.

## Notes

La base de donnees logique IC10 actuelle expose CH4/methane sous le nom
`RatioVolatiles`. Si votre version du jeu accepte seulement `RatioMethane`,
remplacez `RatioVolatiles` dans le script.

Gardez la chambre de combustion petite et isolee. Les scripts controlent `On` et
`Setting` des pompes; configurez la direction et le mode de la pompe turbo sur la
pompe elle-meme au besoin.
