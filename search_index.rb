require_relative './helper'
require_relative './document'

class SearchIndex
  include Helper

  def self.search_for(terms)
    tokenize(terms).each do |word|
      if @data[word]
        @data[word].each.with_index(1)  do |file, index|
          puts "#{index}. #{file}\n\n"
        end
      else
        puts "No index found!!!\n\n"
      end
    end
  end
end

# search for words in the index
# SearchIndex.search_for('pelumi,? dlsd? was here a trying')
