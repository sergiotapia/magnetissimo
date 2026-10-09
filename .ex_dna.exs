# Duplication policy checked by `mix ex_dna` (part of `mix precommit`). Any
# clone fails the build. Beyond exact copies, it matches clones that differ
# only in names or literals, and near-misses at 85% similarity.
%{
  paths: ["lib/", "test/"],
  literal_mode: :abstract,
  min_similarity: 0.85,
  normalize_pipes: true
}
