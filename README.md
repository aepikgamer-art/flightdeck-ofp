# FlightDeck

A compact iPhone companion for your latest SimBrief Operational Flight Plan. It puts the flight, aircraft, V1/VR/V2, and route up front, with useful dispatch details one tap away.

<p align="center">
  <a href="https://altdirect.app/?url=https://raw.githubusercontent.com/aepikgamer-art/flightdeck-ofp/main/altstore-source.json"><img src="https://img.shields.io/badge/ADD%20WITH-ALTDIRECT-6750D8?style=for-the-badge&logo=apple&logoColor=white" alt="Add FlightDeck with AltDirect"></a>
  <a href="https://raw.githubusercontent.com/aepikgamer-art/flightdeck-ofp/main/altstore-source.json"><img src="https://img.shields.io/badge/ALTSTORE-SOURCE-168C72?style=for-the-badge&logo=apple&logoColor=white" alt="Open the AltStore source"></a>
  <a href="https://github.com/aepikgamer-art/flightdeck-ofp/releases/latest/download/FlightDeck.ipa"><img src="https://img.shields.io/badge/DOWNLOAD-LATEST%20IPA-1677C8?style=for-the-badge&logo=apple&logoColor=white" alt="Download the latest IPA"></a>
</p>

<p align="center">
  <a href="https://github.com/aepikgamer-art/flightdeck-ofp/stargazers"><img src="https://img.shields.io/github/stars/aepikgamer-art/flightdeck-ofp?style=for-the-badge&logo=github&logoColor=white&label=stars&color=E3B341" alt="GitHub stars"></a>
  <a href="https://github.com/aepikgamer-art/flightdeck-ofp/commits/main"><img src="https://img.shields.io/github/commit-activity/t/aepikgamer-art/flightdeck-ofp?style=for-the-badge&logo=git&logoColor=white&label=commits&color=5B8DEF" alt="Total commits"></a>
  <a href="https://github.com/aepikgamer-art/flightdeck-ofp/commits/main"><img src="https://img.shields.io/github/last-commit/aepikgamer-art/flightdeck-ofp/main?style=for-the-badge&logo=github&logoColor=white&label=last%20commit&color=8854D0" alt="Last commit"></a>
</p>

## Features
- Fetch the latest SimBrief OFP by username or Pilot ID. No SimBrief password is requested or stored.
- Liquid Glass styling on modern iOS, with a material fallback on older versions.
- Customize accent and button colors, choose a font style, and save named themes on your device.
- Route formatting starts with departure airport/runway and SID, then shows the enroute route and arrival procedure/runway.
- Summary, route, and details tabs for aircraft/registration, airports, takeoff speeds, altitude, distance, fuel, weights, and timing.
- Aircraft details and registration, with a direct link to JetPhotos for aircraft photos.
- AltStore source manifest and [AltDirect](https://altdirect.app/?url=https://raw.githubusercontent.com/aepikgamer-art/flightdeck-ofp/main/altstore-source.json) link.

## Install
1. Open **Actions → Build iOS IPA → Run workflow** to build an unsigned device IPA.
2. Download the `FlightDeck-IPA` artifact from the completed run.
3. Install it with AltStore Classic, SideStore, or another compatible sideloader. The IPA is unsigned; the sideloader signs it with your Apple ID.
4. Add this source to a compatible sideloader using the AltDirect link above.

To publish a release automatically, push a tag such as `v1.0.8`. The workflow attaches the IPA to a GitHub release, which the AltStore source points to.

## Build locally on macOS
Install Xcode and XcodeGen, then run `xcodegen generate` and build the `FlightDeck` scheme.

## Data sources
- SimBrief public OFP fetcher: `https://www.simbrief.com/api/xml.fetcher.php` (JSON v2)
- JetPhotos registration search pages for aircraft photos

Flight information is fetched directly on your device. The saved SimBrief username and appearance settings are stored locally in the app's preferences.

