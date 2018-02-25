//
//  SeedData.swift
//  HealthKitSeeding
//
//  Created by Ekta Shahani on 2/24/18.
//  Copyright © 2018 Ekta Shahani. All rights reserved.
//

import Foundation
import HealthKit

struct HealthValues {
    static let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
    static let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
    static let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)
    static let height = HKObjectType.quantityType(forIdentifier: .height)
    static let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)
    static let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    static let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)
    static let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
    static let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
    static let respRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate)
    static let workouts = HKObjectType.workoutType()
    static let sleepHours = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
}

class Seeder {
    let store:HKHealthStore?
    private let dayInterval:Double = -86400
    
    private enum HealthStoreErrors : Error {
        case noHealthDataFound
        case noAgeFound
        case noSexEntered
    }
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    public static func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard   let dateOfBirth = HealthValues.dateOfBirth,
            let biologicalSex = HealthValues.biologicalSex,
            let bodyMassIndex = HealthValues.bodyMassIndex,
            let height = HealthValues.height,
            let bodyMass = HealthValues.bodyMass,
            let activeEnergy = HealthValues.activeEnergy,
            let exerciseTime = HealthValues.exerciseTime,
            let stepCount = HealthValues.stepCount,
            let heartRate = HealthValues.heartRate,
            let sleepHours = HealthValues.sleepHours,
            let respRate = HealthValues.respRate else {
                
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        let writeTypes: Set<HKSampleType> = [stepCount,
                                             HKObjectType.workoutType(),
                                             heartRate,
                                             sleepHours]
        
        let readTypes: Set<HKObjectType> = [activeEnergy,
                                            dateOfBirth,
                                            biologicalSex,
                                            bodyMassIndex,
                                            height,
                                            bodyMass,
                                            exerciseTime,
                                            stepCount,
                                            heartRate,
                                            respRate,
                                            sleepHours,
                                            HKObjectType.workoutType()]
        
        HKHealthStore().requestAuthorization(toShare: writeTypes, read: readTypes, completion: { (success, error) in
            completion(success, error)
        })
    }
    
    init() {
        if(HKHealthStore.isHealthDataAvailable()) {
            store = HKHealthStore()
            print("data found")
        } else {
            print("no data")
            store = nil
        }
    }
    
    public func seedSteps(daysPrior: Double, steps: Double) -> Void {
        let steps = HKQuantity(unit: HKUnit.count(), doubleValue: steps)
        let stepSample = HKQuantitySample(type: HealthValues.stepCount!, quantity: steps, start: Date().addingTimeInterval(daysPrior * dayInterval), end: Date().addingTimeInterval(daysPrior * dayInterval))
        
        store?.save(stepSample) { (success, error) in
            
            if let error = error {
                print("Error Saving step: \(error.localizedDescription)")
            } else {
                print("Successfully saved step sample")
            }
        }
    }
    
    public func seedSleep(daysPrior: Double, hoursSlept: Double) -> Void {
        let start = Calendar.current.startOfDay(for: Date().addingTimeInterval(daysPrior * dayInterval))
        let end = start.addingTimeInterval(hoursSlept*60*60)
        
        let sleepSample = HKCategorySample(type: HealthValues.sleepHours!, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: start, end: end)
        
        store?.save(sleepSample) { (success, error) in
            
            if let error = error {
                print("Error Saving step: \(error.localizedDescription)")
            } else {
                print("Successfully saved sleep sample")
            }
        }
    }
    
    public func seedExerciseTime(daysPrior: Double, exerciseMins: Double) -> Void {
        let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 200)
        let distQuantity = HKQuantity(unit: HKUnit.mile(), doubleValue: 4)
        
        let workout = HKWorkout(activityType: .running,
                                start: Date().addingTimeInterval(daysPrior * dayInterval),
                                end: Date().addingTimeInterval(daysPrior * dayInterval),
                                duration: exerciseMins * 60,
                                totalEnergyBurned: calorieQuantity,
                                totalDistance: distQuantity,
                                device: HKDevice.local(),
                                metadata: nil)
        
        store?.save(workout) { (success, error) in
            
            if let error = error {
                print("Error Saving step: \(error.localizedDescription)")
            } else {
                var samples: [HKQuantitySample] = []
                let heartRateUnit = HKUnit(from: "count/min")
                let heartRateQuantity = HKQuantity(unit: heartRateUnit, doubleValue: 95)
                let heartRateForIntervalSample =
                    HKQuantitySample(type: HealthValues.heartRate!, quantity: heartRateQuantity,
                                     start: Date(), end: Date())
                let heartRateForIntervalSample2 =
                    HKQuantitySample(type: HealthValues.heartRate!, quantity: heartRateQuantity,
                                     start: Date().addingTimeInterval(20), end: Date().addingTimeInterval(40))
                samples.append(heartRateForIntervalSample)
                samples.append(heartRateForIntervalSample2)
                
                self.store?.add(samples, to: workout) {
                    (success, error) in
                    
                    if let error = error {
                        print("can't save heart rate")
                        print(error)
                    } else {
                        print("saved heart rate")
                    }
                }
                print("Successfully saved exercise sample")
            }
        }

    }
}
