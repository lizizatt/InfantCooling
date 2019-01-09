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
        let compoundQuestions: [CompoundQuestion]?
        let leaves: [Leaf]
        let branches: [Branch]
        
        init(questions: [Question], compoundQuestions: [CompoundQuestion], leaves: [Leaf], branches: [Branch]) {
            self.questions = questions
            self.compoundQuestions = compoundQuestions
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
        
        func getAllNodes() -> [Node] {
            var toRet : [Node] = []
            for question in questions {
                toRet.append(question)
            }
            if let compoundQuestions = compoundQuestions {
                for compoundQuestion in compoundQuestions {
                    toRet.append(compoundQuestion)
                }
            }
            for leaf in leaves {
                toRet.append(leaf)
            }
            return toRet;
        }
        
        func getMaxDepth() -> Int {
            var max = -1;
            for node in getAllNodes() {
                if node.maxDepth > max {
                    max = node.maxDepth;
                }
            }
            return max;
        }
        
        func getQuestion(withId : String) -> Node? {
            for question in questions {
                if question.getID().lowercased() == withId.lowercased() {
                    return question;
                }
            }
            if let compoundQuestions = compoundQuestions {
                for question in compoundQuestions {
                    if question.getID().lowercased() == withId.lowercased() {
                        return question;
                    }
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
    class CompoundQuestion: Node, Decodable {
        let id : String;
        let needed : Int;
        let questions : [String];
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
    
    init(controller: DecisionEngineController, jsonString : String) {
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
    func AnswerQuestion(value : Bool) {
        
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
            if let compoundQuestions = tree.compoundQuestions {
                for compoundQuestion in compoundQuestions {
                    if (compoundQuestion.id == currentBranch?.question) {
                        controller.FocusOnNode(compoundQuestion);
                        return;
                    }
                }
            }
        }
        assert(false);
    }
}
