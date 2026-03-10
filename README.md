# keyword-ruby

Keyword extraction for Ruby using RAKE, YAKE, and TF-IDF algorithms. Extract the most relevant terms from any text.

## Installation

```ruby
gem "keyword-ruby"
```

## Usage

```ruby
require "keyword_ruby"

text = "Ruby is a dynamic programming language focused on simplicity and productivity."

# RAKE (Rapid Automatic Keyword Extraction)
keywords = KeywordRuby.extract(text, algorithm: :rake, top_n: 5)

# YAKE (Yet Another Keyword Extractor)
keywords = KeywordRuby.extract(text, algorithm: :yake, top_n: 5)

# TF-IDF
extractor = KeywordRuby::Extractors::Tfidf.new
extractor.fit(corpus)  # optional: fit on a corpus
keywords = extractor.extract(text, top_n: 5)

keywords.each { |kw| puts "#{kw.text}: #{kw.score}" }
```

## Features

- RAKE with proper co-occurrence degree calculation
- YAKE with stop word handling in multi-word phrases
- TF-IDF with optional corpus fitting (falls back to TF-only)
- Score normalization to 0.0-1.0 range
- English contraction expansion (don't → do not)
- Input validation and language support

## License

MIT
