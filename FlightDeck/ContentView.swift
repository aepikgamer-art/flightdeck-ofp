import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var store: FlightPlanStore
    @State private var tab = 0
    var body: some View {
        TabView(selection: $tab) {
            SummaryView().tabItem { Label("Summary", systemImage: "airplane") }.tag(0)
            RouteView().tabItem { Label("Route", systemImage: "point.topleft.down.to.point.bottomright.curvepath") }.tag(1)
            DetailsView().tabItem { Label("Details", systemImage: "list.bullet.rectangle") }.tag(2)
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }.tag(3)
        }.tint(Color.cyan)
    }
}

private struct Screen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    var body: some View {
        NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 18) { content }.padding(20) }.background(Color(red: 0.035, green: 0.075, blue: 0.12)).navigationTitle(title).toolbarColorScheme(.dark) }
    }
}

private struct SummaryView: View {
    @EnvironmentObject var store: FlightPlanStore
    var body: some View {
        Screen("FLIGHT DECK") {
            if let p = store.plan {
                HStack { Text(p.callsign.isEmpty ? "LATEST OFP" : p.callsign.uppercased()).font(.caption.bold()).tracking(2); Spacer(); Button { Task { await store.fetch() } } label: { Image(systemName: "arrow.clockwise") } }.foregroundStyle(.cyan)
                HStack(spacing: 12) { airport(p.origin, p.originName); Image(systemName: "arrow.right").foregroundStyle(.cyan); airport(p.destination, p.destinationName) }
                aircraftCard(p)
                Text("TAKEOFF SPEEDS").font(.caption.bold()).tracking(2).foregroundStyle(.white.opacity(0.65))
                HStack(spacing: 0) { speed("V1", p.v1); speed("VR", p.vr); speed("V2", p.v2) }.padding(.vertical, 18).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
                HStack { metric("CRUISE", p.cruiseAltitude); metric("DISTANCE", p.distance); metric("TIME", p.flightTime) }
                if !p.route.isEmpty { infoCard("ROUTE", p.route) }
            } else { emptyState }
        }
    }
    private func airport(_ code: String, _ name: String) -> some View { VStack(alignment: .leading, spacing: 3) { Text(code.isEmpty ? "----" : code).font(.system(size: 30, weight: .bold, design: .rounded)); Text(name.isEmpty ? "AIRPORT" : name).font(.caption).foregroundStyle(.white.opacity(0.6)).lineLimit(1) }.frame(maxWidth: .infinity, alignment: .leading) }
    private func speed(_ name: String, _ value: String) -> some View { VStack(spacing: 5) { Text(name).font(.caption.bold()).foregroundStyle(.cyan); Text(value.isEmpty ? "—" : value.replacingOccurrences(of: " kt", with: "")).font(.system(size: 27, weight: .semibold, design: .rounded)); Text(value.isEmpty ? "NOT FILED" : "KNOTS").font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.45)) }.frame(maxWidth: .infinity) }
    private func metric(_ label: String, _ value: String) -> some View { VStack(alignment: .leading, spacing: 6) { Text(label).font(.system(size: 10, weight: .bold)).foregroundStyle(.white.opacity(0.5)); Text(value.isEmpty ? "—" : value).font(.subheadline.bold()).lineLimit(1) }.frame(maxWidth: .infinity, alignment: .leading) }
    private func aircraftCard(_ p: FlightPlan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Image(systemName: "airplane").foregroundStyle(.cyan); VStack(alignment: .leading, spacing: 3) { Text(p.aircraft.isEmpty ? "Aircraft not listed" : p.aircraft).font(.headline); Text(p.registration.isEmpty ? "REGISTRATION NOT SET" : p.registration.uppercased()).font(.caption).foregroundStyle(.white.opacity(0.6)) }; Spacer(); if !p.registration.isEmpty { Link(destination: JetPhotos.url(for: p.registration)) { Image(systemName: "photo") } } }.font(.title3)
            if !p.registration.isEmpty { JetPhotosImage(registration: p.registration).frame(height: 150).clipShape(RoundedRectangle(cornerRadius: 12)) }
        }.padding(16).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
    }
    private var emptyState: some View { VStack(spacing: 14) { Image(systemName: "airplane.departure").font(.system(size: 48)).foregroundStyle(.cyan); Text("Your next flight, at a glance").font(.title3.bold()); Text("Connect your SimBrief username to load your latest operational flight plan.").multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.6)); Button { Task { await store.fetch() } } label: { Label("Load Latest OFP", systemImage: "arrow.down.circle.fill").frame(maxWidth: .infinity).padding(14).background(.cyan, in: RoundedRectangle(cornerRadius: 14)).foregroundStyle(.black).fontWeight(.bold) }.disabled(store.isLoading); if store.isLoading { ProgressView("Fetching flight plan…") }; if let error = store.error { Text(error).font(.footnote).foregroundStyle(.orange) }; Text("Set up your username in Settings first.").font(.caption).foregroundStyle(.white.opacity(0.45)) }.frame(maxWidth: .infinity).padding(.top, 80) }
    private func infoCard(_ title: String, _ text: String) -> some View { VStack(alignment: .leading, spacing: 8) { Text(title).font(.caption.bold()).tracking(1.5).foregroundStyle(.cyan); Text(text).font(.subheadline).lineSpacing(4) }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16)) }
}

