# Patrouille Hydroponique LArRE

`LARRE_HYDROPONICS.ic10` contrôle un LArRE Dock (Hydroponics) nommé sans
utiliser les pins de l'IC. Le script parcourt une plage de stations de culture
configurée, échantillonne le slot proxy hydroponique sous chaque station, et
utilise des stations de chute dédiées aux graines et aux récoltes afin que LArRE
puisse garder la ligne automatique.

En bref, LArRE patrouille votre rail hydroponique et s'occupe de la maintenance
simple des plateaux. Il visite chaque station de culture configurée, vérifie le
plateau en dessous, prend des graines dans un seed export bin, plante les
plateaux vides, récolte les graines et les cultures, puis dépose la sortie dans
les bacs de chute quand le plateau demande une action.

## Étiquette et Stations Requises

Toutes les étiquettes sont sensibles à la casse. Le nom dans `HASH("name")`
doit correspondre exactement à l'étiquette du device en jeu.

| Étiquette | Type de device | Utilité |
| --- | --- | --- |
| `LArRE` | `StructureLarreDockHydroponics` | LArRE Dock (Hydroponics) contrôlé par le script. |

L'IC peut être installé n'importe où sur le même data network que le dock LArRE.
Il utilise des lectures et écritures batch par prefab hash et étiquette, donc
aucune pin n'est requise.

Seul le LArRE Dock (Hydroponics) a besoin de cette étiquette. Ne nommez pas
chaque station de rail `Station`, `Station1`, ou quelque chose de similaire pour
ce script. Les arrêts de rail sont sélectionnés par leur index numérique de
station via la valeur `Setting` du dock.

Disposition par défaut des stations:

| Rôle | Station par défaut | Cible physique sous la station | Utilité |
| --- | --- | --- | --- |
| Plateaux de culture | `0` à `15` | Hydroponics trays/devices | LArRE plante, récolte et nettoie les cultures. |
| Seed import bin | `16` | Chute Import Bin | LArRE dépose les graines récoltées dans le réseau de chute des graines. |
| Seed export bin | `17` | Chute Export Bin | LArRE prend des graines depuis le réseau de chute des graines avant de planter. |
| Crops export bin | `18` | Chute Import Bin | LArRE dépose les récoltes ou les plantes mortes nettoyées dans le réseau de sortie. |

La station crops export utilise un Chute Import Bin parce que LArRE place les
items dans le réseau de chute. Le nom décrit le rôle de la station du point de
vue de la serre.

## Comportement

Plage de stations de culture et stations de bacs par défaut:

```ic10
define FIRST_GROW_STATION 0
define LAST_GROW_STATION 15
define SEED_IMPORT_STATION 16
define SEED_EXPORT_STATION 17
define CROPS_EXPORT_STATION 18
```

Pour chaque station de culture, le script écrit le numéro de station dans
`Setting`, attend que LArRE soit idle, puis lit le slot `255` sur le dock
hydroponique nommé.

Le cycle automatique:

1. Plateau vide: LArRE visite le seed export bin, prend une graine si elle est
   disponible, retourne au plateau et la plante.
2. Plante en seed: LArRE récolte la graine et la dépose dans le seed import bin.
3. Plante mature: LArRE récolte la culture et la dépose dans le crops export bin.
4. Plante morte: LArRE nettoie le plateau et dépose la plante morte dans le
   crops export bin.

Pour les stations de transfert par chute:

- Chute Import Bin = LArRE dépose les items dans le réseau de chute.
- Chute Export Bin = LArRE peut prendre des items depuis le réseau de chute.

Envoyer une impulsion sur `Activate` dit à LArRE d'utiliser la pince à la station
actuelle. S'il tient des cultures ou des graines et qu'il y a un Chute Import Bin
sous la station, il devrait placer ou déposer l'item dans ce bin.

Après la dernière station, le script attend 10 secondes et recommence la
patrouille.

## Options

Modifiez ces valeurs directement dans `LARRE_HYDROPONICS.ic10`:

| Option | Défaut | Comportement |
| --- | --- | --- |
| `LARRE_NAME` | `HASH("LArRE")` | Étiquette en jeu du LArRE Dock (Hydroponics). |
| `FIRST_GROW_STATION` | `0` | Premier index de station de plateau de culture à visiter. |
| `LAST_GROW_STATION` | `15` | Dernier index de station de plateau de culture à visiter. |
| `SEED_IMPORT_STATION` | `16` | Station avec le Chute Import Bin où LArRE dépose les graines récoltées. |
| `SEED_EXPORT_STATION` | `17` | Station avec le Chute Export Bin où LArRE prend les graines à planter. |
| `CROPS_EXPORT_STATION` | `18` | Station avec le Chute Import Bin où LArRE dépose les récoltes et plantes mortes. |
| `ACTION_SETTLE_SECONDS` | `2` | Délai après une action de pince avant de revérifier l'état idle. |
| `LOOP_PAUSE_SECONDS` | `10` | Délai entre les boucles de patrouille. |

## Fichiers

- `LARRE_HYDROPONICS.ic10` - version name/hash pour un LArRE Dock (Hydroponics).
- `README.md` - version anglaise originale de ce README.
