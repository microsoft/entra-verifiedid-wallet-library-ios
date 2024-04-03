Pod::Spec.new do |s|
  s.name= 'WalletLibrary'
  s.version= '1.0.1'
  s.license= 'MIT'
  s.summary= 'An SDK to manage your Decentralized Identities and Verifiable Credentials.'
  s.homepage= 'https://github.com/microsoft/entra-verifiedid-wallet-library-ios'
  s.authors= {
    'symorton' => 'symorton@microsoft.com'
  }
  s.documentation_url= 'https://github.com/microsoft/entra-verifiedid-wallet-library-ios'
  s.source= {
    :git => 'https://github.com/microsoft/entra-verifiedid-wallet-library-ios.git',
    :submodules => true,
    :tag => s.version
  }

  vcsdkPath = 'WalletLibrary/Submodules/VerifiableCredential-SDK-iOS'
  submodulePath = 'WalletLibrary/Submodules/VerifiableCredential-SDK-iOS/Submodules'

  s.swift_version = '5.0'

  s.ios.deployment_target = '13.0'
  s.default_subspecs = 'Core'

  s.subspec 'Secp256k1' do |cs|
      cs.library = 'c++'
      cs.public_header_files = ["#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/include/*"]
      cs.compiler_flags = "-Wno-shorten-64-to-32", "-Wno-unused-function"
      cs.preserve_paths = "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/{include,src}/*.{c,h}"
      cs.source_files = ["#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/{include,src}/*.{c,h}"]
      cs.exclude_files = [  
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench_ecdh.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench_ecmult.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench_internal.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench_recover.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench_schnorrsig.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench_sign.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/bench_verify.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/tests.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/testrand_impl.h",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/testrand.h",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/valgrind_ctime_test.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/ctime_tests.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/gen_context.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/precompute_ecmult.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/precompute_ecmult_gen.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/src/tests_exhaustive.c",
        "#{submodulePath}/Secp256k1/bitcoin-core/secp256k1/contrib/*.{c, h}"
     ]
      cs.prefix_header_contents = '
#define ECMULT_WINDOW_SIZE 15 
#define LIBSECP256K1_CONFIG_H
#define USE_NUM_NONE 1 
#define ECMULT_WINDOW_SIZE 15
#define ECMULT_GEN_PREC_BITS 4
#define USE_FIELD_INV_BUILTIN 1
#define USE_SCALAR_INV_BUILTIN 1
#define HAVE_DLFCN_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_UNISTD_H 1
#define LT_OBJDIR ".libs/"
#define PACKAGE "libsecp256k1"
#define PACKAGE_BUGREPORT ""
#define PACKAGE_NAME "libsecp256k1"
#define PACKAGE_STRING "libsecp256k1 0.1"
#define PACKAGE_TARNAME "libsecp256k1"
#define PACKAGE_URL ""
#define PACKAGE_VERSION "0.1"
#define STDC_HEADERS 1
#define VERSION "0.1"'
  end

  s.subspec 'Core' do |cs|
      cs.name = 'Core'
      cs.source_files= [
          "WalletLibrary/WalletLibrary/**/*.swift",
          "#{vcsdkPath}/VCServices/VCServices/**/*.{swift, xcdatamodeld, xcdatamodel}",
          "#{vcsdkPath}/VCNetworking/VCNetworking/**/*.swift",
          "#{vcsdkPath}/VCEntities/VCEntities/**/*.swift",
          "#{vcsdkPath}/VCToken/VCToken/**/*.swift",
          "#{vcsdkPath}/VCCrypto/VCCrypto/**/*.swift"
      ]
      cs.resources = "#{vcsdkPath}/VCServices/VCServices/Resources/**/*.{xcdatamodeld,xcdatamodel,mom,momd}"
      cs.exclude_files = [
          "WalletLibrary/**/*Test/*.swift"
      ]
      cs.dependency 'WalletLibrary/Secp256k1'
  end

  s.xcconfig = { "ENABLE_USER_SCRIPT_SANDBOXING" => "NO" }
end