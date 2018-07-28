require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'
require 'nokogiri'

class AndroidWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing Android translations...'
    default_language = options[:default_language]
    regex_replaces = options[:regex_replace].nil? ? [] : options[:regex_replace]

    languages.keys.each do |lang|
      output_path = File.join(path,"values-#{lang}/")
      output_path = File.join(path,'values/') if default_language == lang

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      terms.each do |term|
        key = Formatter.format(term.keyword, formatter, method(:android_key_formatter))
        translation = android_parsing term.values[lang]

        # Iterate trough regex replacements and apply them to translation
        regex_replaces.each do |replace|
          raise ArgumentError, "Regex replace #{replace.inspect}" unless replace.length == 2
          translation.gsub! replace[0], replace[1]
        end

        segment = Segment.new(key, translation, lang)
        segment.key = nil if term.is_comment?
        segments.segments << segment
      end

      TemplateHandler.process_template 'android_localizable.erb', output_path, 'strings.xml', segments
      puts " > #{lang.yellow}"
    end

  end

  private

  def self.android_key_formatter(key)
    key.space_to_underscore.strip_tag.downcase
  end

  def self.android_parsing(term)
    term
    #term.gsub('& ','&amp; ').gsub('...', '…').gsub('%@', '%s')
  end
end