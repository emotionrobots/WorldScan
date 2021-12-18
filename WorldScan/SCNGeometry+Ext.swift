//
//  SCNGeometry+Ext.swift
//  MeshScan
//
//  Created by Larry Li on 12/12/21.
//
//  From SCNGeometry+Ext.swift
//  ExampleOfiOSLiDAR
//
//  Created by TokyoYoshida on 2021/02/13.
//

import SceneKit
import ARKit


extension SCNGeometry {
    convenience init(geometry: ARMeshGeometry, camera: ARCamera, modelMatrix: simd_float4x4, needTexture: Bool = false) {
        
        ///=================================================================================================
        ///
        ///   Convert ARGeometryPrimitiveType to SCNGeometryPrimitiveType
        ///
        ///=================================================================================================
        func convertType(type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
            switch type {
            case .line:
                return .line
            case .triangle:
                return .triangles
            @unknown default:
                fatalError("unknown type")
            }
            
        }
        
        ///=================================================================================================
        ///
        ///   Given ARGeometry source, and ARCamera and model transform of the camera, return a
        ///   SCNGeomtry with texture coordinates calculated
        ///
        ///   helps from:
        ///   https://stackoverflow.com/questions/61538799/ipad-pro-lidar-export-geometry-texture
        ///
        ///=================================================================================================
        func calcTextureCoordinates(verticles: ARGeometrySource, camera: ARCamera, modelMatrix: simd_float4x4) ->  SCNGeometrySource? {
            
            // Return the 3D coordinates of the vertex indexed by 'index'
            func getVertex(at index: UInt32) -> SIMD3<Float> {
                    assert(verticles.format == MTLVertexFormat.float3, "Expected three floats (twelve bytes) per vertex.")
                    let vertexPointer = verticles.buffer.contents().advanced(by: verticles.offset + (verticles.stride * Int(index)))
                    let vertex = vertexPointer.assumingMemoryBound(to: SIMD3<Float>.self).pointee
                    return vertex
            }
            
            // Given an ARCamera Return the UV texture coordinates, which is an array of (u,v)
            func buildCoordinates() -> [vector_float2]? {
                let size = camera.imageResolution
                let textureCoordinates = (0..<verticles.count).map { i -> vector_float2 in
                    let vertex = getVertex(at: UInt32(i))
                    let vertex4 = vector_float4(vertex.x, vertex.y, vertex.z, 1)
                    let world_vertex4 = simd_mul(modelMatrix, vertex4)
                    let world_vector3 = simd_float3(x: world_vertex4.x, y: world_vertex4.y, z: world_vertex4.z)
                    let pt = camera.projectPoint(world_vector3,
                        orientation: .portrait,
                        viewportSize: CGSize(
                            width: CGFloat(size.height),
                            height: CGFloat(size.width)))
                    let v = 1.0 - Float(pt.x) / Float(size.height)
                    let u = Float(pt.y) / Float(size.width)
                    return vector_float2(u, v)
                }
                return textureCoordinates
            }
            
            // Build the texture coordinates and then return a SCNGeometry initialized with texture coordinates
            guard let texcoords = buildCoordinates() else {return nil}
            let result = SCNGeometrySource(textureCoordinates: texcoords)
            
            return result
        }
        
        let verticles = geometry.vertices
        let normals = geometry.normals
        let faces = geometry.faces
        let verticesSource = SCNGeometrySource(buffer: verticles.buffer, vertexFormat: verticles.format, semantic: .vertex, vertexCount: verticles.count, dataOffset: verticles.offset, dataStride: verticles.stride)
        let normalsSource = SCNGeometrySource(buffer: normals.buffer, vertexFormat: normals.format, semantic: .normal, vertexCount: normals.count, dataOffset: normals.offset, dataStride: normals.stride)
        let data = Data(bytes: faces.buffer.contents(), count: faces.buffer.length)
        let facesElement = SCNGeometryElement(data: data, primitiveType: convertType(type: faces.primitiveType), primitiveCount: faces.count, bytesPerIndex: faces.bytesPerIndex)
        var sources = [verticesSource, normalsSource]
        if needTexture {
            let textureCoordinates = calcTextureCoordinates(verticles: verticles, camera: camera, modelMatrix: modelMatrix)!
            sources.append(textureCoordinates)
        }
        self.init(sources: sources, elements: [facesElement])
    }
}

extension SCNGeometrySource {
    convenience init(textureCoordinates texcoord: [vector_float2]) {
        let stride = MemoryLayout<vector_float2>.stride
        let bytePerComponent = MemoryLayout<Float>.stride
        let data = Data(bytes: texcoord, count: stride * texcoord.count)
        self.init(data: data, semantic: SCNGeometrySource.Semantic.texcoord, vectorCount: texcoord.count, usesFloatComponents: true, componentsPerVector: 2, bytesPerComponent: bytePerComponent, dataOffset: 0, dataStride: stride)
    }
}



/*
extension  SCNGeometry {
    convenience init(arGeometry: ARMeshGeometry) {
       let verticesSource = SCNGeometrySource(arGeometry.vertices, semantic: .vertex)
       let normalsSource = SCNGeometrySource(arGeometry.normals, semantic: .normal)
       let faces = SCNGeometryElement(arGeometry.faces)
       self.init(sources: [verticesSource, normalsSource], elements: [faces])
    }
}

extension  SCNGeometrySource {
    convenience init(_ source: ARGeometrySource, semantic: Semantic) {
        self.init(buffer: source.buffer, vertexFormat: source.format, semantic: semantic, vertexCount: source.count, dataOffset: source.offset, dataStride: source.stride)
    }
}

extension  SCNGeometryElement {
    convenience init(_ source: ARGeometryElement) {
       let pointer = source.buffer.contents()
       let byteCount = source.count * source.indexCountPerPrimitive * source.bytesPerIndex
       let data = Data(bytesNoCopy: pointer, count: byteCount, deallocator: .none)
       self.init(data: data, primitiveType: .of(source.primitiveType), primitiveCount: source.count, bytesPerIndex: source.bytesPerIndex)
    }
}

extension  SCNGeometryPrimitiveType {
    static  func  of(_ type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
       switch type {
       case .line:
            return .line
       case .triangle:
            return .triangles
       @unknown default:
            return .line
       }
    }
}
*/

