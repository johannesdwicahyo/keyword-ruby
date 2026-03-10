# keyword-ruby Milestones

## Current State (v0.1.0)

- RAKE, YAKE, TF-IDF keyword extraction algorithms
- English and Indonesian stop word lists
- Module-level `extract`/`extract_batch` API
- 13 tests, 21 assertions — all passing

---

## v0.1.1 — Algorithm Fixes & Edge Cases

### Fix
- [ ] **RAKE co-occurrence degree calculation** — Current implementation counts `words.length - 1` as degree for all words in a phrase; should use actual co-occurrence matrix where `degree(w) = sum of all words co-occurring with w`
- [ ] **TF-IDF without corpus** — `Math.log(@doc_count + 1)` when `@doc_count` is 0 yields `Math.log(1) = 0`, making all scores 0; use raw term frequency when no corpus is fitted
- [ ] **YAKE candidate generation bug** — Middle stop words allowed in multi-word candidates; filter phrases containing stop words in middle positions
- [ ] **Tokenizer contraction handling** — "don't" splits into "don", "t"; preserve contractions and hyphenated words
- [ ] **Empty result on single stop word** — `extract("the")` should return `[]` not crash

### Add
- [ ] Input validation: nil text, non-string input, max text length
- [ ] **Keyword deduplication** — RAKE can produce overlapping phrases ("machine learning" and "learning algorithms"); merge overlapping candidates
- [ ] **Keyword position tracking** — Record first occurrence position in text for each keyword
- [ ] **Score normalization** — Normalize scores to 0.0..1.0 range across all algorithms for comparability

### Test
- [ ] RAKE mathematical correctness (hand-computed expected scores)
- [ ] TF-IDF with and without corpus
- [ ] Single-word documents, stop-words-only documents
- [ ] Very long documents (>10K words) — performance
- [ ] Unicode text (accented characters, CJK)
- [ ] Invalid algorithm name raises proper error

---

## v0.2.0 — YAKE Improvements & Batch Processing

### Add: Algorithms
- [ ] **TextRank** — Graph-based keyword extraction (PageRank on word co-occurrence graph)
- [ ] **YAKE improvements** — Proper statistical features (casing, word position, word frequency, relatedness to context, word different sentence)

### Add: Languages
- [ ] Stop words for: Malay (MS), Dutch (NL), French (FR), German (DE), Spanish (ES), Portuguese (PT), Arabic (AR), Japanese (JA)
- [ ] **Auto-language detection** — Optional lingua-ruby integration: `extract(text, language: :auto)`

### Add: Features
- [ ] **Batch extraction with shared state** — `extract_batch` reuses stop word loading and vocabulary
- [ ] **Keyword clustering** — Group related keywords by semantic similarity
- [ ] **N-gram extraction** — Character-level n-grams for CJK text support
- [ ] **Domain stop words** — `KeywordRuby.configure { |c| c.custom_stop_words = ["specific", "domain", "terms"] }`

### Refine
- [ ] Remove unused `SentenceSplitter` class or integrate it into tokenizer
- [ ] Stop word loading should raise error if language file explicitly requested but missing

### Test
- [ ] Cross-algorithm comparison (same text, different algorithms)
- [ ] Multi-language extraction
- [ ] Batch performance benchmarks
- [ ] Memory usage for large corpora (TF-IDF)

---

## v0.3.0 — sastrawi-ruby Integration & Hybrid Search

### Integrate: sastrawi-ruby
- [ ] **Stemmed keyword extraction** — Apply Indonesian stemming before RAKE/YAKE for better grouping
- [ ] `extract(text, language: :id, stemmer: :sastrawi)` option

### Integrate: rag-ruby
- [ ] **BM25 hybrid search** — Provide keywords for BM25 scoring alongside vector similarity
- [ ] **Auto-tagging** — Extract keywords during document ingestion for metadata enrichment
- [ ] `RagRuby::Pipeline.configure { |c| c.keyword_extractor = KeywordRuby::Extractors::Rake.new }`

### Integrate: eval-ruby
- [ ] **Keyword overlap metric** — Lightweight relevance metric: `keyword_overlap(expected, actual)`
- [ ] Compare generated answer keywords vs reference answer keywords

### Integrate: guardrails-ruby
- [ ] **Topic detection** — Extract keywords → match against blocked topic lists
- [ ] `GuardrailsRuby::Checks::TopicCheck.new(blocked_topics: ["weapons", "drugs"])`

### Add
- [ ] **Keyphrase expansion** — Expand single keywords to meaningful phrases using context window
- [ ] **Keyword importance over time** — Track keyword frequency across document collections

---

## v0.4.0 — Advanced Features

### Add
- [ ] **POS-based filtering** — Only extract nouns/noun phrases (requires POS tagger integration)
- [ ] **Named entity keywords** — Combine with ner-ruby to boost entity keywords
- [ ] **Corpus management** — Persistent TF-IDF corpus with add/remove/update documents
- [ ] **Export formats** — `to_json`, `to_csv`, `to_word_cloud` for visualization

### Refine
- [ ] Algorithm benchmarks against standard datasets (SemEval, Inspec, Krapivin)
- [ ] Memory-efficient processing for documents >1MB
- [ ] Thread-safe extractors

---

## v1.0.0 — Production Ready

- [ ] API stability guarantee
- [ ] Comprehensive documentation with algorithm explanations
- [ ] Performance benchmarks (keywords/sec for each algorithm)
- [ ] Accuracy benchmarks against standard datasets
