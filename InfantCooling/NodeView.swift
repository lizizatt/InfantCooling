//
//  NodeView.swift
//  InfantCooling
//
//  Created by Elizabeth Izatt on 12/9/18.
//  Copyright © 2018 LizIzatt. All rights reserved.
//

import Foundation
import UIKit

class Node: UIView {
    let ANIMATION_DURATION : Double = 1;
    let COMPOUND_ANIMATION_DURATION : Double = 0.5;
    let SPACE : CGFloat = 10;
    func setOffset(vec : CGVector, animate : Bool) {
    }
    func setFocused(focused : Bool) {
        
    }
}

class LeafNode : Node {
    var result = "";
    var engine : DecisionEngine;
    
    private let nodeConnectDistance : CGFloat = 20;
    
    private var defaultFrame : CGRect;
    
    let resultField : UILabel = {
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
    
    init(result : String, engine: DecisionEngine, initialX : CGFloat, initialY : CGFloat, width : CGFloat, height : CGFloat) {
        
        self.engine = engine;
        self.result = result;
        resultField.text = result;
        
        defaultFrame = CGRect(x: initialX, y: initialY, width: width, height: height);
        super.init(frame: defaultFrame);
        
        
        self.layer.borderWidth = 5;
        self.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        
        addSubview(resultField);
        
        setUpColors();
        setUpAutoLayout();
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func setOffset(vec : CGVector, animate : Bool) {
        
        let x = vec.dx - frame.width / 2;
        let y = vec.dy - frame.height / 2;
        
        var duration = ANIMATION_DURATION;
        if (!animate) {
            duration = 0;
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.origin = CGPoint(x: x + self.defaultFrame.origin.x, y: y + self.defaultFrame.origin.y)
        })
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var defaultSizeThatFits = super.sizeThatFits(_: size);
        defaultSizeThatFits.height += nodeConnectDistance * 2;
        return defaultSizeThatFits;
    }
    
    //layout of view
    func setUpAutoLayout() {
        
        resultField.widthAnchor.constraint(equalTo: widthAnchor).isActive = true;
        resultField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true;
        resultField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true;
        
        resultField.sizeToFit();
    }
    
    func setUpColors() {
        resultField.textColor = DukeLookAndFeel.coolGray;
        
        backgroundColor = DukeLookAndFeel.black
    }
    
    override func setFocused(focused : Bool) {
        if (focused) {
            backgroundColor = DukeLookAndFeel.blueSecondaryFaded
        } else {
            backgroundColor = DukeLookAndFeel.black
        }
    }
}

class QueryNode : Node {
    var question = "";
    var engine : DecisionEngine;
    
    private let yesNoButtonHeight : CGFloat = 50;
    private let nodeConnectDistance : CGFloat = 20;
    private var defaultFrame : CGRect;
    
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
    
    init(question : String, engine: DecisionEngine, initialX : CGFloat, initialY : CGFloat, width : CGFloat, height : CGFloat) {
        
        self.engine = engine;
        self.question = question;
        questionField.text = question;
        
        defaultFrame = CGRect(x: initialX, y: initialY, width: width, height: height);
        super.init(frame: defaultFrame);
        
        
        self.layer.borderWidth = 5;
        self.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        
        addSubview(yesButton);
        addSubview(noButton);
        addSubview(questionField);
        
        yesButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        setUpColors();
        setUpAutoLayout();
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func setOffset(vec : CGVector, animate: Bool) {
        let x = vec.dx - frame.width / 2;
        let y = vec.dy - frame.height / 2;
        
        var duration = ANIMATION_DURATION;
        if (!animate) {
            duration = 0;
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.origin = CGPoint(x: x + self.defaultFrame.origin.x, y: y + self.defaultFrame.origin.y)
        })
    }
    
    @objc func buttonPressed(_ sender: UIButton?) {
        if (sender == yesButton) {
            engine.AnswerQuestion(value: true);
        }
        if (sender == noButton) {
            engine.AnswerQuestion(value: false);
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var defaultSizeThatFits = super.sizeThatFits(_: size);
        defaultSizeThatFits.height += nodeConnectDistance * 2;
        return defaultSizeThatFits;
    }
    
    //layout of view
    func setUpAutoLayout() {
        yesButton.leftAnchor.constraint(equalTo: leftAnchor, constant: SPACE).isActive = true;
        yesButton.rightAnchor.constraint(equalTo: centerXAnchor, constant: -SPACE/2).isActive = true;
        yesButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        yesButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SPACE - nodeConnectDistance).isActive = true;
        
        noButton.leftAnchor.constraint(equalTo:yesButton.rightAnchor, constant: SPACE).isActive = true;
        noButton.rightAnchor.constraint(equalTo:rightAnchor, constant: -SPACE).isActive = true;
        noButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        noButton.bottomAnchor.constraint(equalTo: yesButton.bottomAnchor).isActive = true;
        
        questionField.leftAnchor.constraint(equalTo:leftAnchor, constant: SPACE).isActive = true;
        questionField.rightAnchor.constraint(equalTo:rightAnchor, constant: -SPACE).isActive = true;
        questionField.bottomAnchor.constraint(equalTo: yesButton.topAnchor, constant: -SPACE).isActive = true;
        
        questionField.sizeToFit();
    }
    
    func setUpColors() {
        questionField.textColor = DukeLookAndFeel.coolGray;
        
        yesButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        noButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        
        yesButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        noButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        
        yesButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        noButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        
        yesButton.layer.borderWidth = 1;
        noButton.layer.borderWidth = 1;
        
        backgroundColor = DukeLookAndFeel.black
    }
    
