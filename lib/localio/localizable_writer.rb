require 'localio/writers/ios_writer'
require 'localio/writers/swift_writer'
require 'localio/writers/json_writer'
require 'localio/writers/rails_writer'
require 'localio/writers/java_properties_writer'
require 'localio/writers/resx_writer'
require 'localio/writers/po_writer'

module LocalizableWriter
  def self.write(platform, languages, terms, path, formatter, options)
    case platform
      when :ios
        IosWriter.write languages, terms, path, formatter, options
      when :swift
        SwiftWriter.write languages, terms, path, formatter, options
      when :json
        JsonWriter.write languages, terms, path, formatter, options
      when :rails
        RailsWriter.write languages, terms, path, formatter, options
      when :java_properties
        JavaPropertiesWriter.write languages, terms, path, formatter, options
      when :resx
        ResXWriter.write languages, terms, path, formatter, options
      when :po
        PoWriter.write languages, terms, path, formatter, options
      else
        raise ArgumentError, 'Platform not supported! Current possibilities are :android, :ios, :json, :rails, :java_properties, :resx'
    end
  end
end
