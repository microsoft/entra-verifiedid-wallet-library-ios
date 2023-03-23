Pod::Spec.new do |s|
    s.name= 'WalletLibrary'
    s.version= '0.0.1-beta'
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

    s.subspec 'VCCrypto' do |cs|
        cs.name = 'VCCrypto'
        cs.preserve_paths = "#{vcsdkPath}/VCCrypto/**/*.swift"
        cs.source_files= "#{vcsdkPath}/VCCrypto/VCCrypto/**/*.swift"
        cs.dependency 'WalletLibrary/Secp256k1'
    end 

    s.subspec 'VCToken' do |cs|
        cs.name = 'VCToken'
        cs.preserve_paths = "#{vcsdkPath}/VCToken/**/*.swift"
        cs.source_files= "#{vcsdkPath}/VCToken/VCToken/**/*.swift"
        cs.dependency 'WalletLibrary/VCCrypto'
    end


    s.subspec 'VCEntities' do |cs|
        cs.name = 'VCEntities'
        cs.preserve_paths = "#{vcsdkPath}/VCEntities/**/*.swift"
        cs.source_files= "#{vcsdkPath}/VCEntities/VCEntities/**/*.swift"
        cs.dependency 'WalletLibrary/VCToken'
        cs.dependency 'WalletLibrary/VCCrypto'
        cs.dependency 'PromiseKit', '~> 6.18.0'
    end

    s.subspec 'VCNetworking' do |cs|
        cs.name = 'VCNetworking'
        cs.preserve_paths = "#{vcsdkPath}/VCNetworking/**/*.swift"
        cs.source_files= "#{vcsdkPath}/VCNetworking/VCNetworking/**/*.swift"
        cs.dependency 'WalletLibrary/VCEntities'
        cs.dependency 'PromiseKit', '~> 6.18.0'
    end

    s.subspec 'VCServices' do |cs|
        cs.name = 'VCServices'
        cs.preserve_paths = "#{vcsdkPath}/VCServices/**/*.{swift, xcdatamodeld, xcdatamodel}"
        cs.source_files= "#{vcsdkPath}/VCServices/VCServices/**/*.{swift, xcdatamodeld, xcdatamodel}"
        cs.resources = [
            "#{vcsdkPath}/VCServices/VCServices/coreData/VerifiableCredentialDataModel.xcdatamodeld",
            "#{vcsdkPath}/VCServices/VCServices/coreData/VerifiableCredentialDataModel.xcdatamodeld/*.xcdatamodel"]
        cs.preserve_paths = "#{vcsdkPath}/VCServices/VCServices/coreData/VerifiableCredentialDataModel.xcdatamodeld"
        cs.dependency 'WalletLibrary/VCNetworking'
        cs.dependency 'WalletLibrary/VCEntities'
        cs.dependency 'PromiseKit', '~> 6.18.0'
    end

    s.subspec 'Core' do |cs|
        cs.name = 'Core'
        cs.preserve_paths = "WalletLibrary/WalletLibrary/**/*.swift"
        cs.source_files= "WalletLibrary/WalletLibrary/**/*.swift"
        cs.dependency 'WalletLibrary/VCServices'
        cs.dependency 'WalletLibrary/VCEntities'
        cs.dependency 'PromiseKit', '~> 6.18.0'
    end
end