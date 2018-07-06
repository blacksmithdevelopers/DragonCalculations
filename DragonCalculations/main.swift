//
//  main.swift
//  DragonCalculations
//
//  Created by Matthew Elmore on 7/5/18.
//  Copyright © 2018 Matthew Elmore. All rights reserved.
//

import Foundation

struct EngineOut {
    private var currentAlt = 0.0 //ipad gives alt in meters
    private var ktJet = 0.0
    private var fuelRemaining = 100.0  //Gallons
    private var config: Configuration = .slickGearUp
    private var correction: Corrections = .none
    private var currentWeight: Double = 0.0
    
    // TODO: Function for Calculating HiKey Altitude based on Field Diverting
    // function for calculating distance from current position to HiKey
    
    
    init(currentAlt: Double,
         ktJet: Double,
         fuelRemaining: Double,
         config: Configuration,
         correction: Corrections) {
        self.currentAlt = currentAlt
        self.ktJet = ktJet
        self.fuelRemaining = fuelRemaining
        self.currentWeight  = self.totalCurrentWeight()
        self.config = config
        self.correction = correction
    }
    
    enum Configuration: Double {
        case slickGearUp = 37.0
        case slickGearDown = 31.0
        case superPodsGearUp = 34.0
        case superPodsGearDown = 29.0
        case pegGearUp = 32.0
        case pegGearDown = 27.0
    }
    
    enum Corrections: Double {
        case none = 0.0
        case gustUp = -1.0
        case speedBrakeOutGearUp = -10.0
        case speedBrakeOutGearDown = -8.0
        case spoilersUpGearUp = -15.00001 //the extended decimal is nominal and just to make the enum have unique raw values
        case spoilersUpGearDown = -12.0
        case spoilersUpAndSpeedBrakeOutGearUp = -18.0
        case spoilersUpAndSpeedBrakeOutGearDown = -15.00002 //the extended decimal is nominal and just to make the enum have unique raw values
    }
    
    public func glideDistance() -> Double {
        let altAdj = self.currentAlt / 10000
        let glideFactor = config.rawValue + correction.rawValue
        let result = glideFactor*altAdj
        return result
    }
    
    private func totalCurrentWeight() -> Double {
        let zfw = 18700.0
        let gasWeight = 6.5 //per gallon
        let jet = (self.ktJet * 650.0) + zfw
        let fuelWeight = gasWeight * self.fuelRemaining
        let totalWeight = jet + fuelWeight
        return totalWeight
    }
    
    public func altLossAt_20_DegreesAngleOfBankFor(degrees: Double) -> Double {
        let altFor180 = (0.0144*self.currentWeight) + 78 //Extrapolated using Excel (Linear Formula) and Figure 3-2 in -1
        let altPerDegree = altFor180/180
        let alt = altPerDegree * degrees
        return alt
    }
    
    public func altLossAt_30_DegreesAngleOfBankFor(degrees: Double) -> Double {
        let altFor180 = (0.0104*self.currentWeight) + 50 //Extrapolated using Excel (Linear Formula) and Figure 3-2 in -1
        let altPerDegree = altFor180/180
        let alt = altPerDegree * degrees
        return alt
    }
    
    public func timeForTurnAt_20_DegreesAngleOfBankFor(degrees: Double) -> Double {
        let timeFor180 = (0.0007*self.currentWeight) + 28.8 //Extrapolated using Excel (Linear Formula) and Figure 3-2 in -1
        let timePerDegree = timeFor180/180
        let alt = timePerDegree * degrees
        return alt
    }
    
    public func timeForTurnAt_30_DegreesAngleOfBankFor(degrees: Double) -> Double {
        let timeFor180 = (0.0004*self.currentWeight) + 17.6 //Extrapolated using Excel (Linear Formula) and Figure 3-2 in -1
        let timePerDegree = timeFor180/180
        let alt = timePerDegree * degrees
        return alt
    }
    
    public func altLossAfter30SecondsOfTurnAt_20_DegreesAngleOfBankFor(seconds: Double) -> Double {
        let altFor30sec = (0.0046*self.currentWeight) + 176 //Extrapolated using Excel (Linear Formula) and Figure 3-2 in -1
        let altPerSec = altFor30sec/30
        let alt = altPerSec * seconds
        return alt
    }
    
    public func altLossAfter30SecondsOfTurnAt_30_DegreesAngleOfBankFor(seconds: Double) -> Double {
        let altFor30sec = (0.0056*self.currentWeight) + 180 //Extrapolated using Excel (Linear Formula) and Figure 3-2 in -1
        let altPerSec = altFor30sec/30
        let alt = altPerSec * seconds
        return alt
    }
    
    public func altLossCorrectionFactorPer1FtAboveSeaLevel(alt: Double) -> Double {
        return alt * 1.00003 //-1 says 3% for each 1000ft, this is taken down to 1ft for a continuous conversion
    }
    
    public func altLossCorrectionFactorForEachDegreeCelciusAboveStandardDay(tempDev: Double) -> Double {
        return tempDev * 1.003 //-1 says 3% for each 10°, this is taken down to 1°
    }
    
    public func minSinkAirspeedWithFuel(_ gal: Double, ktJet: Double) -> Double {
        return gal/100 + 90 + ktJet
    }
    
    public func bestGlideAirspeedWithFuel(_ gal: Double, ktJet: Double) -> Double {
        return gal/100 + 105 + ktJet
    }
    
}
let turn: Double = 180
let time: Double = 1
let currentAlt: Double = 65000
let ktJet: Double = 0
let fuelRemaining: Double = 500
let config: EngineOut.Configuration = .pegGearDown
let correction: EngineOut.Corrections = .speedBrakeOutGearUp

let newSit = EngineOut(currentAlt: currentAlt,
                       ktJet: ktJet,
                       fuelRemaining: fuelRemaining,
                       config: config,
                       correction: correction)
print("****************SETUP**********************")
print("Knot Jet: \(ktJet)")
print("Fuel remaining: \(fuelRemaining)")
print("Current Altitude: \(currentAlt)")
print(config)
print(correction)
print("****************RESULTS**********************")
print("Alt loss for \(time) seconds at 20° AOB: \(newSit.altLossAfter30SecondsOfTurnAt_20_DegreesAngleOfBankFor(seconds: time)) ft")
print("Alt loss for \(time) seconds at 30° AOB: \(newSit.altLossAfter30SecondsOfTurnAt_30_DegreesAngleOfBankFor(seconds: time)) ft")
print("Alt loss 20° AOB for 180°: \(newSit.altLossAt_20_DegreesAngleOfBankFor(degrees: turn)) ft")
print("Alt loss 30° AOB for 180°: \(newSit.altLossAt_30_DegreesAngleOfBankFor(degrees: turn)) ft")
print("Time to turn \(turn)° at 20° AOB: \(newSit.timeForTurnAt_20_DegreesAngleOfBankFor(degrees: turn)) seconds")
print("Time to turn \(turn)° at 30° AOB: \(newSit.timeForTurnAt_30_DegreesAngleOfBankFor(degrees: turn)) seconds")
print("Glide distance from \(currentAlt) ft: \(newSit.glideDistance()) NM")
print("*********************************************")




