require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class PoWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing .po translations...'
    resource_file = options[:resource_file].nil? ? "default" : options[:resource_file]

    languages.keys.each do |lang|
      output_path = File.join(path, "#{lang}/LC_MESSAGES/")
      file_name = "#{resource_file}.po"

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      terms.each do |term|
        key = Formatter.format(term.keyword, formatter, method(:po_key_formatter))
        next if term.values[lang].empty?
        translation = term.values[lang].gsub(/\n/, '\n')
        segment = Segment.new(key, translation, lang)
        segment.key = nil if term.is_comment?
        segments.segments << segment
      end
      TemplateHandler.process_template 'po_localizable.erb', output_path, file_name, segments
      puts " > #{lang.yellow}"
    end

  end

  private

  def self.po_key_formatter(key)
    key
  end
end