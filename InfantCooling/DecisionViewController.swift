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
    
    var questions = [""];
    var answers = [""];
    
    enum UIState {
        case question
        case done
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let questionField : UILabel = {
        let txt = UILabel()
        txt.text = ""
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
    
    //init
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
        
        let dc = DecisionEngineController(DecisionReached: DecisionReached, NewQuestionToDisplay: NewQuestionToDisplay);
        decisionEngine = DecisionEngine(controller: dc);
    }
    
    //callbacks from engine
    func DecisionReached(decision : String) {
        SetButtonState(state: .done)
        questionField.text = decision;
        refineAutoLayout(); //resize text
    }
    
    func NewQuestionToDisplay(question: String) {
        SetButtonState(state: .question);
        questionField.text = question;
        self.question = question;
        refineAutoLayout(); //resize text
    }
    
    //button callback
    @objc func buttonPressed(_ sender: UIButton?) {
        if (sender == yesButton) {
            decisionEngine?.AnswerQuestion(value: true);
        }
        if (sender == noButton) {
            decisionEngine?.AnswerQuestion(value: false);
        }
        if (sender == resetButton) {
            decisionEngine?.Clear();
        }
    }
    
    //layout of view
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
    
    //state utility
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
