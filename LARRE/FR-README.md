# Patrouille hydroponique LArRE

Cette branche teste un système LArRE hydroponique avec plusieurs IC. Le script
`LARRE_BRAIN.ic10` décide quoi faire à chaque station,
`LARRE_DRIVER.ic10` déplace ou active le LArRE Dock (Hydroponics), et
`LARRE_EXPORT_BIN.ic10` garde les chute import bins de graines/cultures en
mode envoi vers le réseau de chute.

La séparation laisse plus d'espace pour ajouter des comportements plus tard tout
en gardant chaque script IC sous la limite IC10 de 128 lignes.

## Installation

Chargez les scripts dans des IC housings standards sur le même data network:

| Script | Rôle |
| --- | --- |
| `LARRE_BRAIN.ic10` | Patrouille les stations de culture et envoie les commandes inspect/action. |
| `LARRE_DRIVER.ic10` | Déplace LArRE, active la pince et rapporte l'état du slot. |
| `LARRE_EXPORT_BIN.ic10` | Ferme les chute import bins de graines/cultures occupés afin d'envoyer les items dans le réseau de chute. |

Aucune pin d'IC n'est utilisée. Le brain et le driver communiquent avec des
Logic Memory nommées sur le réseau de câbles, donc cette version fonctionne avec
des housings IC normaux et ne dépend pas du stack partagé d'un mod ni des
écritures réseau `db:1 Channel`. L'IC export-bin est indépendant et doit
seulement accéder aux chute import bins étiquetés.

## Étiquette et Stations Requises

Toutes les étiquettes sont sensibles à la casse. Le nom dans `HASH("name")`
doit correspondre exactement à l'étiquette du device en jeu.

| Étiquette | Type de device | Utilité |
| --- | --- | --- |
| `LArRE` | `StructureLarreDockHydroponics` | LArRE Dock (Hydroponics) contrôlé par le driver IC. |
| `SEED_EXPORT_BIN` | Chute Import Bin | Bin sous la station `17` où LArRE dépose les graines récoltées. |
| `CROP_EXPORT_BIN` | Chute Import Bin | Bin sous la station `18` où LArRE dépose les récoltes et plantes mortes. |

Ajoutez ces huit Logic Memory sur le même data network:

| Étiquette | Utilité |
| --- | --- |
| `LARRE_BUS_REQ` | Id de requête du brain vers le driver. |
| `LARRE_BUS_TARGET` | Index de la station cible. |
| `LARRE_BUS_CMD` | Commande: `1` = inspect, `2` = action. |
| `LARRE_BUS_DONE` | Id de requête complétée du driver vers le brain. |
| `LARRE_BUS_OCCUPIED` | Dernière valeur `Occupied` du slot `255`. |
| `LARRE_BUS_MATURE` | Dernière valeur `Mature` du slot `255`. |
| `LARRE_BUS_SEEDING` | Dernière valeur `Seeding` du slot `255`. |
| `LARRE_BUS_DAMAGE` | Dernière valeur `Damage` du slot `255`. |

Seul le LArRE Dock (Hydroponics) a besoin de cette étiquette. Ne nommez pas
chaque station de rail `Station`, `Station1`, ou quelque chose de similaire pour
ce système. Les arrêts de rail sont sélectionnés par leur index numérique de
station via la valeur `Setting` du dock.

Disposition par défaut des stations:

| Rôle | Station par défaut | Cible physique sous la station | Utilité |
| --- | --- | --- | --- |
| Plateaux de culture | `0` à `15` | Hydroponics trays/devices | LArRE plante, récolte et nettoie les cultures. |
| Seed import station | `16` | Chute Export Bin | LArRE prend des graines depuis le réseau de chute des graines avant de planter. |
| Seed export station | `17` | Chute Import Bin étiqueté `SEED_EXPORT_BIN` | LArRE dépose les graines récoltées dans le réseau de chute des graines. |
| Crops export bin | `18` | Chute Import Bin étiqueté `CROP_EXPORT_BIN` | LArRE dépose les récoltes ou les plantes mortes nettoyées dans le réseau de sortie. |

La station seed import utilise un Chute Export Bin parce que LArRE prend les
graines depuis le réseau de chute. Les stations seed export et crops export
utilisent des Chute Import Bins parce que LArRE place les items dans le réseau
de chute.
`LARRE_EXPORT_BIN.ic10` surveille ces deux import bins. Les bins vides restent
ouverts; lorsqu'un item apparaît dans le slot `0`, le script ferme le bin afin
de l'envoyer dans le réseau de chute.

## Protocole Logic Memory