    override func setFocused(focused : Bool) {
        noButton.isEnabled = focused;
        yesButton.isEnabled = focused;
        
        if (focused) {
            backgroundColor = DukeLookAndFeel.blueSecondaryFaded
        } else {
            backgroundColor = DukeLookAndFeel.black
        }
    }
}

class CompoundQueryNode : Node {
    var questions = [String]();
    var needed : Int = 0;
    var engine : DecisionEngine;
    
    var questionsTableView: UITableView!
    
    private let yesNoButtonHeight : CGFloat = 50;
    private let nodeConnectDistance : CGFloat = 20;
    private var defaultFrame : CGRect;
    
    private var answered = 0;
    private var current = 0;
    
    var questionFields = [UILabel]();
    
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
    
    init(questions : [String], needed : Int, engine: DecisionEngine, initialX : CGFloat, initialY : CGFloat, width : CGFloat, height : CGFloat) {
        
        self.engine = engine;
        self.questions = questions;
        self.needed = needed;
        
        defaultFrame = CGRect(x: initialX, y: initialY, width: width, height: height);
        super.init(frame: defaultFrame);
        
        addSubview(yesButton);
        addSubview(noButton);
        
        yesButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        for question in questions {
            let label = UILabel(frame: frame);
            label.text = question
            label.textColor = DukeLookAndFeel.coolGray;
            label.translatesAutoresizingMaskIntoConstraints = false;
            label.adjustsFontForContentSizeCategory = true;
            label.adjustsFontSizeToFitWidth = true;
            label.numberOfLines = 0;
            questionFields.append(label)
            addSubview(label)
        }
        
        self.clipsToBounds = true
        
        setUpColors();
        setUpAutoLayout();
        
        answered = 0;
        current = 0;
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func setOffset(vec : CGVector, animate: Bool) {
        let x = vec.dx - frame.width / 2;
        let y = vec.dy - frame.height / 2;
        
        var duration = ANIMATION_DURATION;
        if (!animate) {
            duration = 0;
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.origin = CGPoint(x: x + self.defaultFrame.origin.x, y: y + self.defaultFrame.origin.y)
        })
    }
    
    @objc func buttonPressed(_ sender: UIButton?) {
        if (sender == yesButton) {
            current = current + 1
            answered = answered + 1;
            if (answered >= needed) {
                engine.AnswerQuestion(value: true);
                return;
            }
        }
        if (sender == noButton) {
            current = current + 1
            
            //currently have current questions answeresd of questions.count
            //with answered / needed
            //if (needed - answered) < questions.count - current, we're done
            
            if ((needed - answered) > (questions.count - current)) {
                engine.AnswerQuestion(value: false);
                return;
            }
        }
        
        //animate presentation of next question
        setActiveQuestionField(index: current);
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var defaultSizeThatFits = super.sizeThatFits(_: size);
        defaultSizeThatFits.height += nodeConnectDistance * 2;
        return defaultSizeThatFits;
    }
    
    //layout of view
    func setUpAutoLayout() {
        yesButton.leftAnchor.constraint(equalTo: leftAnchor, constant: SPACE).isActive = true;
        yesButton.rightAnchor.constraint(equalTo: centerXAnchor, constant: -SPACE/2).isActive = true;
        yesButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        yesButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SPACE - nodeConnectDistance).isActive = true;
        
        noButton.leftAnchor.constraint(equalTo:yesButton.rightAnchor, constant: SPACE).isActive = true;
        noButton.rightAnchor.constraint(equalTo:rightAnchor, constant: -SPACE).isActive = true;
        noButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        noButton.bottomAnchor.constraint(equalTo: yesButton.bottomAnchor).isActive = true;
        
        var currentIndex = 0;
        for questionField in questionFields {
            let offset = CGFloat(currentIndex) * (frame.width * 2);
            
            questionField.leftAnchor.constraint(equalTo:leftAnchor, constant: SPACE + offset).isActive = true;
            questionField.rightAnchor.constraint(equalTo:rightAnchor, constant: -SPACE + offset).isActive = true;
            questionField.bottomAnchor.constraint(equalTo: yesButton.topAnchor, constant: -SPACE).isActive = true;
            
            questionField.sizeToFit();
            
            currentIndex = currentIndex + 1;
        }
    }
    
    func setActiveQuestionField(index : Int) {
        
        var currentIndex = 0;
        for questionField in questionFields {
            let offset = CGFloat(currentIndex - index) * (frame.width * 2);
            
            UIView.animate(withDuration: COMPOUND_ANIMATION_DURATION, delay: 0.0, options: .curveEaseOut, animations: {
                questionField.frame.origin = CGPoint(x: self.SPACE + offset, y: questionField.frame.origin.y)
            })
            
            currentIndex = currentIndex + 1;
        }
    }
    
    func setUpColors() {
        self.layer.borderWidth = 5;
        self.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        
        yesButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        noButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        
        yesButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        noButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        
        yesButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        noButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        
        yesButton.layer.borderWidth = 1;
        noButton.layer.borderWidth = 1;
        
        backgroundColor = DukeLookAndFeel.black
    }
    
    override func setFocused(focused : Bool) {
        noButton.isEnabled = focused;
        yesButton.isEnabled = focused;
        
        answered = 0;
        current = 0;
        setActiveQuestionField(index: 0)
        
        if (focused) {
            backgroundColor = DukeLookAndFeel.blueSecondaryFaded
        } else {
            backgroundColor = DukeLookAndFeel.black
        }
    }
}
