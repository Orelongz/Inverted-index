require_relative './document_helper'

class Document
  include DocumentHelper
  attr_reader :id, :filename, :file_path

  @@id = 0

  def initialize(filename, file_path)
    @filename = filename
    @file_path = file_path
    @id = self.class.assign_id
  end

  class << self
    def assign_id
      @@id += 1
      ids_list << @@id

      @@id
    end

    def ids_list
      @@ids = []
    end
  
    def exists?(id)
      @@ids && @@ids.include?(id) ? true : false
    end
  end

  def open_file
    File.open(@file_path) do |file|
      yield file
    end
  end

  def index_word(word, sentence)
    to_s.merge({ positions: get_positions(word, sentence) })
  end

  def to_s
    {
      id: @id,
      filename: @filename,
      file_path: @file_path,
    }
  end
end
