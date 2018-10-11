class TagSearchQueryParser

  def initialize(tag_search_query)
    @tag_search_query = tag_search_query
  end

  def parse()
    tags_with_sign = @tag_search_query.scan(/(\+\w+|\-\w+)/).flatten
    positive_tags_with_sign = extract_tags_with_sign(tags_with_sign, '+')
    negative_tags_with_sign = extract_tags_with_sign(tags_with_sign, '-')

    {
      :+ => normalize_tags(positive_tags_with_sign),
      :- => normalize_tags(negative_tags_with_sign)
    }
  end

  private

  def extract_tags_with_sign(tags, sign)
    tags.select{|tag| tag.start_with?(sign)}
  end

  def normalize_tags(tags)
    tags.map{|tag| tag.slice(1, tag.size)}
  end
end
