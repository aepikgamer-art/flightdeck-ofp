# FlightDeck

A compact iPhone companion for your latest SimBrief Operational Flight Plan. It puts the flight, aircraft, V1/VR/V2, and route up front, with useful dispatch details one tap away.

## Features
- Fetch the latest SimBrief OFP by username or Pilot ID. No SimBrief password is requested or stored.
- Liquid Glass styling on modern iOS, with a material fallback on older versions.`n- Route formatting starts with departure airport/runway and SID, then shows the enroute route and arrival procedure/runway.`n- Summary, route, and details tabs for aircraft/registration, airports, takeoff speeds, altitude, distance, fuel, weights, and timing.
- JetPhotos registration search for real-world aircraft photos.
- AltStore source manifest and [AltDirect](https://altdirect.app/?url=https://raw.githubusercontent.com/aepikgamer-art/flightdeck-ofp/main/altstore-source.json) link.

## Install
1. Open **Actions → Build iOS IPA → Run workflow** to build an unsigned device IPA.
2. Download the `FlightDeck-IPA` artifact from the completed run.
3. Install it with AltStore Classic, SideStore, or another compatible sideloader. The IPA is unsigned; the sideloader signs it with your Apple ID.
4. Add this source to a compatible sideloader using the AltDirect link above.

To publish a release automatically, push a tag such as `v1.0.2`. The workflow attaches the IPA to a GitHub release, which the AltStore source points to.

## Build locally on macOS
Install Xcode and XcodeGen, then run `xcodegen generate` and build the `FlightDeck` scheme.

## Data sources
- SimBrief public OFP fetcher: `https://www.simbrief.com/api/xml.fetcher.php` (JSON v2)
- JetPhotos registration search pages for aircraft photos

Flight information is fetched directly on your device. The saved SimBrief username is stored locally in the app's preferences.



