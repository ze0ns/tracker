//
//  CategoryViewControllerDelegate.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 09.03.2026.
//


//
//  CategoryViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

class CategoryViewController: UIViewController {
    weak var delegate: CategoryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Категория"
    }
}

