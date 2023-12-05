import Foundation

public extension BinaryFloatingPoint {
    var seconds: Measurement<UnitDuration> {
        .init(value: Double(self), unit: .seconds)
    }

    var minutes: Measurement<UnitDuration> {
        .init(value: Double(self), unit: .minutes)
    }

    var hours: Measurement<UnitDuration> {
        .init(value: Double(self), unit: .hours)
    }

    var watts: Measurement<UnitPower> {
        .init(value: Double(self), unit: .watts)
    }

    var kph: Measurement<UnitSpeed> {
        .init(value: Double(self), unit: .kilometersPerHour)
    }

    var mps: Measurement<UnitSpeed> {
        .init(value: Double(self), unit: .metersPerSecond)
    }

    var meters: Measurement<UnitLength> {
        .init(value: Double(self), unit: .meters)
    }

    var kilometers: Measurement<UnitLength> {
        .init(value: Double(self), unit: .kilometers)
    }

    var miles: Measurement<UnitLength> {
        .init(value: Double(self), unit: .miles)
    }

    var degrees: Measurement<UnitAngle> {
        .init(value: Double(self), unit: .degrees)
    }

    var kilograms: Measurement<UnitMass> {
        .init(value: Double(self), unit: .kilograms)
    }
}

public extension BinaryInteger {
    var seconds: Measurement<UnitDuration> {
        .init(value: Double(self), unit: .seconds)
    }

    var minutes: Measurement<UnitDuration> {
        .init(value: Double(self), unit: .minutes)
    }

    var hours: Measurement<UnitDuration> {
        .init(value: Double(self), unit: .hours)
    }

    var watts: Measurement<UnitPower> {
        .init(value: Double(self), unit: .watts)
    }

    var kph: Measurement<UnitSpeed> {
        .init(value: Double(self), unit: .kilometersPerHour)
    }

    var mps: Measurement<UnitSpeed> {
        .init(value: Double(self), unit: .metersPerSecond)
    }

    var meters: Measurement<UnitLength> {
        .init(value: Double(self), unit: .meters)
    }

    var kilometers: Measurement<UnitLength> {
        .init(value: Double(self), unit: .kilometers)
    }

    var miles: Measurement<UnitLength> {
        .init(value: Double(self), unit: .miles)
    }

    var degrees: Measurement<UnitAngle> {
        .init(value: Double(self), unit: .degrees)
    }

    var kilograms: Measurement<UnitMass> {
        .init(value: Double(self), unit: .kilograms)
    }
}
