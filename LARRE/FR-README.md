# Patrouille hydroponique LArRE

Cette branche teste un système LArRE hydroponique avec plusieurs IC. Le script
`LARRE_BRAIN.ic10` décide quoi faire à chaque station,
`LARRE_DRIVER.ic10` déplace ou active le LArRE Dock (Hydroponics), et
`LARRE_EXPORT_BIN.ic10` garde les chute import bins de graines/cultures en
mode envoi vers le réseau de chute. L'aide optionnelle
`LARRE_CHUTE_STACKER_CONTROL.ic10` utilise des boutons séparés `START` et `STOP`
pour activer/désactiver le seed supply export bin nommé, `MANUAL` pour envoyer un pulse
de vidage aux stackers, et `AUTO` pour répéter ce pulse sur minuterie.
`LARRE_POWER_LEVER.ic10` permet à un Big Lever ou Flip Cover Switch nommé
`LArRE_SWITCH` d'activer ou désactiver le LArRE Dock.

La séparation laisse plus d'espace pour ajouter des comportements plus tard tout
en gardant chaque script IC sous la limite IC10 de 128 lignes.

## Installation

Chargez les scripts dans des IC housings standards sur le même data network:

| Script | Rôle |
| --- | --- |
| `LARRE_BRAIN.ic10` | Patrouille les stations de culture et envoie les commandes inspect/action. |
| `LARRE_DRIVER.ic10` | Déplace LArRE, active la pince et rapporte l'état du slot. |
| `LARRE_EXPORT_BIN.ic10` | Ferme les chute import bins de graines/cultures occupés afin d'envoyer les items dans le réseau de chute. |
| `LARRE_CHUTE_STACKER_CONTROL.ic10` | Active/désactive le seed supply export bin nommé et vide tous les stackers avec des boutons. |
| `LARRE_POWER_LEVER.ic10` | Copie l'état d'un Big Lever ou Flip Cover Switch nommé `LArRE_SWITCH` vers l'état `On` du LArRE Dock. |

Aucune pin d'IC n'est utilisée. Le brain et le driver communiquent avec des
Logic Memory nommées sur le réseau de câbles, donc cette version fonctionne avec
des housings IC normaux et ne dépend pas du stack partagé d'un mod ni des
écritures réseau `db:1 Channel`. Les IC export-bin et chute/stacker sont
indépendants et doivent seulement accéder aux devices étiquetés sur le même
data network.

## Étiquette et Stations Requises

Toutes les étiquettes sont sensibles à la casse. Le nom dans `HASH("name")`
doit correspondre exactement à l'étiquette du device en jeu.

| Étiquette | Type de device | Utilité |
| --- | --- | --- |
| `LArRE` | `StructureLarreDockHydroponics` | LArRE Dock (Hydroponics). |
| `LArRE_SWITCH` | `ModularDeviceBigLever` ou `ModularDeviceFlipCoverSwitch` optionnel | Contrôle de puissance qui active/désactive le LArRE Dock. |
| `SEED_SUPPLYER` | `StructureChuteExportBin` | Chute Export Bin contrôlé par les boutons START et STOP. |
| `SEED_EXPORT_BIN` | Chute Import Bin | Bin sous la station `17` où LArRE dépose les graines récoltées. |
| `CROP_EXPORT_BIN` | Chute Import Bin | Bin sous la station `18` où LArRE dépose les récoltes et plantes mortes. |
| `START` | `ModularDeviceUtilityButton2x2` | Met `On` de `SEED_SUPPLYER` à `1`. |
| `STOP` | `ModularDeviceUtilityButton2x2` | Met `On` de `SEED_SUPPLYER` à `0`. |
| `MANUAL` | `ModularDeviceUtilityButton2x2` | Envoie un pulse de vidage à tous les stackers. |
| `AUTO` | `ModularDeviceUtilityButton2x2` | Active/désactive le vidage automatique des stackers toutes les `300` secondes. |
| `Vider` | `ModularDeviceLabelDiode3` | Indicateur du mode auto; jaune quand inactif, bleu quand actif. |
| `Empileurs` | `ModularDeviceLabelDiode3` | Indicateur du mode auto; jaune quand inactif, bleu quand actif. |
| `Planter` | `ModularDeviceLabelDiode3` | Indicateur de `SEED_SUPPLYER`; rouge quand inactif, vert quand actif. |

`LARRE_CHUTE_STACKER_CONTROL.ic10` contrôle le `StructureChuteExportBin` nommé
`SEED_SUPPLYER` par hash de prefab/nom. Il vide encore tous les
`StructureStacker` et `StructureStackerReverse` sur le data network de l'IC par
hash de prefab, donc ces stackers n'ont pas besoin d'étiquettes individuelles.
Il colore aussi les `ModularDeviceLabelDiode3`: `Vider` et `Empileurs` sont
jaunes quand le mode auto est inactif et bleus quand il est actif; `Planter` est
rouge quand `SEED_SUPPLYER` est inactif (`On` = `0`) et vert quand il est
actif (`On` = `1`).

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

Seul le LArRE Dock (Hydroponics) a besoin de l'étiquette `LArRE` pour les IC de
patrouille. Ne nommez pas chaque station de rail `Station`, `Station1`, ou
quelque chose de similaire pour ce système. Les arrêts de rail sont sélectionnés
par leur index numérique de station via la valeur `Setting` du dock.
Si vous utilisez `LARRE_POWER_LEVER.ic10`, étiquetez le LArRE Dock `LArRE` et le
Big Lever ou Flip Cover Switch `LArRE_SWITCH`; l'IC les sépare par hash de
prefab/nom, donc aucune pin n'est requise.

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
6. Aide chute/stacker: appuyer sur `START` met la valeur `On` du Chute Export
   Bin alimenté nommé `SEED_SUPPLYER` à `1`, et il reste actif jusqu'à ce que
   `STOP` mette `On` à `0`. Appuyer sur `MANUAL` envoie un pulse de vidage à
   tous les stackers normaux/inversés. Appuyer sur `AUTO` active/désactive le
   mode auto; quand le mode auto est actif, le même pulse de vidage est envoyé
   toutes les 300 secondes. `Vider` et `Empileurs` affichent le mode auto,
   tandis que `Planter` affiche l'état `On` actuel de `SEED_SUPPLYER`.
