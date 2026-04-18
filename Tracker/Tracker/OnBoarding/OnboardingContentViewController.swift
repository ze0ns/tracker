//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 31.03.2026.
//


// OnboardingContentViewController.swift
import UIKit

class OnboardingContentViewController: UIViewController {
    
    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    // MARK: - Properties
    var page: OnboardingPage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithPage()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 460),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureWithPage() {
        guard let page = page else { return }
        titleLabel.text = page.title
        imageView.image = UIImage(named: page.imageName)
        view.backgroundColor = page.backgroundColor
    }
}
