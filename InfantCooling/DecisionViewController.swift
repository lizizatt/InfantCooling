//
//  DecisionViewController.swift
//  InfantCooling
//
//  Created by Elizabeth Izatt on 11/30/18.
//  Copyright © 2018 LizIzatt. All rights reserved.
//

import Foundation
import UIKit

//utility for CGVector
func +(left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

class DecisionViewController: UIViewController {
    
    static let ANIMATION_DURATION : Double = 1;

    private var decisionEngine : DecisionEngine?;
    
    private let space : CGFloat = 5;
    private let yesNoButtonHeight : CGFloat = 50;
    
    private var nodesAccessDictionary = [DecisionEngine.Node: Node]()
    private var nodesPositionDictionary = [DecisionEngine.Node: CGVector]()
    private var nodeViews = [Node]()
    private var lineViews = [LineView]()
    
    private var firstDraw = false;
    
    
    let nodeWidth : CGFloat = 0.66;
    let nodeHeight: CGFloat = 0.33;
    
    var questions = [""];
    var answers = [""];
    var jsonString = "";
    
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
    
    let exitButton : UIButton = {
        let btn = UIButton(type:.system)
        btn.setTitle("Exit", for: .normal)
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
    
    convenience init (jsonString : String) {
        self.init()
        self.jsonString = jsonString;
    }
    
    //init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true;
        
        let dc = DecisionEngineController(SetUpTree: SetUpTree, FocusOnNode: FocusOnNode);
        decisionEngine = DecisionEngine(controller: dc, jsonString: jsonString);
        
        view.addSubview(resetButton);
        view.addSubview(exitButton)
        
        resetButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        setUpAutoLayout();
        setUpColors();
        
        decisionEngine!.ClearAndStart();
    }
    
    //Called once by DecisionEngine once tree is generated but question has not been asked yet
    //Determine a layout and draw out the decision tree in our frame
    func SetUpTree(tree: DecisionEngine.Tree)
    {
        var nodes = [Int:[DecisionEngine.Node]]()
        
        for node in tree.getAllNodes() {
            if (nodes[node.maxDepth] == nil) {
                nodes[node.maxDepth] = [DecisionEngine.Node]()
            }
            nodes[node.maxDepth]?.append(node)
        }
     
        let w = nodeWidth * view.frame.width
        let h = nodeHeight * view.frame.height
        
        for level in nodes.keys {
            let numInLevel : CGFloat = CGFloat(nodes[level]!.count);
            
            let y : CGFloat = CGFloat(level) * h * 1.5
            
            var x = numInLevel / -2.0 * w
            let dX = w * 1.5
            for node in nodes[level]! {
                if let question = node as? DecisionEngine.Question {
                    let toAdd = QueryNode(question: question.question, engine: decisionEngine!, initialX: x, initialY: y, width: w, height: h)
                    toAdd.sizeToFit()
                    nodeViews.append(toAdd)
                    view.addSubview(toAdd)
                    nodesPositionDictionary[question] = CGVector(dx: x, dy: y)
                    nodesAccessDictionary[question] = toAdd
                }
                if let compoundQuestion = node as? DecisionEngine.CompoundQuestion {
                    let toAdd = CompoundQueryNode(label: compoundQuestion.id, questions: compoundQuestion.questions, needed: compoundQuestion.needed, engine: decisionEngine!, initialX: x, initialY: y, width: w, height: h)
                    toAdd.sizeToFit()
                    nodeViews.append(toAdd)
                    view.addSubview(toAdd)
                    nodesPositionDictionary[compoundQuestion] = CGVector(dx: x, dy: y)
                    nodesAccessDictionary[compoundQuestion] = toAdd
                }
                if let leaf = node as? DecisionEngine.Leaf {
                    let toAdd = LeafNode(result: leaf.result, engine: decisionEngine!, initialX: x, initialY: y, width: w, height: h)
                    toAdd.sizeToFit()
                    nodeViews.append(toAdd)
                    view.addSubview(toAdd)
                    nodesPositionDictionary[leaf] = CGVector(dx: x, dy: y)
                    nodesAccessDictionary[leaf] = toAdd
                }
                x += dX
            }
        }
        
        for node in tree.getAllNodes() {
            if let left = node.left {
                let lv = LineView(start: nodesPositionDictionary[node]!, end: nodesPositionDictionary[left]!);
                lineViews.append(lv);
                view.addSubview(lv);
            }
            if let right = node.right {
                let lv = LineView(start: nodesPositionDictionary[node]!, end: nodesPositionDictionary[right]!);
                lineViews.append(lv);
                view.addSubview(lv);
            }
        }
        
        for line in lineViews {
            view.sendSubviewToBack(line)
        }
        for node in nodeViews {
            view.bringSubviewToFront(node)
        }
        view.bringSubviewToFront(resetButton)
        view.bringSubviewToFront(exitButton)
    }
    
    //DecisionEngine respondin to a question being answered with the next node
    //Focus on it in the view
    func FocusOnNode(decisionEngineNode: DecisionEngine.Node)
    {
        //determine offset
        let pos = nodesPositionDictionary[decisionEngineNode];
        let offset = CGVector(dx: -pos!.dx + view.frame.width / 2, dy: -pos!.dy + view.frame.height / 2)
        
        //adjust positions of everything in scene
        for node in nodeViews {
            node.setOffset(vec: offset, animate: firstDraw)
            node.setFocused(focused: nodesAccessDictionary[decisionEngineNode] == node)
        }
        for line in lineViews {
            line.setOffset(vec: offset, animate: firstDraw)
        }
        
        firstDraw = true;
    }
    
    //button callback
    @objc func buttonPressed(_ sender: UIButton?) {
        if (sender == resetButton) {
            decisionEngine!.ClearAndStart();
        }
        if (sender == exitButton) {
            dismiss(animated: true)
        }
    }
    
    //layout of view
    func setUpAutoLayout() {
        
        exitButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        exitButton.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.centerXAnchor, constant: -space / 2).isActive = true;
        exitButton.heightAnchor.constraint(equalToConstant: yesNoButtonHeight).isActive = true;
        exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -space).isActive = true;
        
        resetButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: space / 2).isActive = true;
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
        resetButton.backgroundColor = DukeLookAndFeel.gray;
        
        exitButton.setTitleColor(DukeLookAndFeel.coolGray, for: .normal);
        exitButton.setTitleShadowColor(DukeLookAndFeel.black, for: .normal);
        exitButton.layer.borderColor = DukeLookAndFeel.coolGray.cgColor;
        exitButton.layer.borderWidth = 1;
        exitButton.backgroundColor = DukeLookAndFeel.gray;
    }
}
