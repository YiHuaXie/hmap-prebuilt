require 'pathname'
require 'json'
require 'fileutils'
require 'xcodeproj'
require 'pp'

require File.join(File.dirname(__FILE__), './hmap-prebuilt/hmap_utils.rb')
require File.join(File.dirname(__FILE__), './hmap-prebuilt/hmap_saver.rb')
require File.join(File.dirname(__FILE__), './hmap-prebuilt/hmap_bucket.rb')
require File.join(File.dirname(__FILE__), './hmap-prebuilt/mapfile.rb')

def hmap_prebuilt(installer)
  HMapUtils.log('statrt to prebuilt !!!')
  start_time = Time.now
  
  # 遍历所有头文件, 获取头文件绝对路径，并将结果保存在hmap_hash中
  hmap_hash = {}
  installer.pod_targets.each do |target|
    target.header_mappings_by_file_accessor.each_value do |header_paths_hash|
      # {
      # #<Pathname:TestAAModule>=>[
      # #<Pathname:xxx/xxx/TestAAKit.h>,
      # #<Pathname:xxx/xxx/TestAAObj1.h>,
      # #<Pathname:xxx/xxx/TestAAObj2.h>]
      # }
      header_paths_hash.each do |path_name, header_paths|
        header_paths.each do |header_path|
          short_header = header_path.basename # a.h
          long_header = File.join(path_name.to_s.include?('/') ? path_name.basename : path_name, short_header) # a/a.h
          hmap_hash[short_header.to_s] = Hash[
            'prefix' => "#{header_path.dirname.to_s}/",
            'suffix' => header_path.basename.to_s
          ]
          hmap_hash[long_header.to_s] = Hash[
            'prefix' => "#{header_path.dirname.to_s}/",
            'suffix' => header_path.basename.to_s
          ]
        end
      end
    end
  end

  hmap_json = JSON.pretty_generate(hmap_hash)
  # 保存为 json 文件
  hmap_prebuilt_dir_name = '/Pods/nn_hmap_prebuilt'
  hmap_prebuilt_name = 'nn_hmap_prebuilt'
  hmap_prebuilt_dir = File.join(Dir.pwd, hmap_prebuilt_dir_name)
  hmap_prebuilt_file_json_path = File.join(hmap_prebuilt_dir, "#{hmap_prebuilt_name}.json")
  hmap_prebuilt_file_hmap_path = File.join(hmap_prebuilt_dir, "#{hmap_prebuilt_name}.hmap")
  `mkdir #{hmap_prebuilt_dir}` unless File.directory?(hmap_prebuilt_dir)
  json_file = File.new(hmap_prebuilt_file_json_path, 'w')
  json_file << hmap_json
  json_file.close

  HMapUtils.log("hmap prebuiltn json path: #{hmap_prebuilt_file_json_path}")

  # 将json转换为hmap
  hmap_json = JSON.parse(File.read(hmap_prebuilt_file_json_path))
  HMapSaver.new_from_buckets(hmap_json).write_to(hmap_prebuilt_file_hmap_path)
  `rm -rf #{hmap_prebuilt_file_json_path}`
  HMapUtils.log('prebuilt header map finish, used %.2f s' % (Time.now - start_time).to_f)

  # 关闭所有组件的 USE_HEADERMAP, 其余手动关闭
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['USE_HEADERMAP'] = 'NO'
    end
  end

  # 替换全部 pod 的 HEADER_SEARCH_PATH
  start_time = Time.now
  hmap_file_in_path = "\"${PODS_ROOT}/nn_hmap_prebuilt/#{hmap_prebuilt_name}.hmap\""
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      next unless config.base_configuration_reference

      xcconfig_path = config.base_configuration_reference.real_path
      build_settings = Hash[*File.read(xcconfig_path).lines.map{ |x| x.split(/\s*=\s*/, 2) }.flatten]
      next unless build_settings.keys.include?('HEADER_SEARCH_PATHS')

      content = File.read(xcconfig_path)
      content = content.gsub(build_settings['HEADER_SEARCH_PATHS'], "#{hmap_file_in_path}\n")
      File.open(xcconfig_path, 'w') do |file|
        file.truncate(0) # 清空
        file.puts content # 写入新的内容
      end
    end
  end
  HMapUtils.log('replace `Header Search Path`, used %.2f s' % (Time.now - start_time).to_f)
end

