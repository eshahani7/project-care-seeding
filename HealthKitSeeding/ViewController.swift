//
//  ViewController.swift
//  HealthKitSeeding
//
//  Created by Ekta Shahani on 2/24/18.
//  Copyright © 2018 Ekta Shahani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let seeder:Seeder = Seeder()
    
    @IBAction func SeedSteps(_ sender: UIButton) {
        print("button pressed")
        seeder.seedSteps(daysPrior: 0, steps: 5540)
        seeder.seedSteps(daysPrior: 1, steps: 8000)
        seeder.seedSteps(daysPrior: 2, steps: 9000)
        seeder.seedSteps(daysPrior: 3, steps: 6000)
        seeder.seedSteps(daysPrior: 4, steps: 7000)
        seeder.seedSteps(daysPrior: 5, steps: 11000)
        seeder.seedSteps(daysPrior: 6, steps: 9700)
    }
    
    @IBAction func SeedExercise(_ sender: UIButton) {
        print("button pressed")
        seeder.seedExerciseTime(daysPrior: 0, exerciseMins: 10)
        seeder.seedExerciseTime(daysPrior: 1, exerciseMins: 20)
        seeder.seedExerciseTime(daysPrior: 2, exerciseMins: 22)
        seeder.seedExerciseTime(daysPrior: 3, exerciseMins: 0)
        seeder.seedExerciseTime(daysPrior: 4, exerciseMins: 17)
        seeder.seedExerciseTime(daysPrior: 5, exerciseMins: 32)
        seeder.seedExerciseTime(daysPrior: 6, exerciseMins: 8)
    }
    
    @IBAction func SeedSleep(_ sender: UIButton) {
        print("button pressed")
        seeder.seedSleep(daysPrior: 0, hoursSlept: 7)
        seeder.seedSleep(daysPrior: 1, hoursSlept: 8)
        seeder.seedSleep(daysPrior: 2, hoursSlept: 6)
        seeder.seedSleep(daysPrior: 3, hoursSlept: 9.4)
        seeder.seedSleep(daysPrior: 4, hoursSlept: 7.8)
        seeder.seedSleep(daysPrior: 5, hoursSlept: 5.4)
        seeder.seedSleep(daysPrior: 6, hoursSlept: 8.7)
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        Seeder.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
    
            print("HealthKit Successfully Authorized.")
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

