import Foundation
import GPXKit

protocol Simplifiable {
    var x: Double { get }
    var y: Double { get }
}

extension DistanceHeight: Simplifiable {
    var x: Double { distance }
    var y: Double { elevation }
}

extension Coordinate: Simplifiable {
    var x: Double { latitude }
    var y: Double { longitude }
}

// MARK: - Private implementation -

private extension Simplifiable {
    func squaredDistanceToSegment(_ p1: Self, _ p2: Self) -> Double {
        var x = p1.x
        var y = p1.y
        var dx = p2.x - x
        var dy = p2.y - y

        if dx != 0 || dy != 0 {
            let deltaSquared = (dx * dx + dy * dy)
            let t = ((self.x - p1.x) * dx + (self.y - p1.y) * dy) / deltaSquared
            if t > 1 {
                x = p2.x
                y = p2.y
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }

        dx = self.x - x
        dy = self.y - y

        return dx * dx + dy * dy
    }
}

extension Array where Element: Simplifiable {
    func simplify(tolerance: Double) -> Self {
        return simplifyDouglasPeucker(self, sqTolerance: tolerance * tolerance)
    }

    private func simplifyDPStep(
        _ points: Self,
        first: Self.Index,
        last: Self.Index,
        sqTolerance: Double,
        simplified: inout Self
    ) {
        guard last > first else {
            return
        }
        var maxSqDistance = sqTolerance
        var index = startIndex

        for currentIndex: Self.Index in first + 1 ..< last {
            let sqDistance = points[currentIndex].squaredDistanceToSegment(points[first], points[last])
            if sqDistance > maxSqDistance {
                maxSqDistance = sqDistance
                index = currentIndex
            }
        }

        if maxSqDistance > sqTolerance {
            if (index - first) > 1 {
                simplifyDPStep(points, first: first, last: index, sqTolerance: sqTolerance, simplified: &simplified)
            }
            simplified.append(points[index])
            if (last - index) > 1 {
                simplifyDPStep(points, first: index, last: last, sqTolerance: sqTolerance, simplified: &simplified)
            }
        }
    }

    private func simplifyDouglasPeucker(_ points: [Element], sqTolerance: Double) -> [Element] {
        guard points.count > 1 else {
            return []
        }

        let last = (points.count - 1)
        var simplied = [points.first!]
        simplifyDPStep(points, first: 0, last: last, sqTolerance: sqTolerance, simplified: &simplied)
        simplied.append(points.last!)

        return simplied
    }
}

public extension [DistanceHeight] {
    // http://skemman.is/stream/get/1946/15343/37285/3/SS_MSthesis.pdf
    // https://gist.github.com/DanielWJudge/63300889f27c7f50eeb7
    func largestTriangleThreeBuckets(toCount threshold: Int) -> Self {
        guard !isEmpty, threshold > 2, threshold < count else {
            return self
        }

        var sampled: Self = []

        // Bucket size. Leave room for start and end data points
        let every = Double(count - 2) / Double(threshold - 2)

        var a = 0
        var maxAreaPoint: Element = .init(distance: 0, elevation: 0)
        var nextA = 0

        sampled.append(self[a]) // Always add the first point

        for i in 0 ..< (threshold - 2) {
            // Calculate point average for next bucket (containing c)
            var avgX: Double = 0
            var avgY: Double = 0
            var avgRangeStart = Int((Double(i + 1) * every).rounded(.down) + 1)
            var avgRangeEnd = Int((Double(i + 2) * every).rounded(.down) + 1)
            avgRangeEnd = avgRangeEnd < count ? avgRangeEnd : count

            let avgRangeLength = avgRangeEnd - avgRangeStart

            while avgRangeStart < avgRangeEnd {
                avgX += self[avgRangeStart].x
                avgY += self[avgRangeStart].y
                avgRangeStart += 1
            }
            avgX /= Double(avgRangeLength)
            avgY /= Double(avgRangeLength)

            // Get the range for this bucket
            var rangeOffs = Int((Double(i) * every).rounded(.down) + 1)
            let rangeTo = Int((Double(i + 1) * every).rounded(.down) + 1)

            // Point a
            let pointAx = self[a].x
            let pointAy = self[a].y

            var maxArea = -1.0

            while rangeOffs < rangeTo {
                // Calculate triangle area over three buckets
                let area =
                    abs(
                        (pointAx - avgX) * (self[rangeOffs].y - pointAy) - (pointAx - self[rangeOffs].x) *
                            (avgY - pointAy)
                    ) * 0.5

                if area > maxArea {
                    maxArea = area
                    maxAreaPoint = self[rangeOffs]
                    nextA = rangeOffs // Next a is this b
                }
                rangeOffs += 1
            }

            sampled.append(maxAreaPoint) // Pick this point from the bucket
            a = nextA // This a is the next a (chosen b)
        }

        sampled.append(self[count - 1]) // Always add last

        return sampled
    }
}
