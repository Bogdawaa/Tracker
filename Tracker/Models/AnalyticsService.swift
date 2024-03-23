//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 13.03.2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "1cf821ab-d52a-4f27-a04d-bf67426a72a0") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR %@", error.localizedDescription)
        })
    }
}
