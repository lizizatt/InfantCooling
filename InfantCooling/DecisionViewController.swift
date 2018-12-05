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
        btn.backgroundColor = UIColor.lightGray;
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
        btn.backgroundColor = UIColor.lightGray;
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        if let titleLabel = btn.titleLabel {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body);
        }
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(questionField);
        view.addSubview(yesButton);
        view.addSubview(noButton);
        
        yesButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        setUpAutoLayout();
        
        let dc = DecisionEngineController(DecisionReachedShouldProceed: DecisionReachedShouldProceed, DecisionReachedShouldNotCool: DecisionReachedShouldNotCool, NewQuestionToDisplay: NewQuestionToDisplay);
        decisionEngine = DecisionEngine(controller: dc);
    }
    
    func DecisionReachedShouldProceed() -> Void {
        questionField.text = "Proceed to neurological examination."
    }
    
    func DecisionReachedShouldNotCool() -> Void {
        questionField.text = "Do not cool infant."
    }
    
    func NewQuestionToDisplay(question: String) -> Void {
        questionField.text = question;
        self.question = question;
    }
    
    @objc func buttonPressed(_ sender: UIButton?) {
        if (sender == yesButton) {
            decisionEngine?.AnswerQuestion(question: question, value: true);
        }
        if (sender == noButton) {
            decisionEngine?.AnswerQuestion(question: question, value: false);
        }
    }
    
    func setUpAutoLayout() {
        questionField.leftAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leftAnchor).isActive = true;
        questionField.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor).isActive = true;
        questionField.heightAnchor.constraint(equalToConstant: view.frame.height / 3.0).isActive = true;
        questionField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true;
        
        yesButton.leftAnchor.constraint(equalTo:questionField.leftAnchor).isActive = true;
        yesButton.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.centerXAnchor).isActive = true;
        yesButton.heightAnchor.constraint(equalToConstant: view.frame.height / 6.0).isActive = true;
        yesButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true;
        
        noButton.leftAnchor.constraint(equalTo:yesButton.rightAnchor).isActive = true;
        noButton.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor).isActive = true;
        noButton.heightAnchor.constraint(equalToConstant: view.frame.height / 6.0).isActive = true;
        noButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true;
    }
}
