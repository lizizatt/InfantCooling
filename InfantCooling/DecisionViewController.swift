//
//  DecisionViewController.swift
//  InfantCooling
//
//  Created by Elizabeth Izatt on 11/30/18.
//  Copyright © 2018 LizIzatt. All rights reserved.
//

import Foundation
import UIKit

class DecisionViewController: UIViewController {
    
    private var decisionEngine : DecisionEngine?;
    private var question = "";
    
    private let space : CGFloat = 5;
    private let yesNoButtonHeight : CGFloat = 100;
    
    enum UIState {
        case question
        case done
    }
    
    let questionField : UILabel = {
        let txt = UILabel()
        txt.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        txt.tintColor = .white
        txt.layer.cornerRadius = 5
        txt.clipsToBounds = true
        txt.textAlignment = NSTextAlignment.center
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.font = UIFont.preferredFont(forTextStyle: .body)
        txt.adjustsFontForContentSizeCategory = true
        txt.lineBreakMode = NSLineBreakMode.byWordWrapping
        txt.numberOfLines = 0
        return txt
    }()
    
    let yesButton : UIButton = {
        let btn = UIButton(type:.system)
        btn.setTitle("Yes", for: .normal)
        btn.setTitleColor(UIColor.black , for: .normal);
        btn.tintColor = UIColor.white
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        if let titleLabel = btn.titleLabel {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body);
        }
        return btn
    }()
    
    let noButton : UIButton = {
        let btn = UIButton(type:.system)
        btn.setTitle("No", for: .normal)
        btn.setTitleColor(UIColor.black , for: .normal);
        btn.tintColor = UIColor.lightGray
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        if let titleLabel = btn.titleLabel {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body);
        }
        return btn
    }()
    
    let resetButton : UIButton = {
        let btn = UIButton(type:.system)
        btn.setTitle("Reset", for: .normal)
        btn.tintColor = UIColor.lightGray
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        if let titleLabel = btn.titleLabel {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body);
        }
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = DukeLookAndFeel.black;
        
        view.addSubview(questionField);
        view.addSubview(yesButton);
        view.addSubview(noButton);
        view.addSubview(resetButton);
        
        SetButtonState(state: .question);
        
        yesButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        setUpAutoLayout();
        setUpColors();
        
        let dc = DecisionEngineController(DecisionReachedShouldProceed: DecisionReachedShouldProceed, DecisionReachedShouldNotCool: DecisionReachedShouldNotCool, NewQuestionToDisplay: NewQuestionToDisplay);
        decisionEngine = DecisionEngine(controller: dc);
    }
    
    func DecisionReachedShouldProceed() -> Void {
        SetButtonState(state: .done);
        questionField.text = "Proceed to neurological examination."
        refineAutoLayout(); //resize text
    }
    
    func DecisionReachedShouldNotCool() -> Void {
        SetButtonState(state: .done);
        questionField.text = "Do not cool infant."
        refineAutoLayout(); //resize text
    }
    
    func NewQuestionToDisplay(question: String) -> Void {
        SetButtonState(state: .question);
        questionField.text = question;
        self.question = question;
        refineAutoLayout(); //resize text
    }
    
    @objc func buttonPressed(_ sender: UIButton?) {
        if (sender == yesButton) {
            decisionEngine?.AnswerQuestion(question: question, value: true);
        }
        if (sender == noButton) {
            decisionEngine?.AnswerQuestion(question: question, value: false);
        }
        if (sender == resetButton) {
            decisionEngine?.Clear();
        }
    }
    
    func setUpAutoLayout() {
        yesButton.leftAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        yesButton.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.centerXAnchor, constant: -space/2).isActive = true;
        yesButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        yesButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true;
        
        noButton.leftAnchor.constraint(equalTo:yesButton.rightAnchor, constant: space).isActive = true;
        noButton.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor, constant: -space).isActive = true;
        noButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        noButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true;
        
        resetButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        resetButton.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor, constant: -space).isActive = true;
        resetButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        resetButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true;
        
        questionField.leftAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        questionField.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor, constant: -space).isActive = true;
        questionField.bottomAnchor.constraint(equalTo: yesButton.topAnchor, constant: -space).isActive = true;
        
        refineAutoLayout();
    }
    
    func refineAutoLayout() {
        questionField.sizeToFit();
    }
    
    func setUpColors() {
        questionField.textColor = DukeLookAndFeel.coolGray;
        
        yesButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        noButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        resetButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        
        yesButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        noButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        resetButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        
        yesButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        noButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        resetButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        
        yesButton.layer.borderWidth = 1;
        noButton.layer.borderWidth = 1;
        resetButton.layer.borderWidth = 1;
    }
    
    func SetButtonState(state : UIState) {
        switch (state) {
        case .question:
            yesButton.isHidden = false;
            noButton.isHidden = false;
            resetButton.isHidden = true;
            return
        case .done:
            yesButton.isHidden = true;
            noButton.isHidden = true;
            resetButton.isHidden = false;
            return
        }
    }
}
