# Cycle d'eclairage de culture

Script IC10 Stationeers pour cycler des lampes de culture et des stations
hydroponiques avec une minuterie simple et repetitive.

## Objectif

`GROW_LIGHT.ic10` controle tous les appareils `StructureGrowLight` nommes
`Grow Light` et tous les appareils `StructureHydroponicsStation` nommes
`Hydroponic Station` sur le reseau de donnees. Au demarrage de l'IC, le script
allume les deux groupes d'appareils avant d'entrer dans le cycle minute. Le
cycle les garde allumes pendant 14 minutes, les eteint pendant 6 minutes, puis
recommence sans fin.

## Etiquettes requises

Toutes les etiquettes sont sensibles a la casse. Le nom dans `HASH("name")`
doit correspondre exactement a l'etiquette du device en jeu.

| Etiquette | Device |
| --- | --- |
| `Grow Light` | Une ou plusieurs lampes de culture a cycler ensemble. |
| `Hydroponic Station` | Une ou plusieurs stations hydroponiques a cycler avec les lampes. |

## Comportement

Le script:

1. Allume les lampes `Grow Light` et les stations hydroponiques
   `Hydroponic Station` au demarrage de l'IC.
2. Attend 840 secondes, soit 14 minutes.
3. Eteint les deux groupes d'appareils.
4. Attend 360 secondes, soit 6 minutes.
5. Rallume les deux groupes d'appareils et repete le cycle.

## Parametres

Modifiez ces valeurs directement dans `GROW_LIGHT.ic10`:

| Option | Valeur par defaut | Comportement |
| --- | --- | --- |
| `Grow Light` | etiquette | Etiquette en jeu des lampes de culture controlees par le script. |
| `Hydroponic Station` | etiquette | Etiquette en jeu des stations hydroponiques controlees par le script. |
| duree allumee | `840` secondes | Temps pendant lequel les appareils restent allumes. |
| duree eteinte | `360` secondes | Temps pendant lequel les appareils restent eteints. |

## Fichiers

- `GROW_LIGHT.ic10` - version par nom/hash pour les groupes de lampes de
  culture et de stations hydroponiques.
- `README.md` - version anglaise de cette documentation.
