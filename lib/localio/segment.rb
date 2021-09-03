require 'localio/string_helper'

class Segment

  attr_accessor :key, :translation, :language

  def initialize(key, translation, language)
    @key = key

    if translation.respond_to?(:replace_escaped)
        @translation = translation.replace_escaped
    else
        @translation = translation
    end
    @language = language
  end

  def is_comment?
    @key == nil
  end
end
