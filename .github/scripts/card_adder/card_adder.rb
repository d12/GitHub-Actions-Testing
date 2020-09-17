require "slop"

opts = Slop.parse do |o|
  o.string "--label_name", "The name of the label used to add issue to project board"
  o.string "--action", "The label action taken. One of 'labeled' or 'unlabeled'"
end

puts opts.to_h
