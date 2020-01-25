module DocumentHelper

  def find_document(documents, id)
    documents.find {|doc| doc[:id] == id}
  end

  def get_positions(word, sentence, pointer = 0)
    sentence.find_all_indices(word).map { |num| num + pointer }
  end
end
