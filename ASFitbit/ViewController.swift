//
//  ViewController.swift
//  ASFitbit
//
//  Created by Maksim Vialykh on 2019-03-02.
//  Copyright © 2019 Vialyx. All rights reserved.
//

import UIKit

// TODO: - Move to the separated file
struct Constants {

    static let authUrl = URL(string: "https://www.fitbit.com/oauth2/authorize")
    static let responseType = "code"
    static let clientId = "{YOUR_CLIENT_ID}"
    static let redirectScheme = "vialyx://"
    static let redirectUrl = "\(redirectScheme)fitbit/auth"
    static let scope = ["activity", "heartrate", "location", "nutrition", "profile", "settings", "sleep", "social", "weight"]
    static let expires = "604800"

    private init() {}

}

// TODO: - Move to the separated file
class Model: AuthHandlerType {

    var session: NSObject? = nil

    func auth(_ completion: @escaping ((String?, Error?) -> Void)) {
        guard let authUrl = Constants.authUrl else {
            completion(nil, nil)

            return
        }

        var urlComponents = URLComponents(url: authUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "response_type", value: Constants.responseType),
            URLQueryItem(name: "client_id", value: Constants.clientId),
            URLQueryItem(name: "redirect_url", value: Constants.redirectUrl),
            URLQueryItem(name: "scope", value: Constants.scope.joined(separator: " ")),
            URLQueryItem(name: "expires_in", value: String(Constants.expires))
        ]

        guard let url = urlComponents?.url else {
            completion(nil, nil)

            return
        }

        auth(url: url, callbackScheme: Constants.redirectScheme) {
            url, error in
            if error != nil {
                completion(nil, error)
            } else if let `url` = url {
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      let item = components.queryItems?.first(where: { $0.name == "code" }),
                      let code = item.value else {
                    completion(nil, nil)

                    return
                }

                completion(code, nil)
            }
        }
    }

}

class ViewController: UIViewController {

    var model: Model = Model()

    override func loadView() {
        super.loadView()

        let button = UIButton(frame: CGRect(x: 60, y: 100, width: 200, height: 100))
        button.setTitle("Start Fitbit Auth", for: UIControl.State())
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(authDidTap), for: .touchUpInside)

        view.addSubview(button)
    }

    // MARK: - Actions
    @objc private func authDidTap() {
        model.auth { authCode, error in
            if error != nil {
                print("Auth flow finished with error \(String(describing: error))")
            } else {
                print("Your auth code is \(String(describing: authCode))")

                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "auth code is \(String(describing: authCode))", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

}
