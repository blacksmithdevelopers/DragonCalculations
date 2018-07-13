//
//  main.swift
//  DragonCalculations
//
//  Created by Matthew Elmore on 7/5/18.
//  Copyright © 2018 Matthew Elmore. All rights reserved.
//

import Foundation

// MARK: - Extensions
extension Double {
    var radiansToDegrees: Double { return self * 180/Double.pi }
    var degreesToRadians: Double { return self * Double.pi/180 }
}
extension Formatter {
    static let avoidNotation: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
}

extension Double {
    var avoidNotation: String {
        return Formatter.avoidNotation.string(for: self) ?? ""
    }
}

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
    
    
    // MARK: - Glide Stuff
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
    
    //AIRSPEED FUNCTIONS WAG Calculations
    func glideSpeed(_ totalGallons: Int,_ knotCorrection: Double) -> Double {
        let glideSpeed = ((Double(totalGallons - 60)/100)+105.0)+knotCorrection
        print(glideSpeed)
        return glideSpeed
    }
    func minSinkSpeed(_ totalGallons: Int,_ knotCorrection: Double) -> Double {
        let minSinkSpeed = ((Double(totalGallons - 60)/100)+90.0)+knotCorrection
        print(minSinkSpeed)
        return minSinkSpeed
    }
    func flaps_0_Speed(_ totalGallons: Int,_ knotCorrection: Double) -> Double {
        let flaps_0_Speed = ((Double(totalGallons - 60)/100)+75.0)+knotCorrection
        print(flaps_0_Speed)
        return flaps_0_Speed
    }
    func flaps_35_Speed(_ totalGallons: Int,_ knotCorrection: Double) -> Double {
        let flaps_35_Speed = ((Double(totalGallons - 60)/100)+70.0)+knotCorrection
        print(flaps_35_Speed)
        return flaps_35_Speed
    }
    func ZFW_Correction(_ ZFW: Int) -> Double {
        let knotCorrection = (Double(ZFW)-18700.0)/650
        print(knotCorrection)
        return knotCorrection
    }
    func timeToTransferfuel_WingToWing(_ numberOfGallonsToTransfer: Int) -> Double{
        let timeToTransfer = Double(numberOfGallonsToTransfer) / 7
        print(timeToTransfer)
        return timeToTransfer
    }
    func timeToTransferfuel_WingToSump(_ numberOfGallonsToTransfer: Int) -> Double{
        let timeToTransfer = Double(numberOfGallonsToTransfer) / 14
        print(timeToTransfer)
        return timeToTransfer
    }
    func timeToDumpRate_InBoards(_ numberOfGallonsToDump: Int) -> Double {
        let timeToDump = Double(numberOfGallonsToDump) / 75
        print(timeToDump)
        return timeToDump
    }
    func timeToDumpRate_OutBoards(_ numberOfGallonsToDump: Int) -> Double {
        let timeToDump = Double(numberOfGallonsToDump) / 60
        print(timeToDump)
        return timeToDump
    }
    
    
}



struct u2TOLD {
    
    // MARK: - TOLD Conditions
    enum RunwayCondition {
        case dry
        case wet
        case snow
        case ice
    }
    
    // MARK: - Formulas are best trend line from excel
    func airspeeds(fuelInGallons: Double, startTaxiTO: Double, ktJet: Double) -> (bestGlide: Double, minSink: Double, flapsUp: Double, flaps35: Double) {
        let gallonsUsedBestGlide = fuelInGallons - startTaxiTO
        //Best Glide
        let bestGlide = (0.0101 * gallonsUsedBestGlide) + 104.65 + ktJet
        //Min Sink
        let minSink = (0.0101 * gallonsUsedBestGlide) + 89.649 + ktJet
        //0° Flaps
        let flapsUp = (0.0101 * gallonsUsedBestGlide) + 74.649 + ktJet
        //35° Flaps
        let flaps35 = (0.0101 * gallonsUsedBestGlide) + 69.649 + ktJet
        return (bestGlide: bestGlide, minSink: minSink, flapsUp: flapsUp, flaps35: flaps35)
    }
    
    private func takeOffTempCorrectionFor(tempInF: Double, numberToApplyCorrection: Double) -> Double {
        let tempCorrectionPerDegree = 0.0026
        let tempAbove59: Double = {
            if tempInF < 59 {
                return 0.0
            } else {
                return tempInF - 59.0
            }
        }()
        return (numberToApplyCorrection + (numberToApplyCorrection) * (tempAbove59 * tempCorrectionPerDegree))
    }
    private func takeOffAltCorrectionFor(altAboveSL: Double, numberToApplyCorrection: Double) -> Double {
        //I'm Assuming a typo and its Sealevel not Field Elevation
        return (numberToApplyCorrection + (numberToApplyCorrection * altAboveSL * 0.000073)) //corrected for each foot
    }
    private func takeOffTailWindCorrectionFor(knotsOfTailWind: Double, numberToApplyCorrection: Double) -> Double {
        return numberToApplyCorrection + (numberToApplyCorrection * 0.028 * knotsOfTailWind)
    }
    private func takeOffHeadWindCorrectionFor(knotsHeadwind: Double, numberToApplyCorrection: Double) -> Double {
        return numberToApplyCorrection - (numberToApplyCorrection * 0.017 * knotsHeadwind)
    }
    private func takeOffFlaps15Correction(flaps15: Bool, numberToApplyCorrection: Double) -> Double {
        var result = 0.0
        if flaps15 == true {
            result = numberToApplyCorrection - (numberToApplyCorrection * 0.19)
        } else {
            result = numberToApplyCorrection
        }
        return result
    }
    
