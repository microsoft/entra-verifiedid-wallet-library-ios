/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Compression
import Foundation

extension Data {

    /// Inflates a GZIP (RFC 1952) payload, as used by the StatusList2021 `encodedList`.
    ///
    /// Apple's `Compression` framework inflates only a raw DEFLATE stream, so this strips the gzip
    /// header (including the optional FEXTRA / FNAME / FCOMMENT / FHCRC fields) and the 8-byte trailer,
    /// then streams the DEFLATE payload through `COMPRESSION_ZLIB`. Returns `nil` for malformed input.
    func gunzipped() -> Data? {
        // Smallest possible gzip stream: 10-byte header + 8-byte trailer.
        guard count >= 18,
              self[startIndex] == 0x1f,
              self[startIndex + 1] == 0x8b,
              self[startIndex + 2] == 0x08 else {
            return nil
        }

        let flags = self[startIndex + 3]
        var cursor = startIndex + 10

        // FEXTRA: 2-byte little-endian length, then that many bytes.
        if flags & 0x04 != 0 {
            guard cursor + 2 <= endIndex else { return nil }
            let extraLength = Int(self[cursor]) | (Int(self[cursor + 1]) << 8)
            cursor += 2 + extraLength
        }
        // FNAME / FCOMMENT: zero-terminated strings.
        if flags & 0x08 != 0 { cursor = indexAfterZeroByte(from: cursor) }
        if flags & 0x10 != 0 { cursor = indexAfterZeroByte(from: cursor) }
        // FHCRC: 2-byte header CRC.
        if flags & 0x02 != 0 { cursor += 2 }

        // Need at least the 8-byte trailer after the DEFLATE payload.
        guard cursor <= endIndex - 8, cursor >= startIndex else { return nil }
        let deflatePayload = subdata(in: cursor..<(endIndex - 8))
        guard !deflatePayload.isEmpty else { return nil }

        return Self.inflateRawDeflate(deflatePayload)
    }

    /// Returns the index just past the next zero byte at or after `from`, clamped to `endIndex`.
    private func indexAfterZeroByte(from: Int) -> Int {
        var cursor = from
        while cursor < endIndex, self[cursor] != 0 { cursor += 1 }
        return cursor + 1
    }

    /// Streams a raw DEFLATE buffer through `COMPRESSION_ZLIB`, growing the output as needed.
    private static func inflateRawDeflate(_ deflatePayload: Data) -> Data? {
        var stream = compression_stream(dst_ptr: UnsafeMutablePointer<UInt8>(bitPattern: 1)!,
                                        dst_size: 0,
                                        src_ptr: UnsafeMutablePointer<UInt8>(bitPattern: 1)!,
                                        src_size: 0,
                                        state: nil)
        guard compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
                == COMPRESSION_STATUS_OK else {
            return nil
        }
        defer { compression_stream_destroy(&stream) }

        let bufferSize = 32_768
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { destinationBuffer.deallocate() }

        var output = Data()
        let result: Data? = deflatePayload.withUnsafeBytes { (rawBuffer: UnsafeRawBufferPointer) -> Data? in
            guard let baseAddress = rawBuffer.bindMemory(to: UInt8.self).baseAddress else { return nil }
            stream.src_ptr = baseAddress
            stream.src_size = deflatePayload.count

            repeat {
                stream.dst_ptr = destinationBuffer
                stream.dst_size = bufferSize

                let status = compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
                switch status {
                case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
                    output.append(destinationBuffer, count: bufferSize - stream.dst_size)
                    if status == COMPRESSION_STATUS_END { return output }
                default:
                    return nil
                }
            } while true
        }
        return result
    }
}
