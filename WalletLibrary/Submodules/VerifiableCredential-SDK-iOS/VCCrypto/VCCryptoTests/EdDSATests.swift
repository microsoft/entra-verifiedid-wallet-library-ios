import XCTest
@testable import VCCrypto

class EdDSATests: XCTestCase {
    
    func testIsValidSignature() throws {
        
        let x = Data(hexString: "3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c")
        
        let publicKey = ED25519PublicKey(x: x)!
        
        let signature = Data(hexString: "92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00")
        let message = Data(hexString: "72")
        
        let algo = EdDSA()
        let result = try algo.isValidSignature(signature: signature, forMessage: message, usingPublicKey: publicKey)
        XCTAssertTrue(result)
    }
    
    func testIsValidSignatureEmptyMessage() throws {
        
        let x = Data(hexString: "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")
        
        let publicKey = ED25519PublicKey(x: x)!
        
        let signature = Data(hexString: "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b")
        let message = Data(hexString: "")
        
        let algo = EdDSA()
        let result = try algo.isValidSignature(signature: signature, forMessage: message, usingPublicKey: publicKey)
        XCTAssertTrue(result)
    }
    
    func testIsValidSignatureWithBase64KeyValue() throws {
        
        let x = Data(base64URLEncoded: "NnQVm-mj5SQ-k_mazsZKavGCIZ6O-hEOU33LoTfwiLw")!
        
        let publicKey = ED25519PublicKey(x: x)!
        
        let signature = Data(base64URLEncoded: "Qgimq2qxaDIetbjZW-O98shmeHmOpCL4ct40V9xW7b0iGUJay-v8kvdpEC6z75NRoHxRpWmih5j9xVQf1y3IDQ")!
        let message = ("eyJraWQiOiJkaWQ6aW9uOkVpQWlLM3BUMXBONV9NUmVkYWxLU2RBcHFYZGJPSDREMHQxNUxuYmtfWDRFX1E6ZXlKa1pXeDBZU0k2ZXlKd1lYUmphR1Z6SWpwYmV5SmhZM1JwYjI0aU9pSnlaWEJzWVdObElpd2laRzlqZFcxbGJuUWlPbnNpY0hWaWJHbGpTMlY1Y3lJNlczc2lhV1FpT2lKclpYa3RNU0lzSW5CMVlteHBZMHRsZVVwM2F5STZleUpqY25ZaU9pSkZaREkxTlRFNUlpd2lhM1I1SWpvaVQwdFFJaXdpZUNJNklrNXVVVlp0TFcxcU5WTlJMV3RmYldGNmMxcExZWFpIUTBsYU5rOHRhRVZQVlRNelRHOVVabmRwVEhjaWZTd2ljSFZ5Y0c5elpYTWlPbHNpWVhWMGFHVnVkR2xqWVhScGIyNGlYU3dpZEhsd1pTSTZJa3B6YjI1WFpXSkxaWGt5TURJd0luMWRmWDFkTENKMWNHUmhkR1ZEYjIxdGFYUnRaVzUwSWpvaVJXbEJOamwyYlhKMFowWm5USHBZZG5abGVEaGxWSGcxYUhaaE5ERkxTMGhJU2pCQlEzTnJOMmN6ZDFGYVVTSjlMQ0p6ZFdabWFYaEVZWFJoSWpwN0ltUmxiSFJoU0dGemFDSTZJa1ZwUkhJek5GOHliRTVHVUdkM1VVaHZSSFZ0TjBoblRXWkJXblZqYlRFd2MyMXZSbG90VG5RMlpGZzFNSGNpTENKeVpXTnZkbVZ5ZVVOdmJXMXBkRzFsYm5RaU9pSkZhVU10UVhoUlkwRXhhMEl0YzJkdVZHNWFYelZRTUdsUVZXdDZTVnBITTE5NVJEVlNiek5MZDBWV1pXTjNJbjE5I2tleS0xIiwidHlwIjoiSldUIiwiYWxnIjoiRWREU0EifQ.eyJyZXNwb25zZV90eXBlIjoiaWRfdG9rZW4iLCJub25jZSI6IlplU1hLbkFJa3lJZTJ5M2EiLCJjbGllbnRfaWQiOiJkaWQ6aW9uOkVpQWlLM3BUMXBONV9NUmVkYWxLU2RBcHFYZGJPSDREMHQxNUxuYmtfWDRFX1E6ZXlKa1pXeDBZU0k2ZXlKd1lYUmphR1Z6SWpwYmV5SmhZM1JwYjI0aU9pSnlaWEJzWVdObElpd2laRzlqZFcxbGJuUWlPbnNpY0hWaWJHbGpTMlY1Y3lJNlczc2lhV1FpT2lKclpYa3RNU0lzSW5CMVlteHBZMHRsZVVwM2F5STZleUpqY25ZaU9pSkZaREkxTlRFNUlpd2lhM1I1SWpvaVQwdFFJaXdpZUNJNklrNXVVVlp0TFcxcU5WTlJMV3RmYldGNmMxcExZWFpIUTBsYU5rOHRhRVZQVlRNelRHOVVabmRwVEhjaWZTd2ljSFZ5Y0c5elpYTWlPbHNpWVhWMGFHVnVkR2xqWVhScGIyNGlYU3dpZEhsd1pTSTZJa3B6YjI1WFpXSkxaWGt5TURJd0luMWRmWDFkTENKMWNHUmhkR1ZEYjIxdGFYUnRaVzUwSWpvaVJXbEJOamwyYlhKMFowWm5USHBZZG5abGVEaGxWSGcxYUhaaE5ERkxTMGhJU2pCQlEzTnJOMmN6ZDFGYVVTSjlMQ0p6ZFdabWFYaEVZWFJoSWpwN0ltUmxiSFJoU0dGemFDSTZJa1ZwUkhJek5GOHliRTVHVUdkM1VVaHZSSFZ0TjBoblRXWkJXblZqYlRFd2MyMXZSbG90VG5RMlpGZzFNSGNpTENKeVpXTnZkbVZ5ZVVOdmJXMXBkRzFsYm5RaU9pSkZhVU10UVhoUlkwRXhhMEl0YzJkdVZHNWFYelZRTUdsUVZXdDZTVnBITTE5NVJEVlNiek5MZDBWV1pXTjNJbjE5IiwicmVzcG9uc2VfbW9kZSI6InBvc3QiLCJuYmYiOjE2NjUxNTY5NTgsInNjb3BlIjoib3BlbmlkIiwiY2xhaW1zIjp7InZwX3Rva2VuIjp7InByZXNlbnRhdGlvbl9kZWZpbml0aW9uIjp7ImlkIjoiMThmOThlODUtZGZlOC00NjEwLThiNTItMDFiZjQwZjI3YmNmIiwiaW5wdXRfZGVzY3JpcHRvcnMiOlt7ImlkIjoiV29ya3BsYWNlQ3JlZGVudGlhbFZDIiwibmFtZSI6IldvcmtwbGFjZUNyZWRlbnRpYWxWQyIsInB1cnBvc2UiOiJXZSBuZWVkIHRvIHZlcmlmeSB0aGF0IHlvdSBoYXZlIGEgdmFsaWQgV29ya3BsYWNlQ3JlZGVudGlhbCBWZXJpZmlhYmxlIENyZWRlbnRpYWwuIiwic2NoZW1hIjpbeyJ1cmkiOiJXb3JrcGxhY2VDcmVkZW50aWFsIn1dfV19fX0sInJlZ2lzdHJhdGlvbiI6eyJjbGllbnRfbmFtZSI6IkludGVyb3AgRGVtbyBWZXJpZmllciIsInRvc191cmkiOiJodHRwczpcL1wvd29ya2RheS5jb20iLCJsb2dvX3VyaSI6IiIsInN1YmplY3Rfc3ludGF4X3R5cGVzX3N1cHBvcnRlZCI6WyJkaWQ6aW9uIl0sInZwX2Zvcm1hdHMiOnsiand0X3ZwIjp7ImFsZyI6WyJFZERTQSIsIkVTMjU2SyJdfSwiand0X3ZjIjp7ImFsZyI6WyJFZERTQSIsIkVTMjU2SyJdfX19LCJzdGF0ZSI6IjE4Zjk4ZTg1LWRmZTgtNDYxMC04YjUyLTAxYmY0MGYyN2JjZiIsInJlZGlyZWN0X3VyaSI6Imh0dHBzOlwvXC92Y2d3LmlkLnlhZGtyb3cuY29tXC9hcGlcL3YxXC9wcmVzZW50YXRpb24tcmVzcG9uc2UiLCJleHAiOjE2NjUxNjA1NTgsImlhdCI6MTY2NTE1Njk1OCwianRpIjoiODhlNzZmZWEtMDE1Zi00NGZkLWI3NWYtMTViOTE0ZmFjYWUxIn0").data(using: .ascii)!
        
        let algo = EdDSA()
        let result = try algo.isValidSignature(signature: signature, forMessage: message, usingPublicKey: publicKey)
        XCTAssertTrue(result)
    }
    
    func testInvalidSignature() throws {
        
        let x = Data(base64URLEncoded: "r_1voElsuJnWrc7MLzqKeIQ2ZrlXP3UDfOYclKMvJWg")!
        
        let publicKey = ED25519PublicKey(x: x)!
        
        let message = Data(hexString: "85EB4467104FBD9883BF4075EC79DEFDC6EC260B2898D4B4D195443C463B0ED3")
        let signature = Data(hexString: "ABCDA6C0F0BE1858DA4275DD60E69EA174E20B3D6E66FD9E4A9C385BEE7F1DD12054DED0D1E5DED54F763C3B468333EE2E1116E8AE22A51A0FF521A0EBBE3C62")
        
        let algo = EdDSA()
        let result = try algo.isValidSignature(signature: signature, forMessage: message, usingPublicKey: publicKey)
        XCTAssertFalse(result)
    }
}
