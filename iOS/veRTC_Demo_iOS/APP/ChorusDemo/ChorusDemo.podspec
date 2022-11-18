Pod::Spec.new do |spec|
  spec.name         = 'ChorusDemo'
  spec.version      = '1.0.0'
  spec.summary      = 'ChorusDemo APP'
  spec.description  = 'ChorusDemo App Demo..'
  spec.homepage     = 'https://github.com/volcengine'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'author' => 'volcengine rtc' }
  spec.source       = { :path => './' }
  spec.ios.deployment_target = '9.0'
  
  spec.source_files = '**/*.{h,m,c,mm,a}'
  spec.resource_bundles = {
    'ChorusDemo' => ['Resource/*.xcassets', 'Resource/*.lproj']
  }
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  spec.resources = ['Resource/*.{jpg}']
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "Core.h"',
                                '#import "ChorusDemoConstants.h"',
                                '#import "ChorusUserModel.h"',
                                '#import "ChorusRoomModel.h"',
                                '#import "ChorusSongModel.h"'
                                
  spec.dependency 'Core'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
  spec.dependency 'VolcEngineRTC'
  spec.dependency 'veByteMusic'
  spec.dependency 'SDWebImage'

end
