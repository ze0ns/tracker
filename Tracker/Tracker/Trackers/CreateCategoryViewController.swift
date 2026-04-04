
import UIKit
protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}


final class CreateCategoryViewController: UIViewController {
     weak var delegate: CategoryViewControllerDelegate?
      var dismissCallback: (() -> Void)?

    private let viewModel: CategoryViewModel
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .ypBackgroundDay // Или .systemGray6
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = .black
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
 
    init(store: TrackerStore) {
        self.viewModel = CategoryViewModel(store: store)
        super.init(nibName: nil, bundle: nil)
    }
    
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(doneButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func bindViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        viewModel.textDidChange(nameTextField.text ?? "")
    }
    
    @objc private func doneButtonTapped() {
        viewModel.saveCategory()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - CategoryViewModelDelegate
extension CreateCategoryViewController: CategoryViewModelDelegate {
    
    func didUpdateDoneButtonState(isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? .black : .ypGray
    }
    
    func didCreateCategorySuccessfully() {
        dismissCallback?()
        dismiss(animated: true)
    }
    
    func didReceiveError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