private struct RouteView: View {
    @EnvironmentObject var store: FlightPlanStore
    var body: some View {
        Screen("ROUTE") {
            if let p = store.plan { Text("\(p.origin)  →  \(p.destination)").font(.title2.bold()); if !p.alternate.isEmpty { Text("ALTERNATE  \(p.alternate)").font(.caption.bold()).foregroundStyle(.cyan) }; Text(p.route.isEmpty ? "No route was included in this OFP." : p.route).font(.system(.body, design: .monospaced)).lineSpacing(7).padding(18).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16)); Button { UIPasteboard.general.string = p.route } label: { Label("Copy route", systemImage: "doc.on.doc") }.buttonStyle(.borderedProminent).tint(.cyan).foregroundStyle(.black) } else { Text("Load an OFP from the Summary tab.").foregroundStyle(.white.opacity(0.6)) }
        }
    }
}

private struct DetailsView: View {
    @EnvironmentObject var store: FlightPlanStore
    var body: some View {
        Screen("OFP DETAILS") {
            if let p = store.plan {
                Text("DISPATCH SNAPSHOT").font(.caption.bold()).tracking(2).foregroundStyle(.cyan)
                detail("Aircraft", p.aircraft); detail("Registration", p.registration); detail("Departure", [p.origin, p.originName].filter { !$0.isEmpty }.joined(separator: " · ")); detail("Arrival", [p.destination, p.destinationName].filter { !$0.isEmpty }.joined(separator: " · ")); detail("Alternate", p.alternate); detail("Cruise altitude", p.cruiseAltitude); detail("Planned distance", p.distance); detail("Estimated time", p.flightTime); detail("Block fuel", p.blockFuel); detail("Estimated takeoff weight", p.takeoffWeight); detail("Departure runway", p.runway)
            } else { Text("Your OFP fuel, weight, and airport details will appear here.").foregroundStyle(.white.opacity(0.6)) }
        }
    }
    private func detail(_ title: String, _ value: String) -> some View { HStack(alignment: .top) { Text(title).foregroundStyle(.white.opacity(0.55)); Spacer(); Text(value.isEmpty ? "—" : value).multilineTextAlignment(.trailing) }.font(.subheadline).padding(.vertical, 11).overlay(alignment: .bottom) { Rectangle().fill(.white.opacity(0.08)).frame(height: 1) }
}

private struct SettingsView: View {
    @EnvironmentObject var store: FlightPlanStore
    var body: some View {
        Screen("SETTINGS") {
            Text("SIMBRIEF ACCOUNT").font(.caption.bold()).tracking(2).foregroundStyle(.cyan)
            Text("Use your SimBrief username or numeric Pilot ID. The app fetches your latest OFP directly from SimBrief; it never asks for your password.").font(.subheadline).foregroundStyle(.white.opacity(0.65))
            TextField("SimBrief username or Pilot ID", text: $store.username).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.asciiCapable).padding(14).background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            Button { Task { await store.fetch() } } label: { Label("Save and fetch OFP", systemImage: "arrow.down.circle.fill").frame(maxWidth: .infinity).padding(14).background(.cyan, in: RoundedRectangle(cornerRadius: 14)).foregroundStyle(.black).fontWeight(.bold) }
            if let error = store.error { Text(error).foregroundStyle(.orange).font(.footnote) }
            Link(destination: URL(string: "https://www.simbrief.com/home/")!) { Label("Open SimBrief", systemImage: "arrow.up.right.square") }.padding(.top, 8)
        }
    }
}

private enum JetPhotos {
    static func url(for registration: String) -> URL { URL(string: "https://www.jetphotos.com/registration/\(registration.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? registration)")! }
}

private struct JetPhotosImage: View {
    let registration: String
    @State private var photoURL: URL?
    var body: some View {
        Group {
            if let photoURL { AsyncImage(url: photoURL) { image in image.resizable().scaledToFill() } placeholder: { placeholder } }
            else { placeholder }
        }
        .task(id: registration) { photoURL = await JetPhotos.photoURL(for: registration) }
        .frame(maxWidth: .infinity).clipped()
    }
    private var placeholder: some View {
        ZStack { Color.white.opacity(0.05); VStack(spacing: 8) { Image(systemName: "camera").font(.title2); Text("Aircraft photos").font(.caption); Link("Search on JetPhotos", destination: JetPhotos.url(for: registration)).font(.caption.bold()) }.foregroundStyle(.white.opacity(0.7)) }
    }
}

private extension JetPhotos {
    static func photoURL(for registration: String) async -> URL? {
        do {
            var request = URLRequest(url: url(for: registration)); request.timeoutInterval = 12
            request.setValue("Mozilla/5.0 FlightDeck/1.0", forHTTPHeaderField: "User-Agent")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200, let html = String(data: data, encoding: .utf8) else { return nil }
            let patterns = [#"<meta[^>]+property=[\"']og:image[\"'][^>]+content=[\"']([^\"']+)[\"']"#, #"<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+property=[\"']og:image[\"']"#]
            for pattern in patterns {
                if let range = html.range(of: pattern, options: [.regularExpression, .caseInsensitive]),
                   let capture = html[range].range(of: #"https?://[^\"']+"#, options: .regularExpression) {
                    return URL(string: String(html[capture]))
                }
            }
        } catch { return nil }
        return nil
    }
}

