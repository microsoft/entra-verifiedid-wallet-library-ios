/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import UIKit
import WalletLibrary

class RequirementsViewController: UIViewController
{
    /// Constants specific to RequirementsViewController.
    private struct Constants
    {
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// The label.
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.returnKeyType = UIReturnKeyType.done
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    /// The label.
    private lazy var button: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("fulfill", for: .normal)
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// The label.
    private lazy var completebutton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("complete", for: .normal)
        button.addTarget(self, action: #selector(onCompleteButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let viewModel: RequirementsViewModel

    init()
    {
        self.viewModel = RequirementsViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupView()
        bindViewModelComponents()
        do {
            try viewModel.createVerifiedIdClient(from: "this is test")
        } catch {
            print(error)
        }
    }

    /// Bind the the view model components.
    private func bindViewModelComponents()
    {
        viewModel.selfAttestedRequirements.bind {
            [weak self] value in
            if !value.isEmpty {
                DispatchQueue.main.async {
                    self?.label.text = value.first?.description
                }
            }
        }
        
        viewModel.isFlowComplete.bind {
            [weak self] value in
            if value != nil {
                DispatchQueue.main.async {
                    self?.label.text = "Verified ID type: \(value!.type), \n claims: \(value!.claims), \n issued at: \(value!.issuedOn.formatted())"
                    self?.viewModel.areAllRequirementsFulfilled.value = false
                }
            }
        }
        
        viewModel.areAllRequirementsFulfilled.bind {
            [weak self] value in
            if value {
                DispatchQueue.main.async {
                    self?.completebutton.isEnabled = true
                    self?.label.text = self?.viewModel.selfAttestedRequirements.value.first?.description
                }
            } else {
                DispatchQueue.main.async {
                    self?.completebutton.isEnabled = false
                }
            }
        }
    }

    /// Setup the view.
    private func setupView()
    {
        view.addSubview(stackView)
        stackView.addArrangedSubview(label)
        stackView.setCustomSpacing(20, after: label)
        stackView.addArrangedSubview(textField)
        stackView.setCustomSpacing(20, after: textField)
        stackView.addArrangedSubview(button)
        stackView.setCustomSpacing(10, after: button)
        stackView.addArrangedSubview(completebutton)
        setupLayoutConstraints()
    }

    /// Setup the view and subview constraints.
    private func setupLayoutConstraints()
    {
        view.addConstraints([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        view.addConstraints([
            label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 20),
        ])
        
        view.addConstraints([
            textField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20)
        ])
        
        view.addConstraints([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        view.addConstraints([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 25)
        ])
        
    }
    
    @objc private func onButtonTapped() {
        print("on button tapped")
        viewModel.fulfillRequirement(requirement: viewModel.selfAttestedRequirements.value.first!, with: textField.text ?? "")
    }
    
    @objc private func onCompleteButtonTapped() {
        viewModel.completeFlow()
    }
}
