//
//  InfantCoolingTests.swift
//  InfantCoolingTests
//
//  Created by Elizabeth Izatt on 11/25/18.
//  Copyright © 2018 LizIzatt. All rights reserved.
//

import XCTest
@testable import InfantCooling

class InfantCoolingTests: XCTestCase {

    var dc : DecisionEngineController?;
    var engine : DecisionEngine?;
    
    private var didRecieveDecisionCallback = false;
    private var decision = "";
    private var didRecieveQuestionCallback = false;
    private var question = "";
    
    override func setUp() {
        didRecieveQuestionCallback = false;
        didRecieveDecisionCallback = false;
        decision = "";
        question = "";
        
        dc = DecisionEngineController(DecisionReached: DecisionCallback, NewQuestionToDisplay: QuestionCallback);
        if let dcResolved = dc {
            engine = DecisionEngine(controller: dcResolved);
        }
    }

    override func tearDown() {
        dc = nil;
        engine = nil;
    }

    func testBasic() {
        if let engine = engine {
            
            //init should have created the first question callback and nothing else
            XCTAssert(didRecieveQuestionCallback, "Should have recieved question callback");
            XCTAssert(!didRecieveDecisionCallback, "Should not have recieved decision callback");
            
            
            while (true) {
                //answer true to everything, making sure we eventually get a proceed or fail callback
                engine.AnswerQuestion(value: true);
                
                if (didRecieveQuestionCallback) {
                    didRecieveQuestionCallback = false;
                    continue;
                }
                
                if (didRecieveDecisionCallback) {
                    XCTAssert(!didRecieveQuestionCallback, "Should not have recieved a question callback");
                    didRecieveDecisionCallback = false;
                    break;
                }
                
                XCTAssert(false, "Should have recieved a callback of some sort");
            }
            
        } else {
            XCTAssert(false, "Engine not     resolved.");
        }
    }
    
    func DecisionCallback(decision : String) {
        didRecieveDecisionCallback = true;
        self.decision = decision;
    }
    func QuestionCallback(question : String) {
        didRecieveQuestionCallback = true;
        self.question = question;
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
