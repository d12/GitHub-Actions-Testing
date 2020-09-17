require "slop"

opts = Slop.parse do |o|
  o.string "--label_name", "The name of the label we're being notified about"
  o.string "--action", "The label action taken. One of 'labeled' or 'unlabeled'"
  o.string "--issue_title", "The title of the issue"
  o.string "--issue_url", "The URL of the issue"
  o.string "--issue_number", "The number of the issue"
end

puts opts.to_h
