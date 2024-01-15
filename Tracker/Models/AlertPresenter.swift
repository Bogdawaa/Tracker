//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 15.01.2024.
//

import UIKit

class AlertPresenter {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(in vc: UIViewController, error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default)
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
