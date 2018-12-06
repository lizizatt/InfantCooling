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
    var DecisionReachedShouldProceed: () -> Void?;
    var DecisionReachedShouldNotCool: () -> Void?;
    var NewQuestionToDisplay: (String) -> Void?;
}

class DecisionEngine {
    
    private let controller: DecisionEngineController;
    
    private var tree : DecisionEngine.Tree?
    private var currentBranch : Branch?
    
    //json format
    struct Tree: Decodable {
        let questions: [Question]
        let leaves: [Leaf]
        let branches: [Branch]
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
    
    
    init(controller: DecisionEngineController) {
        self.controller = controller;
        
        //load json tree descriptor
        
        let asset = NSDataAsset(name: "tree", bundle: Bundle.main)
        
        if asset != nil {
            if let data = asset?.data {
                let decoder = JSONDecoder()
                guard let treeParsed = try? decoder.decode(Tree.self, from: data) else {
                    print("Error: Couldn't decode data into Tree")
                    exit(1)
                }
                //success!
                self.tree = treeParsed
            } else {
                print("Error: data invalid")
                exit(1)
            }
        } else {
            print("Error: Couldn't find tree.json")
            exit(1)
        }
        
        //should have Tree now, start the first branch
        currentBranch = tree?.branches[0];
        AskQuestion();
    }
    
    //interface for controller clearing state, prompting the next CheckIfShouldCool call
    func Clear() {
    }
    
    //interface for controller providing the answer to the most recently requested question
    func AnswerQuestion(value : Bool) {
        if let tree = tree {
            let toFind = value ? currentBranch?.pass : currentBranch?.fail;
            for branch in tree.branches {
                if (branch.question == toFind) {
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
