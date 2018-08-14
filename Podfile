use_frameworks!
platform :osx, '10.13'

def commonPods
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'ID3TagEditor', '~> 2.1.0'
end

target 'Mp3ID3Tagger' do
    commonPods
end

target 'Mp3ID3TaggerTests' do
    commonPods
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest',     '~> 4.0'
end
