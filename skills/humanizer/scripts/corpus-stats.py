#!/usr/bin/env python3
"""
corpus-stats.py
Computes writing-style statistics from a directory of plain-text/markdown letter
files. Generic and standard-library-only — no personal data or per-user numbers
are hardcoded here; every number below is computed fresh from whatever archive
is passed in.

Usage: python corpus-stats.py <directory> [--ext .md,.txt]

Metrics (see README-level explanation in each function):
- sentence length distribution (min/max/mean word count)
- subject-first opener rate (heuristic — see is_subject_first_opener)
- contraction rate per 100 words
- digit/numeral density
- Flesch-Kincaid reading grade
- type-token ratio (lexical diversity)

Output is a single JSON object printed to stdout so any caller (humanizer,
gatekeeper, letter-writer) can parse it without a custom format.
"""
import glob
import json
import os
import re
import sys

SENTENCE_SPLIT_RE = re.compile(r"(?<=[.!?])\s+(?=[A-Z\"'])")
WORD_RE = re.compile(r"[A-Za-z']+")
CONTRACTION_RE = re.compile(r"\b\w+'(t|s|re|ve|ll|d|m)\b", re.IGNORECASE)
NUMERAL_TOKEN_RE = re.compile(r"\b\w*\d\w*\b")
EXPLETIVE_RE = re.compile(r"^(there|it)\s+(is|are|was|were)\b", re.IGNORECASE)
PRONOUN_SUBJECT_RE = re.compile(r"^(i|we|you|he|she|they)\b", re.IGNORECASE)

VOWEL_GROUPS_RE = re.compile(r"[aeiouy]+")


def read_corpus(directory, extensions):
    texts = []
    for ext in extensions:
        for path in sorted(glob.glob(os.path.join(directory, f"*{ext}"))):
            with open(path, "r", encoding="utf-8") as f:
                texts.append(f.read())
    return texts


def split_sentences(text):
    # Collapse markdown line breaks into spaces so sentences aren't cut mid-paragraph.
    flat = re.sub(r"\s+", " ", text).strip()
    if not flat:
        return []
    return [s.strip() for s in SENTENCE_SPLIT_RE.split(flat) if s.strip()]


def words_in(text):
    return WORD_RE.findall(text)


def count_syllables(word):
    groups = VOWEL_GROUPS_RE.findall(word.lower())
    count = len(groups)
    if word.lower().endswith("e") and count > 1:
        count -= 1
    return max(count, 1)


def is_subject_first_opener(sentence):
    """Heuristic: a sentence opens on its subject unless it starts with an
    expletive construction ('There is/are', 'It is/was') or a gerund phrase
    ('Building X...'). This is an approximation, not a grammar parser — good
    enough to track a trend across a corpus, not to grade a single sentence."""
    stripped = sentence.strip()
    if EXPLETIVE_RE.match(stripped):
        return False
    first_word_match = re.match(r"[A-Za-z']+", stripped)
    if not first_word_match:
        return False
    first_word = first_word_match.group(0)
    if first_word.lower().endswith("ing"):
        return False
    return True


def sentence_length_stats(all_sentences):
    lengths = [len(words_in(s)) for s in all_sentences if words_in(s)]
    if not lengths:
        return {"min": 0, "max": 0, "mean": 0}
    return {
        "min": min(lengths),
        "max": max(lengths),
        "mean": round(sum(lengths) / len(lengths), 2),
    }


def subject_first_rate(all_sentences):
    if not all_sentences:
        return 0.0
    hits = sum(1 for s in all_sentences if is_subject_first_opener(s))
    return round(100 * hits / len(all_sentences), 1)


def contraction_rate_per_100_words(all_words, full_text):
    total_words = len(all_words)
    if total_words == 0:
        return 0.0
    hits = len(CONTRACTION_RE.findall(full_text))
    return round(100 * hits / total_words, 2)


def numeral_density(all_words):
    total_words = len(all_words)
    if total_words == 0:
        return 0.0
    hits = sum(1 for w in all_words if any(c.isdigit() for c in w))
    return round(100 * hits / total_words, 2)


def flesch_kincaid_grade(all_sentences, all_words):
    num_sentences = len(all_sentences)
    num_words = len(all_words)
    if num_sentences == 0 or num_words == 0:
        return 0.0
    num_syllables = sum(count_syllables(w) for w in all_words)
    grade = (
        0.39 * (num_words / num_sentences)
        + 11.8 * (num_syllables / num_words)
        - 15.59
    )
    return round(grade, 1)


def type_token_ratio(all_words):
    if not all_words:
        return 0.0
    lowered = [w.lower() for w in all_words]
    return round(len(set(lowered)) / len(lowered), 3)


def compute_stats(texts):
    all_sentences = []
    all_words = []
    full_text_parts = []
    for text in texts:
        sentences = split_sentences(text)
        all_sentences.extend(sentences)
        all_words.extend(words_in(text))
        full_text_parts.append(text)
    full_text = "\n".join(full_text_parts)

    return {
        "letters_analyzed": len(texts),
        "sentence_count": len(all_sentences),
        "word_count": len(all_words),
        "sentence_length": sentence_length_stats(all_sentences),
        "subject_first_opener_pct": subject_first_rate(all_sentences),
        "contraction_rate_per_100_words": contraction_rate_per_100_words(all_words, full_text),
        "numeral_density_pct": numeral_density(all_words),
        "flesch_kincaid_grade": flesch_kincaid_grade(all_sentences, all_words),
        "type_token_ratio": type_token_ratio(all_words),
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: python corpus-stats.py <directory> [--ext .md,.txt]")
        sys.exit(1)

    directory = sys.argv[1]
    extensions = [".md", ".txt"]
    for arg in sys.argv[2:]:
        if arg.startswith("--ext"):
            _, _, value = arg.partition("=")
            if value:
                extensions = [e if e.startswith(".") else f".{e}" for e in value.split(",")]

    if not os.path.isdir(directory):
        print(f"Not a directory: {directory}", file=sys.stderr)
        sys.exit(1)

    texts = read_corpus(directory, extensions)
    if not texts:
        print(f"No files found in {directory} with extensions {extensions}", file=sys.stderr)
        sys.exit(1)

    print(json.dumps(compute_stats(texts), indent=2))


if __name__ == "__main__":
    main()
