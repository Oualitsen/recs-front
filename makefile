clean:
	fvm flutter clean

build_web:
	fvm flutter pub get
	fvm flutter  pub run build_runner build -d
	fvm flutter  pub run build_runner build -d
	fvm flutter build web --dart-define=URL_BASE=https://manager-control.com --dart-define=WS_URL_BASE=wss://manager-control.com --web-renderer html

copy_build:
	rm -rvf ../ams2/src/main/resources/static/*
	cp -rv build/web/* ../ams2/src/main/resources/static/

build_runner:
	fvm flutter pub get
	fvm flutter pub run build_runner watch -d

