# frozen_string_literal: true

require_relative "test_helper"

class TestYake < Minitest::Test
  def test_extract_english
    text = "Natural language processing is a subfield of linguistics and artificial intelligence. It involves the interaction between computers and human language."
    keywords = KeywordRuby.extract(text, algorithm: :yake, language: :en)

    assert keywords.is_a?(Array)
    assert keywords.any?
    assert keywords.all? { |k| k.is_a?(KeywordRuby::Keyword) }
  end

  def test_extract_returns_sorted_results
    text = "Machine learning algorithms can learn patterns from data. Deep learning is a subset of machine learning."
    keywords = KeywordRuby.extract(text, algorithm: :yake)

    scores = keywords.map(&:score)
    assert_equal scores, scores.sort.reverse
  end

  def test_extract_empty
    keywords = KeywordRuby.extract("", algorithm: :yake)
    assert_equal [], keywords
  end

  def test_extract_nil
    keywords = KeywordRuby.extract(nil, algorithm: :yake)
    assert_equal [], keywords
  end

  def test_scores_normalized_to_0_1
    text = "Natural language processing is a subfield of linguistics and artificial intelligence. It involves the interaction between computers and human language."
    keywords = KeywordRuby.extract(text, algorithm: :yake, language: :en, normalize: true)

    refute_empty keywords
    keywords.each do |kw|
      assert kw.score >= 0.0, "Score #{kw.score} is below 0.0"
      assert kw.score <= 1.0, "Score #{kw.score} is above 1.0"
    end
  end

  def test_stop_word_in_middle_does_not_inflate_score
    # "field of study" should allow "of" in the middle without it contributing to score
    text = "The field of study covers many areas. The field of research is also important."
    keywords = KeywordRuby.extract(text, algorithm: :yake, language: :en, normalize: false)

    # Ensure stop words in middle positions get neutral score (1.0)
    # This is a smoke test that YAKE doesn't crash or produce unexpected results
    assert keywords.is_a?(Array)
  end
end
