# frozen_string_literal: true

require_relative "test_helper"

# --- TextRank algorithm ---

class TestTextRank < Minitest::Test
  def test_extract_english
    text = "Natural language processing is a field of artificial intelligence that deals with the interaction between computers and human language. NLP enables computers to understand and generate human language."
    results = KeywordRuby.extract(text, algorithm: :textrank)
    assert results.size > 0
    assert results.all? { |k| k.is_a?(KeywordRuby::Keyword) }
  end

  def test_extract_empty
    assert_equal [], KeywordRuby.extract("", algorithm: :textrank)
  end

  def test_extract_nil
    assert_equal [], KeywordRuby.extract(nil, algorithm: :textrank)
  end

  def test_scores_normalized
    text = "Machine learning and deep learning are branches of artificial intelligence research and development."
    results = KeywordRuby.extract(text, algorithm: :textrank, normalize: true)
    results.each do |kw|
      assert kw.score >= 0.0, "Score #{kw.score} should be >= 0.0"
      assert kw.score <= 1.0, "Score #{kw.score} should be <= 1.0"
    end
  end

  def test_respects_top_n
    text = "Natural language processing and machine learning are important fields in computer science and artificial intelligence research."
    results = KeywordRuby.extract(text, algorithm: :textrank, top_n: 3)
    assert results.size <= 3
  end
end

# --- Cross-algorithm comparison ---

class TestCrossAlgorithm < Minitest::Test
  def test_all_algorithms_return_keywords
    text = "Natural language processing enables computers to understand and generate human language using machine learning models."
    KeywordRuby::ALGORITHMS.each do |algo|
      results = KeywordRuby.extract(text, algorithm: algo)
      assert results.is_a?(Array), "#{algo} should return Array"
      assert results.all? { |k| k.is_a?(KeywordRuby::Keyword) }, "#{algo} should return Keyword objects"
    end
  end

  def test_all_algorithms_handle_empty
    KeywordRuby::ALGORITHMS.each do |algo|
      assert_equal [], KeywordRuby.extract("", algorithm: algo)
    end
  end

  def test_normalized_scores_in_range
    text = "Artificial intelligence and machine learning are transforming the world of technology and software engineering."
    KeywordRuby::ALGORITHMS.each do |algo|
      results = KeywordRuby.extract(text, algorithm: algo, normalize: true)
      results.each do |kw|
        assert kw.score >= 0.0 && kw.score <= 1.0, "#{algo}: score #{kw.score} out of range"
      end
    end
  end
end

# --- Multi-language extraction ---

class TestMultiLanguage < Minitest::Test
  def test_french_extraction
    text = "Le traitement automatique du langage naturel est un domaine important de recherche en intelligence artificielle et en informatique."
    results = KeywordRuby.extract(text, language: :fr, algorithm: :rake)
    assert results.size > 0
  end

  def test_german_extraction
    text = "Maschinelles Lernen und künstliche Intelligenz sind wichtige Forschungsbereiche der modernen Informatik."
    results = KeywordRuby.extract(text, language: :de, algorithm: :rake)
    assert results.size > 0
  end

  def test_spanish_extraction
    text = "El procesamiento del lenguaje natural es un campo importante de la inteligencia artificial y la informática moderna."
    results = KeywordRuby.extract(text, language: :es, algorithm: :yake)
    assert results.size > 0
  end

  def test_malay_extraction
    text = "Kecerdasan buatan dan pembelajaran mesin adalah bidang yang penting dalam sains komputer moden dan teknologi maklumat."
    results = KeywordRuby.extract(text, language: :ms, algorithm: :rake)
    assert results.size > 0
  end

  def test_all_new_languages_supported
    %i[fr de es pt nl ms ar ja].each do |lang|
      results = KeywordRuby.extract("test text for language support", language: lang, algorithm: :rake)
      assert results.is_a?(Array), "#{lang} should work"
    end
  end
end

# --- Batch extraction with shared state ---

class TestBatchExtraction < Minitest::Test
  def test_tfidf_batch_shares_corpus
    docs = [
      "Machine learning is a subset of artificial intelligence focused on learning from data.",
      "Deep learning uses neural networks with multiple layers for feature extraction.",
      "Natural language processing applies machine learning to understand human language."
    ]
    results = KeywordRuby.extract_batch(docs, algorithm: :tfidf)
    assert_equal 3, results.size
    assert results.all? { |r| r.is_a?(Array) }
  end

  def test_rake_batch
    docs = ["Hello world", "Goodbye world"]
    results = KeywordRuby.extract_batch(docs, algorithm: :rake)
    assert_equal 2, results.size
  end
end

# --- Custom stop words ---

class TestCustomStopWords < Minitest::Test
  def setup
    KeywordRuby.reset_configuration!
  end

  def teardown
    KeywordRuby.reset_configuration!
  end

  def test_custom_stop_words
    KeywordRuby.configure { |c| c.custom_stop_words = ["machine", "learning"] }
    text = "Machine learning and deep learning are branches of artificial intelligence."
    results = KeywordRuby.extract(text, algorithm: :rake)

    phrases = results.map(&:phrase)
    # "machine" and "learning" should be treated as stop words
    phrases.each do |phrase|
      refute phrase.split.include?("machine"), "Expected 'machine' to be filtered as custom stop word"
    end
  end
end

# --- Strict stop word loading ---

class TestStrictStopWords < Minitest::Test
  def test_strict_mode_raises_for_missing_language
    assert_raises(KeywordRuby::Error) do
      KeywordRuby::TextProcessing::StopWords.new(language: :xx, strict: true)
    end
  end

  def test_non_strict_mode_returns_empty_for_missing
    sw = KeywordRuby::TextProcessing::StopWords.new(language: :xx, strict: false)
    refute sw.stop_word?("anything")
  end
end

# --- Performance benchmarks ---

class TestPerformance < Minitest::Test
  def test_extraction_latency
    text = "Natural language processing and machine learning are important fields. " * 50

    # Warm up
    KeywordRuby.extract(text, algorithm: :rake)

    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    50.times { KeywordRuby.extract(text, algorithm: :rake) }
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    avg_ms = (elapsed / 50.0) * 1000
    assert avg_ms < 100, "RAKE extraction took #{avg_ms.round(2)}ms avg, target <100ms"
  end

  def test_batch_performance
    docs = Array.new(100) { "Machine learning and artificial intelligence research." }

    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    KeywordRuby.extract_batch(docs, algorithm: :rake)
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    assert elapsed < 10.0, "Batch of 100 took #{elapsed.round(2)}s, target <10s"
  end
end

# --- Memory test ---

class TestMemory < Minitest::Test
  def test_large_tfidf_corpus
    # Create a moderately large corpus
    docs = Array.new(500) { |i| "Document #{i} about topic #{i % 10} with various words and phrases for testing." }

    extractor = KeywordRuby::Extractors::Tfidf.new
    extractor.fit(docs)

    result = extractor.extract("Document about topic testing with words and phrases.")
    assert result.is_a?(Array)
  end
end
