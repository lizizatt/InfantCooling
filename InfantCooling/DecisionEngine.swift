//
//  DecisionEngine.swift
//  InfantCooling
//
//  Created by Elizabeth Izatt on 11/30/18.
//  Copyright © 2018 LizIzatt. All rights reserved.
//

import Foundation
import UIKit


struct DecisionEngineController {
    var SetUpTree: (DecisionEngine.Tree) -> Void;
    var FocusOnNode: (DecisionEngine.Node) -> Void;
}

class DecisionEngine {
    
    private let controller: DecisionEngineController;
    
    private var tree : Tree?
    private var currentBranch : Branch?
    private var hasCalledSetUpTree = false;
    
    //json format
    class Node : Hashable {
        var maxDepth : Int = -1;
        var parent : Node?;
        var left : Node?;
        var right : Node?;
        
        static func == (lhs: Node, rhs: Node) -> Bool {
            return lhs.getID() == rhs.getID() && lhs.getID() == rhs.getID()
        }
        
        func getID() -> String {
            return "";
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(getID())
        }
    }

    class Tree: Decodable {
        let questions: [Question]
        let leaves: [Leaf]
        let branches: [Branch]
        
        init(questions: [Question], leaves: [Leaf], branches: [Branch]) {
            self.questions = questions
            self.leaves = leaves
            self.branches = branches
        }
        
        func SetUpTree() {
            //link tree
            for branch in branches {
                let questionInQuestion = getQuestion(withId: branch.question)
                let answerYNode = getNode(withId: branch.pass);
                let answerNNode = getNode(withId: branch.fail);
                
                if (questionInQuestion == nil
                    || answerYNode == nil
                    || answerNNode == nil) {
                    print("Malformed tree detected\n")
                    assert(false);
                    continue;
                }
                
                questionInQuestion?.left = answerYNode;
                questionInQuestion?.right = answerNNode;
                
                answerYNode?.parent = questionInQuestion;
                answerNNode?.parent = questionInQuestion;
            }
            
            //determine max depth value for all nodes
            if (branches.count > 0) {
                var nodeStack = [getNode(withId: branches[0].question)];
                var nodeDepthStack = [0];
                
                while (nodeStack.count > 0) {
                    let node : Node? = nodeStack.popLast()!;
                    let depth = nodeDepthStack.popLast()!;
                    
                    if let node = node {
                        if (depth > node.maxDepth) {
                            node.maxDepth = depth;
                        }
                        
                        nodeStack.append(node.left)
                        nodeDepthStack.append(depth + 1)
                        nodeStack.append(node.right)
                        nodeDepthStack.append(depth + 1)
                        
                    }
                }
            }
            else {
                print("No tree parsed\n")
                assert(false);
            }
        }
        
        func getQuestion(withId : String) -> Question? {
            for question in questions {
                if question.getID().lowercased() == withId.lowercased() {
                    return question;
                }
            }
            return nil;
        }
        
        func getLeaf(withId : String) -> Leaf? {
            for leaf in leaves {
                if leaf.getID().lowercased() == withId.lowercased() {
                    return leaf;
                }
            }
            return nil;
        }
        
        func getNode(withId : String) -> Node? {
            let ques = getQuestion(withId: withId);
            let leaf = getLeaf(withId: withId);
            if ques != nil {
                return ques;
            }
            return leaf;
        }
    }
    class Question: Node, Decodable {
        let id : String;
        let question : String;
        
        override func getID() -> String {
            return id;
        }
    }
    class Leaf: Node, Decodable {
        let id : String;
        let result : String;
        
        override func getID() -> String {
            return id;
        }
    }
    class Branch: Decodable {
        let question: String
        let pass: String
        let fail: String
    }
    
    
    let jsonString =
    """
    {
    "questions": [
        {
            "id": "Gestation",
            "question": "Gestation > 35 Weeks?"
        },
        {
            "id": "q2",
            "question": "Acute perinatal event?"
        },
        {
            "id": "q3",
            "question": "Apgar <= 5 at 10 minutes"
        },
        {
            "id": "q4",
            "question": "pH =< 7.0 at < 1 hour"
        },
        {
            "id": "q5",
            "question": "Base deficit >= 16 mEq/L at < 1 hour"
        },
        {
            "id": "q6",
            "question": "Needed ventilation at least 10 minutes since birth?"
        },
        {
            "id": "BloodGas",
            "question": "Blood gas available?"
        },
        {
            "id": "phRange",
            "question": "7.0 < pH < 7.15"
        },
        {
            "id": "BaseDeficitRange",
            "question": "10 < base deficit < 15.9mEq/L"
        }
    ],
    "leaves": [
        {
            "id": "DoNotCool",
            "result": "Do not cool infant"
        },
        {
            "id": "Proceed",
            "result": "Proceed to neurological evaluation"
        }
    ],
    "branches": [
        {
            "question": "Gestation",
            "pass": "BloodGas",
            "fail": "doNotCool"
        },
        {
            "question": "BloodGas",
            "pass": "phRange",
            "fail": "q2"
        },
        {
            "question": "phRange",
            "pass": "BaseDeficitRange",
            "fail": "q4"
        },
        {
            "question": "BaseDeficitRange",
            "pass": "q2",
            "fail": "q4"
        },
        {
            "question": "q2",
            "pass": "q3",
            "fail": "DoNotCool"
        },
        {
            "question": "q3",
            "pass": "Proceed",
            "fail":"q6"
        },
        {
            "question": "q6",
            "pass": "Proceed",
            "fail": "DoNotCool"
        },
        {
            "question": "q4",
            "pass": "Proceed",
            "fail": "q5"
        },
        {
            "question": "q5",
            "pass": "Proceed",
            "fail": "DoNotCool"
        }
    ]
}
"""
    
    init(controller: DecisionEngineController) {
        self.controller = controller;
        
        //load json tree descriptor
        
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        tree = try! decoder.decode(Tree.self, from: jsonData)
        
        //should have Tree now, start the first branch
        currentBranch = tree?.branches[0];
    }
    
    
    //interface for controller clearing state, prompting the next CheckIfShouldCool call
    func ClearAndStart() {
        currentBranch = tree?.branches[0];
        
        if (!hasCalledSetUpTree) {
            tree?.SetUpTree();
            controller.SetUpTree(tree!);
            hasCalledSetUpTree = true;
        }
        
        AskQuestion();
    }
    
    //interface for controller providing the answer to the most recently requested question
    func AnswerQuestion(question : String, value : Bool) {
        
        if let tree = tree {
            let toFind = value ? currentBranch?.pass : currentBranch?.fail;
            
            //check leaves
            for leaf in tree.leaves {
                if (leaf.id.lowercased() == toFind?.lowercased()) {
                    controller.FocusOnNode(leaf);
                    return;
                }
            }
            
            //check branches
            for branch in tree.branches {
                if (branch.question.lowercased() == toFind?.lowercased()) {
                    currentBranch = branch
                    AskQuestion();
                    return;
                }
            }
        }
        assert(false);
    }
    
    func AskQuestion() {
        if let tree = tree {
            for question in tree.questions {
                if (question.id == currentBranch?.question) {
                    controller.FocusOnNode(question);
                    return;
                }
            }
        }
        assert(false);
    }
}
