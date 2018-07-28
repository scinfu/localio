require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class SwiftWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing iOS translations...'
    create_constants = options[:create_constants].nil? ? true : options[:create_constants]
    generate_empty_values = options[:generate_empty_values].nil? ? true : options[:generate_empty_values]
    regex_replaces = options[:regex_replace].nil? ? [] : options[:regex_replace]

    constant_segments = nil
    languages.keys.each do |lang|
      output_path = File.join(path, "#{lang}.lproj/")

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      constant_segments = SegmentsListHolder.new lang
      terms.each do |term|
        key = Formatter.format(term.keyword, formatter, method(:swift_key_formatter))
        translation = term.values[lang]

        # Iterate trough regex replacements and apply them to translation
        regex_replaces.each do |replace|
          raise ArgumentError, "Regex replace #{replace.inspect}" unless replace.length == 2
          translation.gsub! replace[0], replace[1]
        end

        segment = Segment.new(key, translation, lang)
        segment.key = nil if term.is_comment?
        segments.segments << segment unless !generate_empty_values && translation.empty?

        unless term.is_comment?
          constant_key = swift_constant_formatter term.keyword
          constant_value = key
          constant_segment = Segment.new(constant_key, constant_value, lang)
          constant_segments.segments << constant_segment
        end
      end

      TemplateHandler.process_template 'ios_localizable.erb', output_path, 'Localizable.strings', segments
      puts " > #{lang.yellow}"
    end

    if create_constants && !constant_segments.nil?
      TemplateHandler.process_template 'swift_constant_localizable.erb', path, 'LocalizableConstants.swift', constant_segments
      puts ' > ' + 'LocalizableConstants.swift'.yellow
    end
  end

  private

  def self.swift_key_formatter(key)
    '_'+key.space_to_underscore.strip_tag.capitalize
  end

  def self.swift_constant_formatter(key)
    'kLocale'+key.space_to_underscore.strip_tag.camel_case
  end
end
