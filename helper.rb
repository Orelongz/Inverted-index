require 'json'

module Helper
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      include InstanceMethods
    end
  end

  module ClassMethods
    def directory_exists?(directory)
      File.directory?(directory)
    end

    def file_exists?(filename)
      File.exist?(filename)
    end

    def start
      directory = path_to_directory
      output_file = name_of_output_file
      new(directory, output_file).index_records
    end

    def name_of_output_file
      print "Would you like to name your output file? (Y / N)\n>> "
      answer = gets.chomp.upcase

      if answer == 'Y' || answer == 'YES'
        print "Output file name\n>> "
        output_file = gets.chomp
      else
        puts "Using the default \"indices.json\" folder"
      end

      output_file
    end

    def path_to_directory
      print "Would you like to use a specific directory? (Y / N)\n>> "
      answer = gets.chomp.upcase

      if answer == 'Y' || answer == 'YES'
        print "Provide directory to index\n>> "
        path_to_directory = gets.chomp
        
        while !directory_exists?(path_to_directory)
          puts "Given path does not exist"
          print "Provide a valid directory path to index\n>> "
          path_to_directory = gets.chomp
        end
  
        puts "Directory given is valid."
      else
        puts "Using the default \"test\" folder"
      end

      path_to_directory
    end
  end

  module InstanceMethods
    STOP_WORDS = ['a', 'of', 'the', 'to', 'is']

    def file_exists?(filename)
      self.class.file_exists?(filename)
    end

    def directory_exists?(directory)
      self.class.directory_exists?(directory)
    end

    def write_to_file(filename, data)
      File.open(filename, "w+") do |file|
        file.write(JSON.pretty_generate(data))
      end
    end

    def parse_json(file)
      JSON.parse(
        File.read(file),
        {:symbolize_names => true}
      ) 
    end

    def parse_file(file_with_index, type)
      case type
      when :create
        default_index_structure
      when :search
        file_exists?(file_with_index) ? parse_json(file_with_index) : default_index_structure
      end
    end

    def sanitize_sentence(sentence)
      # TODO: Remove stop words from sentence
      sentence.split.each do |word|
        word.gsub!(/\W/, '')
      end
    end

    def tokenize(sentence)
      sanitize_sentence(sentence.downcase).sort.uniq
    end

    def open_directory(directory)
      begin
        Dir.each_child(directory) { |filename| yield filename }
      rescue Exception => e
        if e.message == "undefined method `each_child' for Dir:Class"
          puts "This program only uses Ruby 2.5 and above"
          puts "Kindly switch to a newer version of Ruby"
        else
          puts "An error occured and program failed to run properly"
          raise e
        end
      end
    end

    def default_token_structure
      {
        frequency: 0,
        documents: []
      }
    end

    def default_index_structure
      { result: {} }
    end

    def previously_indexed?(data, word)
      data[:result][word][:frequency] > 0
    end

    def document_index(documents, document)
      documents.find_index { |doc| doc[:id] == document[:id] }
    end

    def calc_frequency(documents)
      documents.reduce(0) { |total, doc| total + doc[:positions].length }
    end
  end
end

class String
  # https://stackoverflow.com/questions/43329481/find-all-indices-of-a-substring-within-a-string
  def find_all_indices(string)
    self.enum_for(:scan, /(?=#{string})/).map { Regexp.last_match.offset(0).first }
  end
end
