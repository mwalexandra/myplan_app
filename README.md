# MyPlan App

MyPlan App ist ein responsiver Kinder-Tageskalender als Flutter-Anwendung für Web und Android. Die App visualisiert den Tagesablauf als farbige Timeline („Farb-Balken“), damit ein Kind kommende Aktivitäten leichter verstehen kann.

## Projektziel

Ziel des Projekts ist es, den Tagesablauf eines Kindes einfach und visuell darzustellen. Langfristig soll ein Elternteil Termine auf einem Gerät verwalten können, während das Kind den Plan auf einem anderen Gerät sieht; in der aktuellen Version steht jedoch die Demonstration des Kalenders und der grundlegenden Planungslogik im Mittelpunkt.

## Aktueller Stand

Die aktuelle Version ist ein MVP_2 zur Demonstration der Grundidee. Der Fokus liegt auf einem einzelnen Kalender ohne Rollenmodell, ohne Login und ohne Familienverwaltung.

Bereits umgesetzt sind laut Storyboard die folgende Funktionen. Geplante Funktionen sind für die nächste Ausbaustufe vor dem Release vorgesehen.

## Verfügbare Funktionen

- Tagesansicht als farbige Timeline / „Farb-Balken“.
- Darstellung von Kategorien über Farben.
- Startscreen mit Kalenderbezug bzw. Tagesansicht als zentrale Benutzeroberfläche.
- Auswahl von Kategorien.
- Anlegen neuer Kategorien mit Name und Farbe.
- Bearbeiten von Kategorien.
- Löschen von Kategorien.
- Ereignis-Erstellung.
- Laden der Kalenderdaten aus der Cloud.

## Geplante Funktionen

Die folgenden Punkte sind bereits konzipiert, aber noch nicht vollständig Bestandteil der aktuellen Version:

- Ereignis-Bearbeitung.
- Löschen von Ereignisen. 
- Monatskalender mit Tagesauswahl.
- Ereignisdetails und „Nächstes Ereignis“-Ansicht.
- Erinnerungen für Termine.
- Synchronisation über mehrere Rollen bzw. Familienmitglieder.
- Rollenmodell Eltern/Kind und Benutzerkonten.
- Erweiterte Validierung, Verlauf und Offline-/Sync-Hinweise.

## Technologien

- Flutter für die plattformübergreifende Benutzeroberfläche.
- Firebase Firestore für die Cloud-Datenhaltung.
- Firebase Hosting für die Bereitstellung der Web-Version.

## Aktuelle Einschränkungen

- Es gibt aktuell keinen Login und keine Benutzerrollen.
- Es gibt keine Testdaten in der Datenbank; nach dem ersten Öffnen kann die Ansicht daher leer sein.
- Standardmäßig sind derzeit zwei Kategorien vorhanden.
- Die App stellt vor allem die Grundidee und den aktuellen Entwicklungsstand dar, nicht den vollständigen Endausbau.

## Projekt aufrufen

Web-Version:  
https://myplan-eb9ec.web.app

GitHub-Repository:  
https://github.com/mwalexandra/myplan_app

## Lokales Starten

### Web
```bash
flutter pub get
flutter run -d chrome
```

### Android Emulator
```bash
flutter pub get
flutter run -d emulator-5554
```

### Web-Build
```bash
flutter build web
```

## Deployment

Für ein erneutes Deployment der Web-Version wird die Anwendung zuerst für Web gebaut und anschließend zu Firebase Hosting veröffentlicht.

```bash
flutter build web
firebase deploy --only hosting
```