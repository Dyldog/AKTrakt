source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

abstract_target 'Internal' do
    pod "AKTrakt", :path => "."
    pod "Alamofire", '~> 4.7.3'
    pod "AlamofireImage"

    target 'AKTrakt iOS' do
        platform :ios, '11.0'
    end

    target 'AKTrakt tvOS' do
        platform :tvos, '11.0'
    end

    target 'Tests' do
        platform :ios, '11.0'
    end
end


