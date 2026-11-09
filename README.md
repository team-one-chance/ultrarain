# ULTRARAIN

ULTRARAIN ist ein schneller 2D-Sidescroller-Shooter von **Team One Chance**, entwickelt mit GameMaker. Im Mittelpunkt stehen Bewegung, präzises Zielen und das Kombinieren von Pistole, Münzabprallern, Schwert und Slam.

## Aktueller Stand

Das Projekt enthält eine spielbare Demo mit Boot-Sequenz, Tutorialbereich, Zugfahrt und einem angebundenen Nebenbereich. Der frühere einzelne Testraum ist inzwischen durch mehrere Räume und zusammenhängende Spielabschnitte ergänzt worden.

Implementiert sind unter anderem:

- **Bewegung:** Sprünge, Walljumps, Wandslide, automatisches Hochziehen an Kanten, Slide, Dash und Slam mit Flächenschaden
- **Kampf:** mausgesteuerte Hitscan-Pistole, Münzwurf mit Abpralltreffern und Splitshots sowie Schwertangriffe
- **Gegner:** Bodengegner, fliegende Drohnen, ein Miniboss und Chip-Roboter mit unterschiedlichen Effekten
- **Umgebung:** zerstörbare Türen und Hindernisse, Türsteuerungen mit Kabelrätsel, versteckte Bereiche, stromführende Kabel, Lava und Zerkleinerer
- **Heilung:** aufhebbare Medkits und verbrauchbare Spritzen
- **Darstellung und Ton:** zusammengesetztes Spieler-Modell mit zielabhängiger Arm- und Waffenhaltung, Raumbeleuchtung, Parallax-Hintergründe sowie Kampf-, Bewegungs- und Umgebungsgeräusche
- **Entwicklungswerkzeuge:** Menü für Spielertests, Gegnerspawns, Kollisionen, Zeitsteuerung und weitere Debug-Funktionen

Die Demo wird weiterentwickelt. Einige Ressourcen tragen noch Arbeitsnamen; vorhandene Mechaniken und ihre Abstimmung können sich ändern.

## Steuerung

| Eingabe | Aktion |
| --- | --- |
| `A` / `D` oder Pfeiltasten links/rechts | Bewegen |
| `W`, Pfeiltaste hoch oder Leertaste | Springen / Walljump |
| `Strg` beim Laufen | Sliden |
| `Shift` | Dash |
| `S` oder Pfeiltaste runter in der Luft | Slam |
| Maus | Zielen |
| Linke Maustaste | Mit der ausgerüsteten Waffe angreifen |
| Rechte Maustaste | Münze werfen |
| `1` / `2` | Pistole / Schwert ausrüsten |
| `Q` | Spritze zur Heilung verwenden, sofern verfügbar |
| `E` | Mit Türsteuerungen und Terminals interagieren |
| `Esc` | Kabelrätsel oder Terminal verlassen |
| `F11` | Vollbild umschalten |

An passenden Kanten zieht sich der Spieler automatisch hoch. Mit `W` und einer Bewegungsrichtung lässt sich daran ein weiterer Sprung anschliessen. Münzen lassen sich mit der Pistole treffen, um Schüsse umzulenken.

## Projekt starten

1. Repository klonen.
2. `ULTRA RAIN.yyp` in GameMaker öffnen.
3. Das Projekt über die GameMaker-IDE starten.
4. In der Boot-Sequenz den Eingabeaufforderungen folgen und mit `Enter` bestätigen.

Das Projekt wurde mit GameMaker IDE **2026.0.0.16** gespeichert. Bei Problemen mit einer anderen Version zuerst die Projektkompatibilität prüfen.

### Räume

| Ressource | Zweck |
| --- | --- |
| `LE_MENU` | Start- und Boot-Sequenz; erster Raum des Projekts |
| `LE_TUTORIAL_WIP` | Hauptbereich der Demo mit Bewegung, Kämpfen, Gefahren und Zugfahrt |
| `LE_PWR` | Angebundener Nebenbereich mit Türsteuerung |
| `LE_TRAIN` | Separater Zugraum |
| `LE_DEMO_END` | Separater Demo-Endraum |
| `TESTING` | Entwicklungs- und Testraum |

### Entwicklung und Debugging

Im Spiel öffnet **F1** das Entwicklungsmenü. Dort lassen sich unter anderem Gesundheit und Münzen auffüllen, Waffen auswählen, Gegner erzeugen und Testpositionen ansteuern. **F2** schaltet die Kollisionsanzeige um, **F4** pausiert die Simulation und **F5** führt einen einzelnen Simulationsschritt aus.

Bedienung, Funktionen und Hinweise zur Konfiguration stehen in [docs/dev-menu.md](docs/dev-menu.md).

## Projektstruktur

| Pfad | Inhalt |
| --- | --- |
| `objects/` | Spieler, Gegner, Gefahren, Interaktionen, Raumsteuerung und Effekte |
| `scripts/` | Unter anderem Spieler-Rig, Hitscan, Münzabpraller, Slam, Chip-System und Raumübergänge |
| `sprites/` | Spieleranimationen, Waffen, Gegner, Umgebung und Effekte |
| `rooms/` | Demo-, Menü- und Testräume |
| `tilesets/` | Tilesets für Level und Hintergründe |
| `sounds/` und `fonts/` | Audio und Schriften |
| `options/` | GameMaker-Projektoptionen |
| `docs/` | Projektdokumentation, MVP, Entwicklungsnotizen und Asset-Werkzeuge |

Aufgaben, Bugs und Ideen werden über [GitHub Issues](https://github.com/team-one-chance/ultrarain/issues) und das Project Board verwaltet.

## Weitere Entwicklung

Weitere Waffen, waffenspezifische Aufsätze und Körper-Items sollen unterschiedliche Builds ermöglichen. Zusätzliche Stages, Gegner und Bosse gehören ebenfalls zur weiteren Planung. Diese Erweiterungen sind nicht als vollständig umgesetzte Systeme der aktuellen Demo zu verstehen.

## Team

ULTRARAIN wird von **Team One Chance** entwickelt.
