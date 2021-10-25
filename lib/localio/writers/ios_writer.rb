require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class IosWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing iOS translations...'
    create_constants = options[:create_constants].nil? ? true : options[:create_constants]
    generate_empty_values = options[:generate_empty_values].nil? ? true : options[:generate_empty_values]
    regex_replaces = options[:regex_replace].nil? ? [] : options[:regex_replace]
    file_name = options[:file_name].nil? ? 'Localizable' : options[:file_name]

    constant_segments = nil
    languages.keys.each do |lang|
      output_path = File.join(path, "#{lang}.lproj/")

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      constant_segments = SegmentsListHolder.new lang
      terms.each do |term|
        key = Formatter.format(term.keyword, formatter, method(:ios_key_formatter))
        translation = term.values[lang]

        # Iterate trough regex replacements and apply them to translation
        regex_replaces.each do |replace|
          raise ArgumentError, "Regex replace #{replace.inspect}" unless replace.length == 2
          translation.gsub! replace[0], replace[1]
        end

        segment = Segment.new(key, translation, lang)
        segment.key = nil if term.is_comment?
        segments.segments << segment unless !generate_empty_values && translation.blank?

        unless term.is_comment?
          constant_key = ios_constant_formatter term.keyword
          constant_value = key
          constant_segment = Segment.new(constant_key, constant_value, lang)
          constant_segments.segments << constant_segment
        end
      end

      TemplateHandler.process_template 'ios_localizable.erb', output_path, file_name+'.strings', segments
      puts " > #{lang.yellow}"
    end

    if create_constants && !constant_segments.nil?
      TemplateHandler.process_template 'ios_constant_localizable.erb', path, 'LocalizableConstants.h', constant_segments
      puts ' > ' + 'LocalizableConstants.h'.yellow
    end

  end

  private

  def self.ios_key_formatter(key)
    '_'+key.space_to_underscore.strip_tag.capitalize
  end

  def self.ios_constant_formatter(key)
    'kLocale'+key.space_to_underscore.strip_tag.camel_case
  end

end


class AndroidWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing Android translations...'
    default_language = options[:default_language]
    file_name = options[:file_name].nil? ? 'strings' : options[:file_name]

    languages.keys.each do |lang|
      output_path = File.join(path,"values-#{lang}/")
      output_path = File.join(path,'values/') if default_language == lang

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      terms.each do |term|
        key = Formatter.format(term.keyword, formatter, method(:android_key_formatter))
        translation = android_parsing term.values[lang]
        segment = Segment.new(key, translation, lang)
        segment.key = nil if term.is_comment?
        segments.segments << segment
      end

      TemplateHandler.process_template 'android_localizable.erb', output_path, file_name+'.xml', segments
      puts " > #{lang.yellow}"
    end

  end

  private

  def self.android_key_formatter(key)
    key.space_to_underscore.strip_tag.downcase
  end

  def self.android_parsing(term)
    if !term.nil? && term.respond_to?(:gsub)
        term.gsub('&','&amp;').gsub('...', '…').gsub('%@', '%s')
    end
  end
end
