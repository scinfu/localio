require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class PoWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing .po translations...'
    resource_file = options[:resource_file].nil? ? "default" : options[:resource_file]

    languages.keys.each do |lang|
      puts 'here at 1'
      output_path = File.join(path, "#{lang}/LC_MESSAGES/")
      puts 'here at 2'
      file_name = "#{resource_file}.po"
      puts 'here at 3'

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      puts 'here at 4'
      terms.each do |term|
        puts 'there at 1'
        key = Formatter.format(term.keyword, formatter, method(:po_key_formatter))
        puts 'there at 2'
        translation = term.values[lang].gsub(/\n/, '\n')
        puts 'there at 3'
        segment = Segment.new(key, translation, lang)
        puts 'there at 4'
        segment.key = nil if term.is_comment?
        puts 'there at 5'
        segments.segments << segment
        puts 'there at 6'
      end
      puts 'here at 5'
      TemplateHandler.process_template 'po_localizable.erb', output_path, file_name, segments
      puts " > #{lang.yellow}"
    end

  end

  private

  def self.po_key_formatter(key)
    key
  end
end