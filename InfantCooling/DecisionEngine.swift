//
//  DecisionEngine.swift
//  InfantCooling
//
//  Created by Elizabeth Izatt on 11/30/18.
//  Copyright © 2018 LizIzatt. All rights reserved.
//

import Foundation


struct DecisionEngineController {
    var DecisionReachedShouldProceed: () -> Void?;
    var DecisionReachedShouldNotCool: () -> Void?;
    var NewQuestionToDisplay: (String) -> Void?;
}

class DecisionEngine {
    
    private let controller: DecisionEngineController;
    private var decisionMade = false;
    
    //individual question to be asked to user
    class Sample {
        var question = "";
        var answered = false;
        private var _pass = false;
        var pass: Bool {
            assert(answered);
            return _pass;
        }
        
        init (question : String) {
            self.question = question;
        }
        
        func SetPass(value : Bool) {
            answered = true;
            _pass = value;
        }
        
        func Reset() {
            answered = false;
            _pass = false;
        }
    }
    
    let samples:[Sample] = [
        Sample(question : "Gestation > 35 Weeks?"),
        Sample(question : "History of an acute perinatal event (abruptio placenta, cord prolapse, severe FHR abnormality (variable or late decelerations))?"),
        Sample(question : "An Apgar score &lt;5 at 10 minutes."),
        Sample(question : "Cord pH or first postnatal blood gas pH at &lt;1 hour &lt;7.0?"),
        Sample(question : "Base deficit on cord gas or first postnatal blood gas at &lt;1 hour &gt;16 mEq/L?"),
        Sample(question : "Continued need for ventilation initiated at birth and continued for at least 10 minutes>"),
        Sample(question : "Blood gas available?"),
        Sample(question : "pH between 7.0 and 7.15 AND BASE DEFICIT 10 to 15.9mEq/L?")
    ];
    
    
    init(controller: DecisionEngineController) {
        self.controller = controller;
        CheckIfShouldCool();
    }
    
    //interface for controller clearing state
    func clear() {
        for sample in samples {
            sample.Reset();
        }
    }
    
    //interface for controller answering a question, prompting the next CheckIfShouldCool call
    func AnswerQuestion(question : String, value : Bool) {
        for sample in samples {
            if (sample.question == question) {
                sample.SetPass(value: value);
            }
        }
        CheckIfShouldCool();
    }
    
    private func CheckIfShouldCool() {
        //sample references for easy of use as dictated in Cooling Criteria for Inborn and Outborn Infants
        let gestationSample = samples[0];
        let sample2 = samples[1];
        let sample3 = samples[2];
        let sample4 = samples[3];
        let sample5 = samples[4];
        let sample6 = samples[5];
        let bloodGasAvailableSample = samples[6];
        let phRangeAndBaseDeficit = samples[7];
        
        //process cooling logic from original document,
        //check each sample before usage if it is sourced, if not return after source function places request
        
        //handle gestation first
        if (!Sourced(sample: gestationSample)) {
            return;
        }
        if (!gestationSample.pass) {
            controller.DecisionReachedShouldNotCool();
            return;
        }
        
        //check which of the two paths we fall in
        if (!Sourced(sample: bloodGasAvailableSample)) {
            return;
        }
        if (!Sourced(sample: phRangeAndBaseDeficit)) {
            return;
        }
        
        //run logic, call delegates at leaves
        if (phRangeAndBaseDeficit.pass || !bloodGasAvailableSample.pass) {
            //A2:  2 and (3 or 6)
            if (!Sourced(sample: sample2)) {
                return;
            }
            if (!sample2.pass) {
                controller.DecisionReachedShouldNotCool();
                return;
            } else {
                
                if (!Sourced(sample: sample3)) {
                    return;
                }
                if (sample3.pass) {
                    controller.DecisionReachedShouldProceed();
                    return;
                }
                
                if (!Sourced(sample: sample6)) {
                    return;
                }
                if (sample6.pass) {
                    controller.DecisionReachedShouldProceed();
                    return;
                }
                controller.DecisionReachedShouldNotCool();
                return;
            }
            
        } else {
            //A1:  4 or 5
            if (!Sourced(sample: sample4)) {
                return;
            }
            if (sample4.pass) {
                controller.DecisionReachedShouldProceed();
                return;
            }
            if (!Sourced(sample: sample5)) {
                return;
            }
            if (sample5.pass) {
                controller.DecisionReachedShouldProceed();
                return;
            }
            controller.DecisionReachedShouldNotCool();
            return;
        }
    }
    
    private func Sourced(sample: Sample) -> Bool {
        if (sample.answered) {
            return true;
        }
        Source(sample: sample);
        return false;
    }
    
    private func Source(sample: Sample) {
        controller.NewQuestionToDisplay(sample.question);
    }
}
