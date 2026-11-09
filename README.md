# ULTRARAIN

ULTRARAIN ist ein schneller 2D-Sidescroller-Shooter von **Team One Chance**, entwickelt mit GameMaker. Im Mittelpunkt stehen Bewegung, präzises Zielen und das Kombinieren von Pistole, Münzabprallern, Schwert und Slam.

## Spielen

Die aktuelle veröffentlichte Demo ist **v0.2.0**. Unter [Releases](https://github.com/team-one-chance/ultrarain/releases/tag/v0.2.0) stehen fertige Builds für beide Plattformen bereit:

| Plattform | Download |
| --- | --- |
| Windows x64 | `ULTRARAIN_x64_win.zip` |
| Linux x64 | `ULTRARAIN_x64_linux.AppImage` |

Unter Windows das ZIP vollständig entpacken und die enthaltene Anwendung starten. Unter Linux die AppImage ausführbar machen und starten. Für diese Builds wird GameMaker nicht benötigt.

Im Hauptmenü startet **TRAINING SIMULATION** einen separaten Übungsparcours. Bewegung und Waffen werden dort schrittweise freigeschaltet; der Spieler beginnt ohne Bewaffnung. **Start** führt über die Schwierigkeitswahl und Boot-Sequenz in die eigentliche Demo.

## Aktueller Stand

Die Demo umfasst einen industriellen Levelbereich mit Kämpfen, Umgebungsgefahren, Zugfahrt und einem angebundenen Nebenbereich. Dazu kommen die Trainingssimulation, Haupt- und Pausenmenü, Einstellungen und frei belegbare Spielaktionen. Die reguläre Schwierigkeitswahl bietet **Easy**, **Normal** und **Hard**; ein zusätzlicher Modus ist zunächst verborgen.

Implementiert sind unter anderem:

- **Bewegung:** Sprünge, Walljumps, Wandslide, automatisches Hochziehen an Kanten, Slide, Dash und Slam mit Flächenschaden
- **Kampf:** mausgesteuerte Hitscan-Pistole, Münzwurf mit Abpralltreffern und Splitshots, Schwertangriffe und Schwertwellen sowie zeitlich abgestimmtes Parieren
- **Gegner:** Scout und Mini-Scout, bewaffnete Drohnen, der Schild-Miniboss Breaker und Chip-Roboter mit unterschiedlichen Effekten
- **Umgebung:** zerstörbare Türen und Hindernisse, Türsteuerungen mit Kabelrätsel, versteckte Bereiche, stromführende Kabel, Lava und Zerkleinerer
- **Ausrüstung und Heilung:** Pinhouse zum Fixieren einer Münze sowie aufhebbare Medkits mit verbrauchbaren Spritzen
- **Darstellung und Ton:** zusammengesetztes Spieler-Modell mit zielabhängiger Arm- und Waffenhaltung, Raumbeleuchtung, Parallax-Hintergründe sowie Kampf-, Bewegungs- und Umgebungsgeräusche
- **Entwicklungswerkzeuge:** Menü für Spielertests, Gegnerspawns, Kollisionen, Zeitsteuerung und weitere Debug-Funktionen

Die Demo wird weiterentwickelt. Einige Ressourcen tragen noch Arbeitsnamen; vorhandene Mechaniken und ihre Abstimmung können sich ändern.

## Steuerung

Die Tabelle zeigt die Standardbelegung. Unter **Settings → Controls** im Haupt- oder Pausenmenü lassen sich Spielaktionen auf Tastatur- und Maustasten umbelegen. Die Belegung wird gespeichert. Im Training werden Aktionen erst im jeweiligen Abschnitt freigeschaltet.

| Eingabe | Aktion |
| --- | --- |
| `A` / `D` oder Pfeiltasten links/rechts | Bewegen |
| `W`, Pfeiltaste hoch oder Leertaste | Springen / Walljump |
| `Strg` beim Laufen | Sliden |
| `Shift` | Dash |
| `S` oder Pfeiltaste runter in der Luft | Slam |
| Maus | Zielen |
| Linke Maustaste | Mit der ausgerüsteten Waffe angreifen |
| Rechte Maustaste | Mit der Pistole eine Münze werfen / mit dem Schwert parieren |
| `1` / `2` | Pistole / Schwert ausrüsten |
| Mittlere Maustaste | Mit Pinhouse eine Münze fixieren, sofern verfügbar |
| `Q` | Spritze zur Heilung verwenden, sofern verfügbar |
| `E` | Mit Türsteuerungen und Terminals interagieren |
| `Esc` | Pausenmenü öffnen / Interaktion verlassen |
| `F11` | Vollbild umschalten |

An passenden Kanten zieht sich der Spieler automatisch hoch. Mit `W` und einer Bewegungsrichtung lässt sich daran ein weiterer Sprung anschliessen. Die Pfeiltasten bleiben als alternative Bewegungs-, Sprung- und Slam-Eingaben verfügbar, solange sie keiner anderen Aktion zugewiesen sind.

Münzen lassen sich mit der Pistole treffen, um Schüsse umzulenken. Beim Parieren zählen das Timing und die Angriffsart: Nicht jeder Angriff lässt sich vollständig abwehren. Die optionale Heilung mit beiden Maustasten kann in den Einstellungen aktiviert werden; standardmässig wird mit `Q` geheilt.

## Projekt starten

1. Repository klonen.
2. `ULTRA RAIN.yyp` in GameMaker öffnen.
3. Das Projekt über die GameMaker-IDE starten.
4. Im Hauptmenü die Trainingssimulation oder **Start** wählen; bei **Start** die Schwierigkeit auswählen und den Eingabeaufforderungen der Boot-Sequenz folgen.

Das Projekt wurde mit GameMaker IDE **2026.0.0.16** gespeichert. Bei Problemen mit einer anderen Version zuerst die Projektkompatibilität prüfen.

### Räume

| Ressource | Zweck |
| --- | --- |
| `LE_MENU` | Hauptmenü, Einstellungen, Schwierigkeitswahl und Boot-Sequenz; erster Raum des Projekts |
| `r_preTutorial` | Separate Trainingssimulation mit schrittweiser Freischaltung von Bewegung und Waffen |
| `LE_TUTORIAL_WIP` | Hauptbereich der Demo mit Bewegung, Kämpfen, Gefahren und Zugfahrt |
| `LE_PWR` | Angebundener Nebenbereich mit Türsteuerung |
| `LE_TRAIN` | Separater Zugraum |
| `LE_DEMO_END` | Separater Demo-Endraum |
| `TESTING` | Entwicklungs- und Testraum |

### Entwicklung und Debugging

Im Spiel öffnet **F1** das Entwicklungsmenü. Dort lassen sich unter anderem Gesundheit und Münzen auffüllen, Waffen auswählen, Gegner erzeugen und Testpositionen ansteuern. **F2** schaltet die Kollisionsanzeige um, **F4** pausiert die Simulation und **F5** führt einen einzelnen Simulationsschritt aus. **F6** schaltet die freie Kamera um. Die Werkzeuge können im Ausstellungsmodus gesperrt sein.

Weitere Hinweise stehen in [docs/dev-menu.md](docs/dev-menu.md). Der Leitfaden beschreibt noch nicht alle neueren Funktionen; das aktuelle Entwicklungsmenü enthält zusätzlich eine Levelkarte, weitere Gegnerspawns und Zeitsteuerung.

## Projektstruktur

| Pfad | Inhalt |
| --- | --- |
| `objects/` | Spieler, Gegner, Gefahren, Interaktionen, Raumsteuerung und Effekte |
| `scripts/` | Unter anderem Spieler-Rig, Hitscan, Münzabpraller, Slam, Chip-System, Raumübergänge, Eingabebelegung und Trainingsablauf |
| `sprites/` | Spieleranimationen, Waffen, Gegner, Umgebung und Effekte |
| `rooms/` | Demo-, Menü- und Testräume |
| `tilesets/` | Tilesets für Level und Hintergründe |
| `sounds/` und `fonts/` | Audio und Schriften |
| `shaders/` | Beleuchtung und weitere visuelle Effekte |
| `options/` | GameMaker-Projektoptionen |
| `docs/` | Projektdokumentation, MVP, Entwicklungsnotizen und Asset-Werkzeuge |

Aufgaben, Bugs und Ideen werden über [GitHub Issues](https://github.com/team-one-chance/ultrarain/issues) und das Project Board verwaltet.

## Weitere Entwicklung

Weitere Waffen, waffenspezifische Aufsätze und Körper-Items sollen unterschiedliche Builds ermöglichen. Zusätzliche Stages, Gegner und Bosse gehören ebenfalls zur weiteren Planung. Diese Erweiterungen sind nicht als vollständig umgesetzte Systeme der aktuellen Demo zu verstehen.

## Team

ULTRARAIN wird von **Team One Chance** entwickelt.
