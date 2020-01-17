require 'json'
require_relative './helper'

class InvertedIndex
  include Helper

  def initialize(directory = nil, output_file = nil)
    # if nil is passed as arg, args will be nil
    # and instance variable will not be set properly
    @directory = directory || "test"
    @output_file = output_file || "indices.json"
    @data = parse_output_file
  end

  def parse_output_file
    file_exists?(@output_file) ? @data = JSON.parse(File.read(@output_file)) : {}
  end

  def search_index_records_for(terms)
    sanitize_sentence(terms).each do |word|
      puts "[[#{word}]]"

      if @data[word]
        @data[word].each.with_index(1)  do |file, index|
          puts "#{index}. #{file}\n\n"
        end
      else
        puts "No index found!!!\n\n"
      end
    end
  end

  def index_records
    open_directory(@directory) do |filename|
      file_path = "#{@directory}/#{filename}"

      File.open(file_path) do |file|
        create_index(file, file_path)
      end
    end

    write_to_file(@output_file, @data)
  end

  def create_index(file, file_path)
    file.each do |sentence|      
      sanitize_sentence(sentence).each do |word|
        @data[word] ||= []
        @data[word] << file_path unless @data[word].include? file_path
      end
    end
  end
end

# start the index
InvertedIndex.start

# search for words in the index
InvertedIndex.new.search_index_records_for('pelumi,? dlsd? was here a trying')
