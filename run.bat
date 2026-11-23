@echo off
rem Starts a local web server for the prebuilt MakeMe app and opens it.
rem Usage: double-click this file (close the window to stop the server)

rem Work from the folder this file is in, then go into the built app
cd /d "%~dp0release\web" || (
  echo release\web not found. Run build_release.ps1 first.
  pause
  exit /b 1
)

echo MakeMe is running at http://localhost:8080 (close this window to stop)
echo If the page says it cannot be reached, wait a second and refresh.

rem Opens the browser. The server starts a moment later.
start http://localhost:8080

rem Uses the Dart server that comes with Flutter, so Python is not needed.
rem The first run installs it (needs internet once).
call dart pub global activate dhttpd
call dart pub global run dhttpd --path . --port 8080