---
name: document-ultrarain
description: "Erstelle und erweitere die erforderlichen ULTRARAIN-Projektunterlagen für den Lehrlingswettbewerb und die Berufsbildner: professionelle Projektdokumentation nach IPERKA, automatisch wiederholte PowerPoint am Stand und bei ausreichender Zeit eine Website. Nutze den Skill für Kapitelentwürfe, Interviews, rückblickende Rekonstruktion, Präsentationsplanung und schrittweise Überarbeitung. Stelle viele gezielte Fragen, prüfe GitHub-Belege und bewahre bestätigte Inhalte über mehrere Sitzungen. Nicht für allgemeine Spielentwicklung oder reine Codefehlerbehebung verwenden."
---

# ULTRARAIN dokumentieren

## Grundlage laden

- Lies [references/projektkontext.md](references/projektkontext.md) für bestätigte Vorgaben, Quellen und offene Anforderungen.
- Lies [references/interview.md](references/interview.md), bevor du eine neue IPERKA-Phase oder ein anderes Ausgabeformat bearbeitest. Wähle passende Fragen und ergänze konkrete Rückfragen.
- Arbeite innerhalb von `team-one-chance/ultrarain`. Behalte diesen Skill projektspezifisch; installiere ihn nicht zusätzlich als persönliche, projektübergreifende Kopie.
- Lies vorhandene Projektanweisungen, aktuelle Unterlagen und einen vorhandenen Dokumentationsstand zuerst. Behandle tägliche Arbeitsberichte als Quellen für die Gesamtdokumentation, nicht als deren Gliederung.
- Nutze vollständige frühere Dokumentationen und Präsentationen als Struktur-, Umfangs- und Gestaltungsreferenzen, sobald sie bereitgestellt werden. Übernimm keine fremden Projektfakten, Leistungen oder Reflexionen.
- Kläre, welches Dokument, Kapitel und welcher Zeitraum jetzt bearbeitet werden sollen. Frage nur nach tatsächlich fehlenden Angaben; nutze frühere Antworten weiter.

## Gründlich interviewen

1. Ermittle vor dem Schreiben die Informationslücken des gewählten Abschnitts. Unterscheide Anforderungen, Sachverhalte, persönliche Beweggründe und offene Entscheidungen.
2. Stelle nummerierte, konkrete Fragen in thematischen Runden. Verwende so viele Fragen wie der Abschnitt benötigt; setze keine starre Obergrenze. Teile grosse Interviews in verständliche Gruppen und ermögliche kurze Antworten nach Nummer.
3. Frage besonders gründlich zu **Informieren, Planen und Entscheiden**. Leite damalige Ziele, Alternativen, Motive, Rollen und Entscheidungen niemals allein aus Code oder heutigen Ergebnissen ab.
4. Frage offen, bevor du mögliche Erklärungen als Erinnerungshilfe anbietest. Kennzeichne diese als Vorschläge, ohne eine Antwort vorzugeben.
5. Warte auf Antworten, bevor du davon abhängige Aussagen ausformulierst. Bearbeite belegte, unabhängige Teile weiter. Erzeuge bei fehlenden Antworten keine scheinbar vollständige Geschichte.
6. Frage nach einzelnen Entwicklern, wenn der Text ihre konkrete Arbeit, Entscheidung oder Erfahrung zuschreibt. Verlange nicht bei jedem allgemeinen Teamabschnitt drei getrennte Interviews.
7. Lege Widersprüche zwischen Antworten, Quellen und früheren Angaben konkret vor und frage nach. Löse sie nicht stillschweigend durch Auswahl einer vermeintlich richtigen Quelle.
8. Frage bei vagen Antworten nach: Was wurde geändert? Warum? Wie wurde es geprüft? Was war das Ergebnis? Was blieb offen?

## Belege und Rekonstruktion trennen

