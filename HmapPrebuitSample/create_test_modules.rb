#!/usr/bin/env ruby
# frozen_string_literal: true

$word_list_part_size = 25
$word_list = %w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
$third_module = %w[AFNetworking Masonry SDWebImage MJRefresh MBProgressHUD]
$scrpit_dir = File.dirname(File.expand_path(__FILE__))

def main(start_dir)
  puts start_dir
  $module_dir_path = "#{start_dir}/AllModules"
  `rm -rf #{$module_dir_path}` if File.exist?($module_dir_path)
  `mkdir #{$module_dir_path}`

  strings = ''
  (0..$word_list_part_size).each do |i|
    (0..$word_list_part_size).each do |j|
      word_str = $word_list[i] + $word_list[j]
      create_module(word_str, i)
      strings += "\t pod 'Test#{word_str}Module', :path => '../AllModules/Test#{word_str}Module'\n"
    end
  end

  code = "
require_relative \"\#{File.expand_path('../../', Pod::Config.instance.installation_root)}/hmap_prebuilt.rb\"
# use_frameworks!
platform :ios, '10.0'

target 'HmapPrebuiltSample_Example' do
#{strings}

  target 'HmapPrebuiltSample_Tests' do
    inherit! :search_paths

    
  end
end

post_install do |installer|
  hmap_prebuilt(installer)
end
"
  file = File.new("#{start_dir}/Example/Podfile", 'w+')
  file.syswrite(code)

  `cd Example && pod install`
end

def create_module(str, i)
  module_name = "Test#{str}Module"
  `mkdir #{$module_dir_path}/#{module_name}`
  `mkdir #{$module_dir_path}/#{module_name}/Classes`

  # kit
  code = "//
//  Test#{str}Kit.h
//
#ifndef Test#{str}Kit_h
#define Test#{str}Kit_h

#import \"Test#{str}Obj1.h\"
#import \"Test#{str}Obj2.h\"

#endif /* Test#{str}Kit_h */
"
  file = File.new("#{$module_dir_path}/#{module_name}/Classes/Test#{str}Kit.h", 'w+')
  file.syswrite(code)

  all_modules = []
  third_modules = get_three_third_modules
  third_module_import = get_third_module_import(third_modules)
  third_modules.each { |m| all_modules = all_modules << m }

  local_modules_str_list = get_local_modules_str(i)
  local_modules = local_modules_str_list.map { |str| "Test#{str}Module" }
  local_modules_import = get_local_module_import(local_modules_str_list)
  local_modules.each { |m| all_modules = all_modules << m }

  # obj1 h
  code = "//
//  Test#{str}Obj1.h
//

#import <Foundation/Foundation.h>
#{third_module_import}
  #{local_modules_import}
NS_ASSUME_NONNULL_BEGIN

@interface Test#{str}Obj1 : NSObject

+ (void)test;

@end

NS_ASSUME_NONNULL_END

"
  file = File.new("#{$module_dir_path}/#{module_name}/Classes/Test#{str}Obj1.h", 'w+')
  file.syswrite(code)

  code = "//
//  Test#{str}Obj1.m
//

#import \"Test#{str}Obj1.h\"

@implementation Test#{str}Obj1

