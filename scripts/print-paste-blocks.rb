#!/usr/bin/env ruby
# Rebuild paste-ready Giscus tribute blocks from _data/messages.yml.
#
# Reads the enriched YAML archive, sorts entries by date (ties preserve
# YAML declaration order), and prints one paste block per entry to
# stdout. Each block matches the attribution format used when seeding
# the /tributes/ GitHub Discussion (see docs/github-runbook.md § 5).
#
# WHY RUBY: no new dependency — Ruby is already required by the Jekyll
# dev shell (see flake.nix), and both `yaml` and `date` are stdlib.
# Alternative choices (Python, Node, Bash+yq) would each pull in a new
# runtime for a ~90-line script.
#
# USAGE:
#   ./scripts/print-paste-blocks.rb                    # print to stdout
#   ./scripts/print-paste-blocks.rb > /tmp/blocks.md   # regen paste file
#   ./scripts/print-paste-blocks.rb | xclip -selection clipboard
#
# Idempotent — pure read of YAML, pure stdout output. Safe to re-run.

require 'yaml'
require 'date'

DATA_FILE = File.expand_path('../_data/messages.yml', __dir__)

unless File.exist?(DATA_FILE)
  warn "no data file at #{DATA_FILE}"
  exit 1
end

messages = YAML.load_file(DATA_FILE)

unless messages.is_a?(Array) && !messages.empty?
  warn "#{DATA_FILE} did not parse to a non-empty array"
  exit 1
end

# Sort by parsed date; same-date ties preserve YAML declaration order.
# Explicit stability: `sort_by` key is [Date, original_index], so ties
# don't rely on Ruby's implementation-defined sort stability.
sorted = messages.each_with_index
                 .sort_by { |m, i| [Date.parse(m.fetch('date')), i] }
                 .map(&:first)

total           = sorted.size
defaulted_count = sorted.count { |m| m['date_defaulted'] }
ai_count        = sorted.count { |m| m['translation_ai_generated'] }

# ---- helpers ---------------------------------------------------------------

def attribution_header(m)
  meta = [m['relation'], m['location']].compact.join(', ')
  line = "**#{m['name']}"
  line += " — #{meta}" unless meta.empty?
  line += " · #{m['date']}" if m['date']
  line + '**'
end

def quote_translation(text)
  # Prefix each line with "> "; blank lines become bare ">".
  text.to_s.rstrip.split("\n", -1).map { |ln| ln.empty? ? '>' : "> #{ln}" }
end

# ---- output ---------------------------------------------------------------

puts '# Paste-ready tribute blocks'
puts
puts "Generated from _data/messages.yml — #{defaulted_count} defaulted"
puts "dates, #{ai_count} AI-generated translations. See the YAML header"
puts 'for the Translation Review Notes.'
puts
puts 'Each block below is inside a fenced code block for clean copy-paste.'
puts 'Copy the content INSIDE the fence into the Giscus composer at'
puts '/tributes/, click Comment, move on.'
puts
puts '---'
puts

sorted.each_with_index do |m, idx|
  n = idx + 1
  puts "## #{n} / #{total} — #{m['name']}"
  puts
  puts '````markdown'
  puts attribution_header(m)
  puts
  puts m['body'].to_s.rstrip

  if m['translation']
    puts
    label = m['translation_partial'] ? '**English translation** (partial):' : '**English translation:**'
    puts "> #{label}"
    puts '>'
    quote_translation(m['translation']).each { |line| puts line }
  end

  puts '````'
  unless idx == total - 1
    puts
    puts '---'
    puts
  end
end