- Nutze verfügbare GitHub-Werkzeuge für Commits, Issues, Pull Requests und Dateiinhalte. Prüfe bei neuen Sitzungen den aktuellen Stand und seit dem letzten belegten Stand relevante Änderungen.
- Grenze Abfragen nach Kapitel, Funktion, Zeitraum und Repository ein. Blättere bei Bedarf weiter; gib einen Ausschnitt nicht als vollständige Historie aus. Lies passende Diffs und Diskussionen statt nur Commit-Titel.
- Prüfe Branch und Merge-Stand: Ein Issue ist keine Umsetzung, ein offener PR keine Integration, Code allein kein erfolgreicher Laufzeittest. Unterscheide geplant, begonnen, implementiert, getestet, verworfen und offen.
- Behandle Commit-Zeitpunkte nicht als sichere Arbeitstage oder Arbeitsstunden. Setze Autor, Committer und tatsächlichen Bearbeiter nicht automatisch gleich. Frage bei relevanten Zuordnungen nach Pair-Arbeit und verspäteten Commits.
- Führe bei umfangreicher Arbeit eine kompakte Zuordnung von Aussage, Quelle, Zeitraum und Status: **belegt**, **vom Nutzer bestätigt**, **vorgeschlagene Rekonstruktion**, **offen**. Halte Quellen bei Bedarf im Arbeitsstand oder Anhang statt jeden Absatz zu überladen.
- Hilf bei Erinnerungslücken und spontanen Entscheidungen mit plausiblen Formulierungsvorschlägen. Frage, ob sie die damalige Situation treffen. Übernimm sie erst nach Bestätigung als rückblickende Erklärung.
- Unterscheide damalige Motivation von heutiger Bewertung. Beschreibe eine intuitive Entscheidung als solche und ihre spätere Begründung getrennt. Erfinde keine damalige Nutzwertanalyse oder formelle Sitzung.
- Erfinde keine Arbeitszeiten, genauen Daten, Testresultate, Rückmeldungen, Wettbewerbsregeln, Quellen, Lizenzen oder individuellen Beiträge. Halte unbestätigte Ursachen als Vermutung fest. Verwende bestätigte allgemeinere Aussagen, wenn Details fehlen.
- Nutze ältere Gespräche und Erinnerungen als Recherchehinweise, nicht als Beweis, dass vorgeschlagene Änderungen tatsächlich umgesetzt wurden.

## Gesamtdokumentation strukturieren

Erhalte sechs eigenständige Hauptkapitel in dieser Reihenfolge:

1. **Informieren** – Ausgangslage, Auftrag, Zielgruppe, Recherche, Anforderungen und Kenntnisse.
2. **Planen** – Ziele, MVP, Aufgaben, Rollen, Zeitplanung, Ressourcen, Risiken und Standplanung.
3. **Entscheiden** – tatsächlich erwogene Optionen, Auswahl, Beweggründe und geänderte Entscheidungen.
4. **Realisieren** – konkrete Umsetzung, Eigenleistungen, Werkzeuge, Beispiele und Probleme samt Lösungen.
5. **Kontrollieren** – Anforderungen mit tatsächlichen Tests, Beobachtungen, Feedback und offenen Mängeln vergleichen.
6. **Auswerten** – Zielerreichung, Zusammenarbeit, Lernerfahrungen, Aufwand, Reflexion und weiterer Ausblick.

- Ergänze Einleitung, Projektvorstellung, Inhaltsverzeichnis, Quellen und Anhang nach Anforderungen und Beispielen. Halte die sechs IPERKA-Kapitel eigenständig.
- Verwende das Beispielinhaltsverzeichnis als Orientierung, nicht als bestätigte aktuelle Wettbewerbsvorschrift. Kläre verlangte Bezeichnungen und Unterkapitel anhand der Vorgaben.
- Stelle IPERKA als Arbeitsmethode dar, ohne eine perfekte lineare Entwicklung vorzutäuschen. Unterscheide ursprüngliche Planung, spätere Anpassungen und aktuellen Stand.
- Schreibe professionelles, verständliches Schweizer Hochdeutsch aus studentischer Perspektive: `ss` statt `ß`, echte Umlaute, deutsche Überschriften. Behalte Eigennamen, Codebezeichner und Quellenbezeichnungen unverändert.
- Nutze grundsätzlich Wir für Teamarbeit, Namen für konkrete Einzelbeiträge und Ich nur für eine zugeordnete persönliche Reflexion. Passe dies an Beispiele und Nutzerwünsche an.
- Formuliere konkret und fachlich, ohne Werbung, künstlich formelle Sprache oder erfundene Sicherheit. Erkläre technische Begriffe nur soweit Leser sie brauchen.

