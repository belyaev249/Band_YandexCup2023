//
//  Wave.swift
//  Band
//
//  Created by Egor on 04.11.2023.
//

import Accelerate
import AVFoundation
import CoreGraphics
import Foundation
import UIKit

actor Cache<Key: Hashable, Value: Any> {
    private var dict: [Key: Value] = [:]
    func value(_ forKey: Key) -> Value? {
        dict[forKey]
    }
    func update(_ value: Value, forKey: Key) {
        dict[forKey] = value
    }
}

final class VectorBuilder {
        
    private struct Vector {
        var values: [Float]
        var xScale: Float
        var yScale: Float
        var lenght: Int
        init(values: [Float], xScale: Float = 1.0, yScale: Float = 1.0, lenght: Int = 0) {
            self.values = values
            self.xScale = xScale
            self.yScale = yScale
            self.lenght = lenght
        }
    }
        
    private let naturalLenght: Int
    
    private var _dict: [UUID: Vector] = [:]
    
    init(naturalLenght: Int) {
        self.naturalLenght = naturalLenght
    }
    
    func remove(
        id: UUID,
        completion: @escaping (Float, [Float]) -> Void
    ) {
        _dict[id] = nil
        rewrite(completion)
    }
    
    func update(
        id: UUID,
        values: [Float],
        xScale: Float?,
        yScale: Float?,
        lenght: Int,
        completion: @escaping (Float ,[Float]) -> Void
    ) {
        
        if _dict[id] == nil {
            _dict[id] = .init(values: values, lenght: lenght)
        }
        
        _dict[id]?.values = values
        _dict[id]?.lenght = lenght
        
        if let yScale {
            _dict[id]?.yScale = yScale
        }
        if let xScale {
            _dict[id]?.xScale = xScale
        }
        
        rewrite(completion)
    }
    
    private func rewrite(_ c: (Float, [Float]) -> Void) {
        
        var values: [Float] = Array(repeating: 0.0, count: naturalLenght)
                
        var maxX: Float = 0
        var maxY: Float = 0
        var minY: Float = 0
        let needsRedraw = !_dict.isEmpty
                
        for (_, value) in _dict {
            maxX = max(Float(value.lenght) / value.xScale, maxX)
        }
        
        for (_, value) in _dict {
            var scale = (Float(value.lenght) / Float(value.xScale)) / Float(maxX)
            scale = scale.bound(l: 0.1, r: 1.0)

            let interLenght = (Float(naturalLenght) * Float(scale))

            let interValues = vDSP
                .linearInterpolate(values: value.values, between: Int(interLenght))

            for index in 0..<naturalLenght {
                let v = interValues[index % interValues.count]
                let vv = v * value.yScale
                values[index] += vv
                maxY = max(values[index], maxY)
                minY = min(values[index], minY)
            }
        }
        
        let maxH = maxY - minY
        
        guard needsRedraw else {
            c(maxH, values)
            return
        }
        
        for index in 0..<values.count {
            if let h = values[safe: index] {
                let hh = h - minY
                values[index] = hh / maxH
            }
        }
        
        c(maxH, values)
    }
    
}

final class TrackLineGenerator {
    private let queue = DispatchQueue(label: "queue.WaveGenerator", qos: .userInteractive, attributes: .concurrent)
    
    typealias CacheValue = (values: [Float], lenght: Int)
    private let vectorCache = Cache<URL, CacheValue>()
    
    private let vectorBuilder = VectorBuilder(naturalLenght: 50)
    
    func removeTrack(track: TrackData, completion: @escaping ((Float, [Float]) -> Void)) {
        queue.async { [weak self] in
            self?.vectorBuilder.remove(id: track.id, completion: completion)
        }
    }
    
    func updateTrack(track: TrackData, completion: @escaping ((Float, [Float]) -> Void)) {
        
        guard let url = track.sample.url else { return }
        
        queue.async { [weak self] in
            
            self?.makeBuffer(
                url,
                completion: { buffer in
                    if let buffer {
                        self?.vectorBuilder.update(
                            id: track.id,
                            values: buffer.values,
                            xScale: Float.optional(track.volumeTemp?.temp),
                            yScale: Float.optional(track.volumeTemp?.volume),
                            lenght: buffer.lenght,
                            completion: completion
                        )
                    }
                    
                }
            )
            
        }
        
    }
    
    private func makeBuffer(_ url: URL, completion: @escaping (_ buffer: CacheValue?) -> Void) {
        queue.async { [weak self] in
            Task { [weak self] in
                if let value = await self?.vectorCache.value(url) {
                    completion(value)
                    return
                }
                self?.readBuffer(url) { buffer in
                    if let buffer {
                        let resultBuffer = vDSP.linearInterpolate(values: buffer, between: 50)
                        Task { [weak self] in
                            await self?.vectorCache.update((resultBuffer, buffer.count), forKey: url)
                            completion((resultBuffer, buffer.count))
                        }
                    }
                }
            }
        }
    }
    
    private func readBuffer(_ url: URL?, completion: @escaping (_ buffer: UnsafeBufferPointer<Float>?) -> Void)  {
        queue.async {
            guard let url, let file = try? AVAudioFile(forReading: url) else {
                completion(nil)
                return
            }
            
            let audioFormat = file.processingFormat
            let audioFrameCount = UInt32(file.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
                    
            else { return completion(UnsafeBufferPointer<Float>(_empty: ()))  }
            do {
                try file.read(into: buffer)
            } catch {
                print(error)
            }
            
            let floatArray = UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength))
            
            completion(floatArray)
        }
    }
}


func waveImage(
    _ samples: [Float],
    _ max: CGFloat,
    _ imageSize: CGSize,
    _ lineWidth: CGFloat,
    _ strokeColor: UIColor
) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    
    let middleY = imageSize.height / 2
    
    guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }
    
    context.setLineWidth(lineWidth)
    
    let heightNormalizationFactor = imageSize.height / max / 2
    let widthNormalizationFactor = imageSize.width / CGFloat(samples.count)
    for index in 0 ..< samples.count {
        let pixel = CGFloat(samples[index]) * heightNormalizationFactor
        
        let x = CGFloat(index) * widthNormalizationFactor + lineWidth
        
        context.move(to: CGPoint(x: x, y: middleY - pixel))
        context.addLine(to: CGPoint(x: x, y: middleY + pixel))
        
        context.setStrokeColor(strokeColor.cgColor)
        context.strokePath()
    }
    guard let soundWaveImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
    
    UIGraphicsEndImageContext()
    return soundWaveImage
}

