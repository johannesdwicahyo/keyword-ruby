# keyword-ruby

Pure Ruby keyword and keyphrase extraction using RAKE, YAKE, and TF-IDF algorithms.

## Installation

```ruby
gem "keyword-ruby", "~> 0.1"
```

## Usage

```ruby
require "keyword_ruby"

# RAKE (default)
keywords = KeywordRuby.extract("Your text here...")
keywords.each { |kw| puts "#{kw.phrase}: #{kw.score}" }

# YAKE
keywords = KeywordRuby.extract(text, algorithm: :yake)

# TF-IDF (with corpus)
extractor = KeywordRuby::Extractors::Tfidf.new
extractor.fit(corpus_documents)
keywords = extractor.extract(text)

# Batch extraction
results = KeywordRuby.extract_batch(documents, algorithm: :rake, top_n: 5)
```

## License

MIT
