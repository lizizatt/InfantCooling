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
    
    private let space : CGFloat = 5;
    private let yesNoButtonHeight : CGFloat = 100;
    
    private var nodesPositionDictionary = [DecisionEngine.Node: CGVector]()
    private var nodeViews = [Node]()
    
    var questions = [""];
    var answers = [""];
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
    
    var nv : QueryNode?;
    
    //init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dc = DecisionEngineController(SetUpTree: SetUpTree, FocusOnNode: FocusOnNode);
        decisionEngine = DecisionEngine(controller: dc);
        
        view.addSubview(resetButton);
        
        resetButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        setUpAutoLayout();
        setUpColors();
        
        decisionEngine!.ClearAndStart();
    }
    
    //Called once by DecisionEngine once tree is generated but question has not been asked yet
    //Determine a layout and draw out the decision tree in our frame
    func SetUpTree(tree: DecisionEngine.Tree)
    {
        var x = 0
        var y = 0
     
        for question in tree.questions {
            nodesPositionDictionary[question] = CGVector(dx: x, dy: y)
            
            nodeViews.append(QueryNode(question: question.question, engine: decisionEngine!, initialX: x, initialY: y))
            view.addSubview(nodeViews[nodeViews.count - 1])
            
            x += 250
        }
        
        x = 0
        y += 300;
        
        for leaf in tree.leaves {
            nodesPositionDictionary[leaf] = CGVector(dx: x, dy: y)
            
            nodeViews.append(LeafNode(result: leaf.result, engine: decisionEngine!, initialX: x, initialY: y))
            view.addSubview(nodeViews[nodeViews.count - 1])
            
            x += 250
        }
    }
    
    //DecisionEngine respondin to a question being answered with the next node
    //Focus on it in the view
    func FocusOnNode(node: DecisionEngine.Node)
    {
        let pos = nodesPositionDictionary[node];
        for node in nodeViews {
            node.setOffset(vec: CGVector(dx: -pos!.dx + view.frame.width / 2, dy: -pos!.dy + view.frame.height / 2))
        }
    }
    
    //button callback
    @objc func buttonPressed(_ sender: UIButton?) {
        if (sender == resetButton) {
            decisionEngine!.ClearAndStart();
        }
    }
    
    //layout of view
    func setUpAutoLayout() {
        resetButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        resetButton.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor, constant: -space).isActive = true;
        resetButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -space).isActive = true;
    }
    
    func setUpColors() {
        view.backgroundColor = DukeLookAndFeel.black;
        
        resetButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        
        resetButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
    
        resetButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        
        resetButton.layer.borderWidth = 1;
    }
}
