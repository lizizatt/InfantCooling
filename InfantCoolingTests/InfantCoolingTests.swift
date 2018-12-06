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
    
    private var didRecieveProceedCallback = false;
    private var didRecieveFailCallback = false;
    private var didRecieveQuestionCallback = false;
    private var question = "";
    
    override func setUp() {
        dc = DecisionEngineController(DecisionReachedShouldProceed: ProceedCallback, DecisionReachedShouldNotCool: FailCallback, NewQuestionToDisplay: QuestionCallback);
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
            XCTAssert(!didRecieveFailCallback, "Should not have recieved fail callback");
            XCTAssert(!didRecieveProceedCallback, "Should not have recieved proceed callback");
            
            //reset flag
            didRecieveQuestionCallback = false;
            
            
            while (true) {
                //answer true to everything, making sure we eventually get a proceed or fail callback
                engine.AnswerQuestion(question: question, value: true);
                
                if (didRecieveQuestionCallback) {
                    didRecieveQuestionCallback = false;
                    continue;
                }
                
                if (didRecieveFailCallback) {
                    XCTAssert(!didRecieveQuestionCallback, "Should not have recieved a question callback");
                    XCTAssert(!didRecieveProceedCallback, "Should not have recieved proceed callback");
                    didRecieveFailCallback = false;
                    break;
                }
                
                
                if (didRecieveProceedCallback) {
                    XCTAssert(!didRecieveQuestionCallback, "Should not have recieved a question callback");
                    XCTAssert(!didRecieveFailCallback, "Should have recieved fail callback");
                    didRecieveProceedCallback = false;
                    break;
                }
                
                XCTAssert(false, "Should have recieved a callback of some sort");
            }
            
        } else {
            XCTAssert(false, "Engine not resolved.");
        }
    }
    
    func ProceedCallback() {
        didRecieveProceedCallback = true;
    }
    
    func FailCallback() {
        didRecieveFailCallback = true;
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