+ (void)test {
    NSLog(@\"Test#{str}Obj1 test\");
}

@end
"
  file = File.new("#{$module_dir_path}/#{module_name}/Classes/Test#{str}Obj1.m", 'w+')
  file.syswrite(code)

  # obj2
  third_modules = get_three_third_modules
  third_module_import = get_third_module_import(third_modules)
  third_modules.each { |m| all_modules = all_modules << m }

  local_modules_str_list = get_local_modules_str(i)
  local_modules = local_modules_str_list.map { |str| "Test#{str}Module" }
  local_modules_import = get_local_module_import(local_modules_str_list)
  local_modules.each { |m| all_modules = all_modules << m }

  code = "//
//  Test#{str}Obj2.h
//

#import <Foundation/Foundation.h>
#{third_module_import}
  #{local_modules_import}
NS_ASSUME_NONNULL_BEGIN

@interface Test#{str}Obj2 : NSObject

+ (void)test;

@end

NS_ASSUME_NONNULL_END

"
  file = File.new("#{$module_dir_path}/#{module_name}/Classes/Test#{str}Obj2.h", 'w+')
  file.syswrite(code)

  code = "//
//  Test#{str}Obj2.m
//

#import \"Test#{str}Obj2.h\"

@implementation Test#{str}Obj2

+ (void)test {
    NSLog(@\"Test#{str}Obj2 test\");
}

@end
"
  file = File.new("#{$module_dir_path}/#{module_name}/Classes/Test#{str}Obj2.m", 'w+')
  file.syswrite(code)

  all_modules = all_modules & all_modules
  strings = ''
  all_modules.each { |m| strings += "s.dependency '#{m}'\n" }

  code = "
Pod::Spec.new do |s|
  s.name             = '#{module_name}'
  s.version          = '1.0.0'
  s.summary          = 'A short description of #{module_name}.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/NeroXie/#{module_name}'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeroXie' => 'xyh30902@163.com' }
  s.source           = { :git => 'https://github.com/NeroXie/#{module_name}.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  # s.static_framework = true
  s.source_files = 'Classes/*'

  # s.resource_bundles = {
  #   '#{module_name}' => ['#{module_name}/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  #{strings}
end
"

  file = File.new("#{$module_dir_path}/#{module_name}/#{module_name}.podspec", 'w+')
  file.syswrite(code)

  `cp -rf #{$scrpit_dir}/LICENSE #{$module_dir_path}/#{module_name}`

end

def get_three_third_modules
  modules = []
  while modules.length < 3
    rand_num = rand(5)
    modules = modules << rand_num if modules.include?(rand_num) == false
  end

  modules.map { |index| $third_module[index] }
end

def get_third_module_import(modules)
  strings = ''
  modules.each do |string|
    case string
    when 'MBProgressHUD'
      strings += "#{rand(2).even? ? '#import "MBProgressHUD.h"' : '#import <MBProgressHUD/MBProgressHUD.h>'}\n"
    when 'Masonry'
      strings += "#{rand(2).even? ? '#import "Masonry.h"' : '#import <Masonry/Masonry.h>'}\n"
    when 'MJRefresh'
      strings += "#{rand(2).even? ? '#import "MJRefresh.h"' : '#import <MJRefresh/MJRefresh.h>'}\n"
    when 'AFNetworking'
      strings += "#{rand(2).even? ? '#import "AFNetworking.h"' : '#import <AFNetworking/AFHTTPSessionManager.h>'}\n"
    when 'SDWebImage'
      strings += "#{rand(2).even? ? '#import "UIImageView+WebCache.h"' : '#import <SDWebImage/UIImageView+WebCache.h>'}\n"
    end
  end

  strings
end

def get_local_modules_str(i)
  return [] if i >= 0 && i < 10

  modules = []
  while modules.length < 3
    rand_num = i >= 10 && i < 18 ? rand(0..9) : rand(10..17)
    modules = modules << rand_num if modules.include?(rand_num) == false
  end

  modules.map do |index|
    "#{$word_list[index]}#{$word_list[rand($word_list_part_size)]}"
  end
end

def get_local_module_import(str_list)
  strings = ''
  str_list.each do |string|
    case rand(3)
    when 0
      strings += "#{rand(2).even? ? "#import \"Test#{string}Kit.h\"" : "#import <Test#{string}Module/Test#{string}Kit.h>"}\n"
    when 1
      strings += "#{rand(2).even? ? "#import \"Test#{string}Obj1.h\"" : "#import <Test#{string}Module/Test#{string}Obj1.h>"}\n"
    when 2
      strings += "#{rand(2).even? ? "#import \"Test#{string}Obj2.h\"" : "#import <Test#{string}Module/Test#{string}Obj2.h>"}\n"
    end
  end

  strings
end

main($scrpit_dir)