    func takeOffGroundDistanceChartP3(grossWeight: Double,
                               tempInF: Double,
                               alt: Double,
                               ktsOfTailWind: Double,
                               ktsHeadWind: Double,
                               flaps15: Bool) -> (takeOffSpeed: Double, takeOffDistance: Double) {
        //Pg P-3
        let takeOffSpeed = 0.4711 * pow(grossWeight, 0.5149)
        // TODO: Fix this equation... works in excel, not in Swift?!?!
        let takeOffDistance = 0.000001 * pow(grossWeight, 2) - (0.0068 * grossWeight) + 49.036
        
        //Take off speed calculations
        let takeOffSpeedWithTempCorrection = takeOffTempCorrectionFor(tempInF: tempInF, numberToApplyCorrection: takeOffSpeed)
        //I'm Assuming a typo and its Sealevel not Field Elevation
        let takeOffSpeedCorrectedForAltAboveSeaLevel = takeOffAltCorrectionFor(altAboveSL: alt, numberToApplyCorrection: takeOffSpeedWithTempCorrection)
        let takeOffSpeedCorrectedForTailWind = takeOffTailWindCorrectionFor(knotsOfTailWind: ktsOfTailWind, numberToApplyCorrection: takeOffSpeedCorrectedForAltAboveSeaLevel)
        let takeOffSpeedCorrectedForHeadWind = takeOffHeadWindCorrectionFor(knotsHeadwind: ktsHeadWind, numberToApplyCorrection: takeOffSpeedCorrectedForTailWind)
        let takeOffSpeedWithALLCorrectionsApplied = takeOffFlaps15Correction(flaps15: flaps15, numberToApplyCorrection: takeOffSpeedCorrectedForHeadWind)
        
        //Take off distance calculations
        let takeOffDistWithTempCorrection = takeOffTempCorrectionFor(tempInF: tempInF, numberToApplyCorrection: takeOffDistance)
        let takeOffDistCorrectedForAltAboveSeaLevel = takeOffAltCorrectionFor(altAboveSL: alt, numberToApplyCorrection: takeOffDistWithTempCorrection)
        let takeOffDistCorrectedForTailWind = takeOffTailWindCorrectionFor(knotsOfTailWind: ktsOfTailWind, numberToApplyCorrection: takeOffDistCorrectedForAltAboveSeaLevel)
        let takeOffDistCorrectedForHeadWind = takeOffHeadWindCorrectionFor(knotsHeadwind: ktsHeadWind, numberToApplyCorrection: takeOffDistCorrectedForTailWind)
        let takeOffDistWithALLCorrectionsApplied = takeOffFlaps15Correction(flaps15: flaps15, numberToApplyCorrection: takeOffDistCorrectedForHeadWind)
        
        
        return (takeOffSpeed: takeOffSpeedWithALLCorrectionsApplied, takeOffDistance: takeOffDistWithALLCorrectionsApplied)
        
        
    }
    
    
//let result = (p6 * pow(weight, 6)) <#pluOrMinus#> (p5 * pow(weight, 5)) <#pluOrMinus#> (p4 * pow(weight, 4)) <#pluOrMinus#> (p3 * pow(weight, 3)) <#pluOrMinus#> (p2 * pow(weight, 2)) <#pluOrMinus#> (p1 * pow(weight, 1)) <#pluOrMinus#> (p0 * pow(weight, 0))
    // MARK: - Abort Stopping Distance P-4
    public func abortStoppingDistanceFor(weight: Double, condition: RunwayCondition) -> Double {
        var result = 0.0
        switch condition {
        case .dry:
//            y = 2E-21x6 - 3E-16x5 + 2E-11x4 - 8E-07x3 + 0.0174x2 - 194x + 891881
            let p6: Double = 2 * pow(10, -21)
            let p5: Double = 3 * pow(10, -16)
            let p4: Double = 2 * pow(10, -11)
            let p3: Double = 8 * pow(10, -7)
            let p2: Double = 0.0174
            let p1: Double = 194
            let p0: Double = 891881
            let c6 = (p6 * pow(weight, 6))
            let c5 = (p5 * pow(weight, 5))
            let c4 = (p4 * pow(weight, 4))
            let c3 = (p3 * pow(weight, 3))
            let c2 = (p2 * pow(weight, 2))
            let c1 = (p1 * pow(weight, 1))
            let c0 = (p0 * pow(weight, 0))
            result = c6 - c5 + c4 - c3 + c2 - c1 + c0
//            result = 0.0
        case .wet:
            result = 0.0
            let theNumber = "-6.11104586446241e-01"
            let decimalValue = NSDecimalNumber(string: theNumber)

        case .snow:
            result - 0.0
//            result = (Double("")! * pow(<#T##Double#>, 6)) - (Double("")! * pow(<#T##Double#>, 5)) + (Double("")! * pow(<#T##Double#>, 4)) - (Double("")! * pow(<#T##Double#>, 3)) + (Double("")! * pow(<#T##Double#>, 2)) - () + ()
        case .ice:
            result = 0.3012 * pow(weight, 0.9964)
//            result = (Double("")! * pow(<#T##Double#>, 6)) - (Double("")! * pow(<#T##Double#>, 5)) + (Double("")! * pow(<#T##Double#>, 4)) - (Double("")! * pow(<#T##Double#>, 3)) + (Double("")! * pow(<#T##Double#>, 2)) - () + ()
        }
        return result
    }


    
    
    
}

