import Foundation
import SwiftUI

struct FlightPlan {
    var callsign = "", aircraft = "", registration = "", origin = "", originName = "", destination = "", destinationName = "", route = "", alternate = "", cruiseAltitude = "", distance = "", flightTime = "", blockFuel = "", takeoffWeight = "", v1 = "", vr = "", v2 = "", runway = ""

    static func parse(_ data: Data) throws -> FlightPlan {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw FetchError.invalidData }
        let general = root["general"] as? [String: Any] ?? [:]
        let aircraft = root["aircraft"] as? [String: Any] ?? [:]
        let origin = root["origin"] as? [String: Any] ?? [:]
        let destination = root["destination"] as? [String: Any] ?? [:]
        let times = root["times"] as? [String: Any] ?? [:]
        let fuel = root["fuel"] as? [String: Any] ?? [:]
        let weights = root["weights"] as? [String: Any] ?? [:]
        let params = root["params"] as? [String: Any] ?? [:]
        func value(_ dict: [String: Any], _ keys: String...) -> String {
            for key in keys { if let v = dict[key], !(v is NSNull) { let s = String(describing: v); if !s.isEmpty && s != "0" { return s } } }
            return ""
        }
        func find(_ names: [String], in object: Any) -> String? {
            if let dict = object as? [String: Any] {
                for (key, item) in dict where names.contains(key.lowercased()) { let s = String(describing: item); if s != "0" && !s.isEmpty { return s } }
                for item in dict.values { if let result = find(names, in: item) { return result } }
            } else if let array = object as? [Any] { for item in array { if let result = find(names, in: item) { return result } } }
            return nil
        }
        var p = FlightPlan(
            callsign: value(general, "flight_number", "callsign"),
            aircraft: [value(aircraft, "icaocode", "icao_code", "icaotype"), value(aircraft, "name", "type")].filter { !$0.isEmpty }.joined(separator: " · "),
            registration: value(aircraft, "reg", "registration"),
            origin: value(origin, "icao_code", "icao"), originName: value(origin, "name"),
            destination: value(destination, "icao_code", "icao"), destinationName: value(destination, "name"),
            route: value(general, "route"), alternate: value(destination, "alternate", "altn", "alternate_icao"),
            cruiseAltitude: value(general, "initial_altitude", "cruise_altitude", "level"),
            distance: value(general, "planned_distance", "distance"),
            flightTime: value(times, "est_time_enroute", "est_block", "sched_time"),
            blockFuel: value(fuel, "plan_ramp", "plan_block", "plan_takeoff"),
            takeoffWeight: value(weights, "est_tow", "plan_tow"),
            v1: find(["speeds_v1", "v1"], in: root).map { $0 + " kt" } ?? "",
            vr: find(["speeds_vr", "vr"], in: root).map { $0 + " kt" } ?? "",
            v2: find(["speeds_v2", "v2"], in: root).map { $0 + " kt" } ?? "",
            runway: value(origin, "plan_rwy", "runway")
        )
        if p.route.isEmpty, let fixes = root["navlog"] as? [[String: Any]] {
            p.route = fixes.compactMap { $0["ident"] as? String }.joined(separator: " · ")
        }
        if p.alternate.isEmpty, let alternates = root["alternates"] as? [[String: Any]], let first = alternates.first {
            p.alternate = value(first, "icao", "icao_code", "id")
        }
        if !p.cruiseAltitude.isEmpty && !p.cruiseAltitude.hasPrefix("FL") { p.cruiseAltitude = "FL" + p.cruiseAltitude }
        if !p.distance.isEmpty { p.distance += " NM" }
        if !p.flightTime.isEmpty { p.flightTime = p.flightTime.replacingOccurrences(of: "00:", with: "") }
        if !p.blockFuel.isEmpty { p.blockFuel += " " + value(params, "units") }
        return p
    }
}

enum FetchError: LocalizedError {
    case invalidData, noPlan
    var errorDescription: String? { switch self { case .invalidData: "SimBrief returned data we couldn't read."; case .noPlan: "No OFP found. Generate a flight plan in SimBrief first." } }
}

@MainActor final class FlightPlanStore: ObservableObject {
    @Published var plan: FlightPlan?
    @Published var username = UserDefaults.standard.string(forKey: "simbriefUsername") ?? ""
    @Published var isLoading = false
    @Published var error: String?
    func fetch() async {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { error = "Enter your SimBrief username in Settings."; return }
        isLoading = true; error = nil
        defer { isLoading = false }
        UserDefaults.standard.set(name, forKey: "simbriefUsername")
        do {
            var components = URLComponents(string: "https://www.simbrief.com/api/xml.fetcher.php")!
            let key = name.allSatisfy(\.isNumber) ? "userid" : "username"
            components.queryItems = [URLQueryItem(name: key, value: name), URLQueryItem(name: "json", value: "v2")]
            var request = URLRequest(url: components.url!); request.timeoutInterval = 25
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw FetchError.noPlan }
            if let fetch = obj["fetch"] as? [String: Any], let status = fetch["status"] as? String, status.lowercased() != "success" { throw FetchError.noPlan }
            plan = try FlightPlan.parse(data)
        } catch { self.error = error.localizedDescription }
    }
}