Le brain écrit les commandes dans des Logic Memory nommées, et le driver écrit
les valeurs de complétion/statut dans le même bus:

| Étiquette mémoire | Propriétaire | Signification |
| --- | --- | --- |
| `LARRE_BUS_REQ` | Brain | Id de requête. Incrémenté à chaque commande. |
| `LARRE_BUS_TARGET` | Brain | Index de la station cible. |
| `LARRE_BUS_CMD` | Brain | Commande: `1` = inspect, `2` = action. |
| `LARRE_BUS_DONE` | Driver | Id de requête complétée. |
| `LARRE_BUS_OCCUPIED` | Driver | Valeur `Occupied` du slot `255`. |
| `LARRE_BUS_MATURE` | Driver | Valeur `Mature` du slot `255`. |
| `LARRE_BUS_SEEDING` | Driver | Valeur `Seeding` du slot `255`. |
| `LARRE_BUS_DAMAGE` | Driver | Valeur `Damage` du slot `255`. |

Redémarrez les deux IC après le chargement afin que les mémoires de bus soient
réinitialisées avant que le driver traite les requêtes.

## Comportement

Plage de stations de culture et stations de bacs par défaut:

```ic10
define FIRST_GROW_STATION 0
define LAST_GROW_STATION 15
define SEED_IMPORT_STATION 16
define SEED_EXPORT_STATION 17
define CROPS_EXPORT_STATION 18
```

Le cycle automatique:

1. Plateau vide: LArRE visite la station seed import, prend une graine si elle
   est disponible, retourne au plateau et la plante.
2. Plante mature sans graines prêtes: LArRE attend et ne récolte pas encore.
3. Plante en seed: LArRE récolte la graine, la dépose dans la station seed
   export, puis retourne récolter les cultures jusqu'à ce qu'il n'y ait plus de
   fruit prêt sur la plante.
4. Plante morte: LArRE nettoie le plateau et dépose toujours la plante morte
   dans le crops export bin.
5. Export bins: l'IC export-bin ferme les import bins de graines/cultures occupés
   pour pousser les items déposés dans le réseau de chute, puis les rouvre quand
   ils sont vides.

Le système utilise la valeur de slot `Seeding` pour éviter de récolter trop tôt.
`Seeding` doit être supérieur à `0` avant que LArRE récolte la plante, donc il
attend que les graines soient prêtes avant de prendre la culture.

## Options

Modifiez ces valeurs directement dans les scripts:

| Option | Script | Défaut | Comportement |
| --- | --- | --- | --- |
| `LARRE_NAME` | `LARRE_DRIVER.ic10` | `HASH("LArRE")` | Étiquette en jeu du LArRE Dock (Hydroponics). |
| `FIRST_GROW_STATION` | `LARRE_BRAIN.ic10` | `0` | Premier index de station de plateau de culture à visiter. |
| `LAST_GROW_STATION` | `LARRE_BRAIN.ic10` | `15` | Dernier index de station de plateau de culture à visiter. |
| `SEED_IMPORT_STATION` | `LARRE_BRAIN.ic10` | `16` | Station avec le Chute Export Bin où LArRE prend les graines à planter. |
| `SEED_EXPORT_STATION` | `LARRE_BRAIN.ic10` | `17` | Station avec le Chute Import Bin où LArRE dépose les graines récoltées. |
| `CROPS_EXPORT_STATION` | `LARRE_BRAIN.ic10` | `18` | Station avec le Chute Import Bin où LArRE dépose les récoltes et plantes mortes. |
| `ACTION_SETTLE_SECONDS` | `LARRE_DRIVER.ic10` | `2` | Délai après une action de pince avant de revérifier l'état idle. |
| `LOOP_PAUSE_SECONDS` | `LARRE_BRAIN.ic10` | `10` | Délai entre les boucles de patrouille. |
| `SEED_EXPORT_BIN` | `LARRE_EXPORT_BIN.ic10` | `HASH("SEED_EXPORT_BIN")` | Étiquette du Chute Import Bin pour les graines récoltées. |
| `CROP_EXPORT_BIN` | `LARRE_EXPORT_BIN.ic10` | `HASH("CROP_EXPORT_BIN")` | Étiquette du Chute Import Bin pour les récoltes et plantes mortes. |

## Fichiers

- `LARRE_BRAIN.ic10` - IC de décision et de patrouille.
- `LARRE_DRIVER.ic10` - IC de mouvement/action LArRE.
- `LARRE_EXPORT_BIN.ic10` - IC de contrôle des chute import bins graines/cultures.
- `README.md` - version anglaise originale de ce README.