let input: [Double] = [20000, 22500, 25000, 27500, 30000, 32500, 35000, 37500, 40000]
let input2: [Double] = [20000, 21000, 22000, 23000, 24000, 25000, 26000, 27000,28000, 29000, 30000, 31000, 32000, 33000, 34000, 35000, 36000, 37000, 38000, 39000, 40000]
let tempInF = 59.0
let alt = 0.0
let ktsTW = 0.0
let ktsHW = 0.0
let flaps15 = true

//for weight in input {
//    let speed = u2TOLD().takeOffGroundDistanceChartP3(grossWeight: weight,
//                                               tempInF: tempInF,
//                                               alt: alt,
//                                               ktsOfTailWind: ktsTW,
//                                               ktsHeadWind: ktsHW,
//                                               flaps15: flaps15)
//
////    print("Speed: \(weight) : \(speed.takeOffSpeed)")
//    print("\(speed.takeOffSpeed)")
//}
//print("********************************")
//for weight in input {
//    let speed = u2TOLD().takeOffGroundDistanceChartP3(grossWeight: weight,
//                                                      tempInF: tempInF,
//                                                      alt: alt,
//                                                      ktsOfTailWind: ktsTW,
//                                                      ktsHeadWind: ktsHW,
//                                                      flaps15: flaps15)
//
//    //    print("Speed: \(weight) : \(speed.takeOffSpeed)")
//    print("\(speed.takeOffDistance)")
//}

//for weight in input2 {
//    let distance = u2TOLD().abortStoppingDistanceFor(weight: weight, condition: .dry)
//    print(distance)
//}
//print("********************************")
//for weight in input2 {
//    let distance = u2TOLD().abortStoppingDistanceFor(weight: weight, condition: .wet)
//    print(distance)
//}
//print("********************************")
//for weight in input2 {
//    let distance = u2TOLD().abortStoppingDistanceFor(weight: weight, condition: .snow)
//    print(distance)
//}
print("********************************")
for weight in input2 {
    let distance = u2TOLD().abortStoppingDistanceFor(weight: weight, condition: .dry)
    print(distance)
}










let turn: Double = 180                              //<- this is turn in degrees
let time: Double = 30                               //<- Amount of time in seconds spent in a turn
let currentAlt: Double = 70000                      //<- if it's not obvious... you should put your helmet on and go lick a window
let ktJet: Double = 1.2                             //<- reference line 153 comment
let fuelRemaining: Double = 1100                    //<- reference line 153 comment
let config: EngineOut.Configuration = .slickGearUp  //<- Type a "." then wait a second for autocomplete to show the options
let correction: EngineOut.Corrections = .speedBrakeOutGearUp   //<- Type a "." then wait a second for autocomplete to show the options


let newSit = EngineOut(currentAlt: currentAlt,
                       ktJet: ktJet,
                       fuelRemaining: fuelRemaining,
                       config: config,
                       correction: correction)

//print("****************SETUP**********************")
//print("Knot Jet: \(ktJet)")
//print("Fuel remaining: \(fuelRemaining)")
//print("Current Altitude: \(currentAlt)")
//print(config)
//print(correction)
//print("****************RESULTS**********************")
//print("Alt loss for \(time) seconds at 20° AOB: \(newSit.altLossAfter30SecondsOfTurnAt_20_DegreesAngleOfBankFor(seconds: time)) ft")
//print("Alt loss for \(time) seconds at 30° AOB: \(newSit.altLossAfter30SecondsOfTurnAt_30_DegreesAngleOfBankFor(seconds: time)) ft")
//print("Alt loss 20° AOB for 180°: \(newSit.altLossAt_20_DegreesAngleOfBankFor(degrees: turn)) ft")
//print("Alt loss 30° AOB for 180°: \(newSit.altLossAt_30_DegreesAngleOfBankFor(degrees: turn)) ft")
//print("Time to turn \(turn)° at 20° AOB: \(newSit.timeForTurnAt_20_DegreesAngleOfBankFor(degrees: turn)) seconds")
//print("Time to turn \(turn)° at 30° AOB: \(newSit.timeForTurnAt_30_DegreesAngleOfBankFor(degrees: turn)) seconds")
//print("Glide distance from \(currentAlt) ft: \(newSit.glideDistance()) NM")
//print("*********************************************")




















