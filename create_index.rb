require_relative './helper'
require_relative './document'
require 'pry'

class CreateIndex
  include Helper

  def initialize(directory = nil, file_with_index = nil)
    # if nil is passed as arg, args will be nil
    # and instance variable will not be set properly
    @directory = directory || "test"
    @file_with_index = file_with_index || "indices.json"
    @data = parse_file(@file_with_index, :create)
  end

  def index_records
    open_directory(@directory) do |filename|
      file_path = "#{@directory}/#{filename}"
      document = Document.new(filename, file_path)
      document.open_file { |file| create_index(file, document) }
    end

    write_to_file(@file_with_index, @data)
  end

  def create_index(file, document)
    @file_pointer = 1

    file.each do |sentence|
      tokenize(sentence).each { |word| build_token(word, sentence, document) }

      @file_pointer += file.pos
    end
  end

  def build_token(word, sentence, document)
    @data[:result][word] = default_token_structure unless @data[:result][word]
    update_indexed_token(word, sentence, document)
  end

  def update_indexed_token(word, sentence, document)
    documents = @data[:result][word][:documents] || []
    positions = document.get_positions(word, sentence, @file_pointer)

    if previously_indexed?(@data, word) && doc_index = document_index(documents, document.to_s)
      documents[doc_index][:positions] += positions
    else
      documents << document.to_s.merge({ positions: positions })
    end
    
    @data[:result][word][:documents] = documents
    @data[:result][word][:frequency] = calc_frequency(documents)
  end
end

# start the index
CreateIndex.start