## Schrittweise erweitern

- Baue frühe Versionen als erweiterbare Grundlage. Schreibe nur die aktuell bearbeiteten Abschnitte fertig; kennzeichne andere im Arbeitsstand als offen. Behaupte keinen Projektabschluss.
- Erhalte bestätigte Passagen und bestehende Gestaltung. Ändere gezielt bei neuen Fakten oder Nutzerkorrekturen statt jedes Mal alles neu zu schreiben.
- Halte bei mehrteiliger Dateiarbeit einen Begleitstand unter `docs/dokumentation/arbeitsstand.md`, sofern kein entsprechender Stand existiert: Dokumentpfade, Kapitelstatus, bestätigte Antworten, offene Fragen, vorgeschlagene Rekonstruktionen und letzter geprüfter Repository-Stand samt Datum/Branch/SHA.
- Speichere den Begleitstand, wenn Dokumentdateien bearbeitet werden sollen; liefere bei reinen Textentwürfen eine kompakte Übergabenotiz. Lege tägliche Berichte nicht als zusätzliche Pflicht fest.
- Lade beim Fortsetzen den Begleitstand und die aktuellen Dokumente. Frage nur bei neuen Lücken oder Konflikten erneut.
- Präsentiere konkrete Kapitelentwürfe und verbleibende Fragen. Halte offene Punkte möglichst ausserhalb des fertigen Fliesstexts. Markiere unvermeidbare Platzhalter deutlich und melde sie vor endgültiger Abgabe.
- Bearbeite Dateien, wenn der Nutzer dies verlangt oder der laufende Auftrag es umfasst. Gib bei einer Bitte um Text nur Text aus. Erhalte bei vorhandenen Dokumenten ihre Identität und Versionierung.

## PowerPoint und Website

- Leite beide aus denselben bestätigten Projektangaben ab. Erzeuge keine widersprüchlichen Funktions-, Termin- oder Abschlussbehauptungen.
- Erstelle für den Stand eine selbstständig verständliche, automatisch gestartete und endlos wiederholte PowerPoint. Plane lesbare Folien ohne Vortrag; frage nach Anzeigeformat, Abstand, Gesamtdauer, Folienwechseln und Ton/Video.
- Prüfe bei Präsentationsdateien automatische Übergänge, Endlosschleife und Medienverhalten soweit die Werkzeuge dies erlauben. Melde nicht überprüfte Wiedergabe und lasse auf dem Standgerät testen. Erfinde keine Standarddauer als Nutzeranforderung.
- Übertrage nicht automatisch die gesamte Dokumentation oder sechs lange Kapitel auf Folien. Kläre Präsentationsvorgaben und verdichte Projektidee, Team, Entwicklung, Gameplay, Ergebnisse und Lernen entsprechend.
- Behandle die Website als optional und zeitabhängig. Kläre Inhalt, Zweck und Veröffentlichung vor dem Bau. Nutze bei Website-Arbeit die verfügbaren Sites-Skills und respektiere die gewünschte Sichtbarkeit.

## Vor Übergaben prüfen

- Prüfe Fakten, Personen, Zeiträume, Status, Quellen und die Trennung damaliger Absichten von heutiger Reflexion.
- Prüfe bei Gesamtdokumentationen alle sechs IPERKA-Kapitel; prüfe bei Kapitelaufträgen nur den gewählten Abschnitt und seine Konsistenz mit dem Rest.
- Prüfe deutsche Sprache, Benennungen, Querverweise und Übereinstimmung der Ausgabeformate.
- Melde offene Belege und Anforderungen knapp. Frage nach fehlenden Erfahrungen oder Entscheidungen, statt sie durch flüssige Formulierungen zu verstecken.
- Reiche nichts beim Wettbewerb ein, verschicke nichts an Berufsbildner und veröffentliche nichts allein aufgrund dieses Dokumentationsauftrags.
