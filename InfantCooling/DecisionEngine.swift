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
    var DecisionReached: (String) -> Void?;
    var NewQuestionToDisplay: (String) -> Void?;
}

class DecisionEngine {
    
    private let controller: DecisionEngineController;
    
    private var tree : Tree?
    private var currentBranch : Branch?
    
    //json format
    struct Tree: Decodable {
        let questions: [Question]
        let leaves: [Leaf]
        let branches: [Branch]
        
        init(questions: [Question], leaves: [Leaf], branches: [Branch]) {
            self.questions = questions
            self.leaves = leaves
            self.branches = branches
        }
    }
    struct Question: Decodable {
        let id : String;
        let question : String;
    }
    struct Leaf: Decodable {
        let id : String;
        let result : String;
    }
    struct Branch: Decodable {
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
        AskQuestion();
    }
    
    //interface for controller clearing state, prompting the next CheckIfShouldCool call
    func Clear() {
        currentBranch = tree?.branches[0];
        AskQuestion();
    }
    
    //interface for controller providing the answer to the most recently requested question
    func AnswerQuestion(value : Bool) {
        if let tree = tree {
            let toFind = value ? currentBranch?.pass : currentBranch?.fail;
            
            //check leaves
            for leaf in tree.leaves {
                if (leaf.id.lowercased() == toFind?.lowercased()) {
                    controller.DecisionReached(leaf.result);
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
                    controller.NewQuestionToDisplay(question.question);
                    return;
                }
            }
        }
        assert(false);
    }
}
