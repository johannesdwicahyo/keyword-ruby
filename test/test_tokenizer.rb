# frozen_string_literal: true

require_relative "test_helper"

class TestTokenizer < Minitest::Test
  def test_basic_tokenization
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("Hello World")
    assert_equal %w[hello world], tokens
  end

  def test_contraction_dont
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("I don't think so")
    assert_includes tokens, "not"
    refute tokens.any? { |t| t.include?("'") }
  end

  def test_contraction_theyre
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("They're going home")
    assert_includes tokens, "are"
  end

  def test_contraction_weve
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("We've seen it")
    assert_includes tokens, "have"
  end

  def test_contraction_cant
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("I can't believe it")
    assert_includes tokens, "not"
  end

  def test_contraction_ill
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("I'll be there")
    assert_includes tokens, "will"
  end

  def test_contraction_im
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("I'm happy")
    assert_includes tokens, "am"
  end

  def test_smart_quotes_normalized
    # Smart/curly apostrophe should be treated like regular apostrophe
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("don\u2019t stop")
    assert_includes tokens, "not"
  end

  def test_possessive_removed
    tokens = KeywordRuby::TextProcessing::Tokenizer.tokenize("the dog's bone")
    assert_includes tokens, "dog"
    refute tokens.any? { |t| t.include?("'") }
  end

  def test_sentences
    sentences = KeywordRuby::TextProcessing::Tokenizer.sentences("Hello world. How are you? Fine!")
    assert_equal 3, sentences.length
  end
end
