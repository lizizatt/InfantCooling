//
//  MainViewController.swift
//  InfantCooling
//
//  Created by Elizabeth Izatt on 1/7/19.
//  Copyright © 2019 LizIzatt. All rights reserved.
//

import Foundation
import UIKit


let jsonStringStepA =
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

let jsonStringStepB =
    """
{
"questions": [
{
"id": "seizures",
"question": "Seizures?"
}
],
"compoundQuestions": [
{
"id": "neuroexam",
"needed": 3,
"questions":
["Level of Consciousness:  Patient lethargic or in stupor/coma?",
"Spontaneous Activity:  Decreased or no activity?",
"Posture: distal flexion, complete extension or decerebrate?",
"Tone: Hypotonia (focal or general), flaccid, or rigid?",
"Primtivie Reflexes:  Suck weak, has bite, or absent? OR Moro incomplete or absent?",
"Autonomic system:  Pupils constricted or deviated/deliated/non-reactive? OR Heart rate bradycardia or variable? OR Periodic breathing or apnea or requiring ventilator?"
]
}
],
"leaves": [
{
"id": "DoNotCool",
"result": "Do not cool infant"
},
{
"id": "Proceed",
"result": "Proceed to cooling"
}
],
"branches": [
{
"question": "seizures",
"pass": "Proceed",
"fail": "neuroexam"
},
{
"question": "neuroexam",
"pass": "Proceed",
"fail": "DoNotCool"
}
]
}
"""


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var treesTableView: UITableView!
    var treesTableViewLabel: UILabel!
    var disclaimersTableView: UITableView!
    
    private let space : CGFloat = 5;
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == treesTableView) {
            return 2;
        }
        
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell();
        
        if (tableView == treesTableView) {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Step A"
            case 1:
                cell.textLabel?.text = "Step B"
            default:
                break
            }
        }
        
        cell.textLabel?.textColor = DukeLookAndFeel.coolGray
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = DukeLookAndFeel.blueSecondaryFaded
        cell.selectedBackgroundView = backgroundView
        
        cell.backgroundColor = UIColor.clear;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == treesTableView) {
            switch indexPath.row {
            case 0:
                self.present(DecisionViewController(jsonString: jsonStringStepA), animated: true)
            case 1:
                self.present(DecisionViewController(jsonString: jsonStringStepB), animated: true)
            default:
                break;
            }
        }
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        treesTableViewLabel = UILabel(frame: view.frame)
        treesTableView = UITableView(frame: view.frame)
        disclaimersTableView = UITableView(frame: view.frame)
        
        view.addSubview(treesTableViewLabel)
        view.addSubview(treesTableView)
        view.addSubview(disclaimersTableView)
        
        treesTableView.delegate = self;
        treesTableView.dataSource = self;

        disclaimersTableView.delegate = self;
        disclaimersTableView.dataSource = self;
        
        view.backgroundColor = DukeLookAndFeel.black;
        treesTableView.backgroundColor = UIColor.clear;
        disclaimersTableView.backgroundColor = UIColor.clear;
        
        treesTableViewLabel.textColor = DukeLookAndFeel.coolGray
        treesTableViewLabel.text = "Infant Cooling"
        
        setUpAutoLayout()
    }
    
    func setUpAutoLayout() {
        
        let labelHeight = 0.1 * view.frame.height
        let treesListHeight = 0.75 * view.frame.height
        let disclaimersListHeight = 0.15 * view.frame.height
        
        treesTableViewLabel.translatesAutoresizingMaskIntoConstraints = false
        treesTableView.translatesAutoresizingMaskIntoConstraints = false
        disclaimersTableView.translatesAutoresizingMaskIntoConstraints = false
        
        treesTableViewLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        treesTableViewLabel.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor, constant: -space).isActive = true;
        treesTableViewLabel.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true;
        treesTableViewLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: space).isActive = true;
        
        treesTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        treesTableView.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor, constant: -space).isActive = true;
        treesTableView.heightAnchor.constraint(equalToConstant: treesListHeight).isActive = true;
        treesTableView.topAnchor.constraint(equalTo: treesTableViewLabel.bottomAnchor, constant: space).isActive = true;
        
        disclaimersTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: space).isActive = true;
        disclaimersTableView.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor, constant: -space).isActive = true;
        disclaimersTableView.heightAnchor.constraint(equalToConstant: disclaimersListHeight).isActive = true;
        disclaimersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -space).isActive = true;
        
    }
    
}
