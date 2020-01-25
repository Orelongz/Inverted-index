require_relative './helper'
require 'pry'

class SearchIndex
  include Helper

  def initialize(file_with_index = nil)
    @file_with_index = file_with_index || "indices.json"
    @data = parse_file(@file_with_index, :search)
  end

  def search_for(terms)
    tokenize(terms).each do |word|
      result = Hash[word, nil]
      if @data[:result][word.to_sym]
        result[word] = @data[:result][word.to_sym]
      end

      pp result
      puts "\n"
    end
  end
end

# search for words in the index
SearchIndex.new.search_for('pelumi,? dlsd? was here a trying')
