.PHONY: get clean web android build deploy redeploy devices

get:
	flutter pub get

clean:
	flutter clean

devices:
	flutter devices

web:
	flutter run -d chrome

android:
	flutter run -d emulator-5554

build:
	flutter build web

deploy:
	firebase deploy --only hosting

redeploy:
	flutter build web
	firebase deploy --only hosting