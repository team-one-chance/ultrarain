# ULTRARAIN

ULTRARAIN ist ein schneller 2D-Sidescroller-Shooter, der mit GameMaker entwickelt wird. Bewegung und Kampf stehen im Mittelpunkt: Der Spieler weicht Gegnern aus, zielt mit der Maus und kombiniert später Waffen, Aufsätze und Körper-Items zu unterschiedlichen Builds.

## Aktueller Stand

Das Projekt ist ein spielbarer Prototyp mit einem Testraum (`Room1`). Bereits im Projekt vorhanden sind:

- Bewegung mit Sprung, Walljump, Wandslide, automatischem Hochziehen an Kanten, Slide, Dash und Slam
- Mausgesteuerte Pistole mit gelbem Hitscan-Effekt; Schüsse starten an der Mündung des gezeichneten Modells
- Münzwurf als alternative Pistolenaktion mit Abpralltreffern
- Nahkampfangriff und Gegner mit Verfolgungs- und Angriffsverhalten
- Ein aus Kopf, Armen, Körper und Waffe zusammengesetztes Spieler-Modell: Der Körper folgt der Bewegung, Kopf und Waffe folgen dem Ziel
- Ein Testraum mit Tiles und separaten Kollisionsobjekten

Einige Assets und Gegner tragen noch temporäre Namen. Der Prototyp wird laufend verändert; einzelne Mechaniken können sich daher noch ändern.

## Steuerung

| Eingabe | Aktion |
| --- | --- |
| `A` / `D` oder Pfeiltasten links/rechts | Bewegen |
| `W`, Pfeiltaste hoch oder Leertaste | Springen |
| `Strg` beim Laufen | Sliden |
| `Shift` | Dash |
| `S` oder Pfeiltaste runter in der Luft | Slam |
| Maus | Zielen |
| Linke Maustaste | Pistole abfeuern |
| Rechte Maustaste | Münze werfen |
| `Q` | Nahkampfangriff |

An Wänden sind Walljumps möglich. Beim Bewegen gegen eine passende Kante zieht sich der Spieler automatisch hoch.

## Geplante Richtung

Für den eigentlichen Gameplay-Loop sind mehrere Waffen, waffenspezifische Aufsätze und Körper-Items vorgesehen. Die Ausrüstung soll sich gegenseitig beeinflussen und dadurch verschiedene Builds ermöglichen. Weitere Stages, Gegner, Umgebungselemente sowie Mini- und Endbosse gehören zur längerfristigen Planung. Diese Systeme sind noch kein fertiger Teil des Prototyps.

Die visuelle Richtung ist industriell und kontrastreich: überwiegend Schwarz und Weiss mit gezielten hellen Akzenten, etwa dem Gelb der Schüsse. Klare Silhouetten und einfache Formen halten die Assets lesbar und den Zeichenaufwand überschaubar.

## Projekt starten

1. Repository klonen.
2. `ULTRA RAIN.yyp` in GameMaker öffnen.
3. Das Projekt in der GameMaker-IDE starten.

Das Projekt wurde mit GameMaker IDE `2026.0.0.16` gespeichert. Bei Problemen mit einer anderen Version zuerst die Projektkompatibilität prüfen.

## Projektstruktur

| Pfad | Inhalt |
| --- | --- |
| `objects/` | Spieler, Gegner, Treffer-Effekte und andere Spielobjekte |
| `scripts/` | Unter anderem Aim-Rig, Armzeichnung, Hitscan und Münzabpraller |
| `sprites/` | Spieleranimationen, Waffen, Gegner und Effekte |
| `tilesets/` und `rooms/` | Tilesets und Testraum |
| `options/` | GameMaker-Projektoptionen |

Aufgaben, Bugs und Ideen werden über GitHub Issues und das Project Board verwaltet.

## Team One Chance

ULTRARAIN wird von **Team One Chance** entwickelt.
