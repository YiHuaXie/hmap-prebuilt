# frozen_string_literal: true

class HMapUtils

  # console log
  def self.log(msg)
    puts '<==== NN Header Map Log ===>'
    puts msg
    puts '<==========================>'
  end

  def self.effective_platform_name(symbolic_name)
    case symbolic_name
    when :ios then %w[iphoneos iphonesimulator]
    when :osx then %w[macosx]
    when :watchos then %w[watchos watchsimulator]
    when :tvos then %w[appletvos appletvsimulator]
    else []
    end
  end

  def self.effective_platforms_names(platforms)
    platforms.flat_map { |name| effective_platform_name(name) }.compact.uniq
  end

  def self.index_of_range(num, range)
    num &= range - 1
    num
  end

  def self.power_of_two?(num)
    num != 0 && (num & (num - 1)).zero?
  end

  def self.next_power_of_two(num)
    num |= (num >> 1)
    num |= (num >> 2)
    num |= (num >> 4)
    num |= (num >> 8)
    num |= (num >> 16)
    num |= (num >> 32)
    num + 1
  end

  def self.hash_set_value(hash, *args)
    args.each do |arg|
      hash.merge(arg)
    end
    hash
  end

  def self.specialize_format(format, swapped)
    modifier = swapped ? '<' : '>'
    format.tr('=', modifier)
  end

  def self.string_downcase_hash(str)
    str.downcase.bytes.inject(0) do |sum, value|
      sum += value * 13
      sum
    end
  end

  def self.update_changed_file(path, contents)
    if File.exist?(path)
      content_stream = StringIO.new(contents)
      identical = File.open(path, 'rb') { |f| FileUtils.compare_stream(f, content_stream) }
      return if identical
    end
    dirname = File.dirname(path)
    Dir.mkdir(dirname) unless File.exist?(dirname)
    File.open(path, 'w') { |f| f.write(contents) }
  end

  def self.swapped_magic?(magic, version)
    magic.eql?(HEADER_CONST[:HMAP_SWAPPED_MAGIC]) && version.eql?(HEADER_CONST[:HMAP_SWAPPED_VERSION])
  end

  def self.magic?(magic)
    magic.eql?(HEADER_CONST[:HMAP_SWAPPED_MAGIC]) || magic.eql?(HEADER_CONST[:HMAP_HEADER_MAGIC_NUMBER])
  end

  def self.safe_encode(string, target_encoding)
    string.encode(target_encoding)
  rescue Encoding::InvalidByteSequenceError
    string.force_encoding(target_encoding)
  rescue Encoding::UndefinedConversionError
    string.encode(target_encoding, fallback: lambda { |c|
      c.force_encoding(target_encoding)
    })
  end
end
