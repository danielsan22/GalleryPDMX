//
//  AppWireframe.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 05/07/23.
//

import UIKit

enum AppWireframe {
    
    static func rootController() -> UIViewController {
        // Here is where we would fetch the dependecies from a container to have better DI
        // Using something like swinject for example.
        let client = GalleryMockClient()
        let interactor = GalleryInteractor(client: client)
        let presenter = GalleryPresenter(interactor: interactor)
        let vc = ViewController(presenter: presenter)
        return UINavigationController(rootViewController: vc)
    }
}