7. Aide levier de puissance: `LARRE_POWER_LEVER.ic10` lit `Open` du
   `ModularDeviceBigLever` nommé `LArRE_SWITCH`. Pour le
   `ModularDeviceFlipCoverSwitch` nommé `LArRE_SWITCH`, il exige que `Open` et
   `On` soient vrais. Il écrit l'état combiné dans le LArRE Dock nommé `LArRE`.
   L'un ou l'autre contrôle actif garde LArRE alimenté; tous les contrôles
   présents désactivés l'éteignent.

Le système utilise la valeur de slot `Seeding` pour éviter de récolter trop tôt.
`Seeding` doit être supérieur à `0` avant que LArRE récolte la plante, donc il
attend que les graines soient prêtes avant de prendre la culture.

## Options

Modifiez ces valeurs directement dans les scripts:

| Option | Script | Défaut | Comportement |
| --- | --- | --- | --- |
| `LARRE_NAME` | `LARRE_DRIVER.ic10` | `HASH("LArRE")` | Étiquette en jeu du LArRE Dock (Hydroponics). |
| `LARRE_NAME` | `LARRE_POWER_LEVER.ic10` | `HASH("LArRE")` | Étiquette en jeu du LArRE Dock (Hydroponics). |
| `SWITCH_NAME` | `LARRE_POWER_LEVER.ic10` | `HASH("LArRE_SWITCH")` | Étiquette partagée par le Big Lever ou Flip Cover Switch de puissance. |
| `FIRST_GROW_STATION` | `LARRE_BRAIN.ic10` | `0` | Premier index de station de plateau de culture à visiter. |
| `LAST_GROW_STATION` | `LARRE_BRAIN.ic10` | `15` | Dernier index de station de plateau de culture à visiter. |
| `SEED_IMPORT_STATION` | `LARRE_BRAIN.ic10` | `16` | Station avec le Chute Export Bin où LArRE prend les graines à planter. |
| `SEED_EXPORT_STATION` | `LARRE_BRAIN.ic10` | `17` | Station avec le Chute Import Bin où LArRE dépose les graines récoltées. |
| `CROPS_EXPORT_STATION` | `LARRE_BRAIN.ic10` | `18` | Station avec le Chute Import Bin où LArRE dépose les récoltes et plantes mortes. |
| `ACTION_SETTLE_SECONDS` | `LARRE_DRIVER.ic10` | `2` | Délai après une action de pince avant de revérifier l'état idle. |
| `LOOP_PAUSE_SECONDS` | `LARRE_BRAIN.ic10` | `10` | Délai entre les boucles de patrouille. |
| `SEED_EXPORT_BIN` | `LARRE_EXPORT_BIN.ic10` | `HASH("SEED_EXPORT_BIN")` | Étiquette du Chute Import Bin pour les graines récoltées. |
| `CROP_EXPORT_BIN` | `LARRE_EXPORT_BIN.ic10` | `HASH("CROP_EXPORT_BIN")` | Étiquette du Chute Import Bin pour les récoltes et plantes mortes. |
| `SEED_SUPPLYER` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("SEED_SUPPLYER")` | Étiquette du Chute Export Bin contrôlé par les boutons START et STOP. |
| `START_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("START")` | Étiquette du bouton pour mettre `On` du seed supply export bin à `1`. |
| `STOP_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("STOP")` | Étiquette du bouton pour mettre `On` du seed supply export bin à `0`. |
| `MANUAL_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("MANUAL")` | Étiquette du bouton manuel pour le pulse de vidage des stackers. |
| `AUTO_BUTTON` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("AUTO")` | Étiquette du bouton pour le mode automatique de vidage des stackers. |
| `VIDER_DIODE` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("Vider")` | Label diode du mode auto. |
| `EMPILEUR_DIODE` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("Empileurs")` | Label diode du mode auto. |
| `PLANTER_DIODE` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `HASH("Planter")` | Label diode de l'état de `SEED_SUPPLYER`. |
| `BLUE`, `GREEN`, `RED`, `YELLOW` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `0`, `2`, `4`, `5` | Valeurs de couleur data-network utilisées par les label diodes. |
| `AUTO_INTERVAL_SECONDS` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `300` | Délai entre les vidages automatiques pendant que le mode auto est actif. |
| `STACKER_CLEAR_SECONDS` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `1` | Durée du pulse actif pour vider les stackers. |
| `POLL_SECONDS` | `LARRE_CHUTE_STACKER_CONTROL.ic10` | `0.25` | Intervalle de lecture des boutons. |

## Fichiers

- `LARRE_BRAIN.ic10` - IC de décision et de patrouille.
- `LARRE_DRIVER.ic10` - IC de mouvement/action LArRE.
- `LARRE_EXPORT_BIN.ic10` - IC de contrôle des chute import bins graines/cultures.
- `LARRE_CHUTE_STACKER_CONTROL.ic10` - IC aide START et STOP pour le seed supply export bin et MANUAL/AUTO pour les stackers.
- `LARRE_POWER_LEVER.ic10` - IC aide Big Lever ou Flip Cover Switch vers puissance du LArRE Dock.
- `README.md` - version anglaise originale de ce README.
