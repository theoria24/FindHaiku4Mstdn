require 'bundler/setup'
require 'yaml'
require 'mastodon'
require 'ikku'
require 'sanitize'

config = YAML.load_file("./key.yml")
debug = true

stream = Mastodon::Streaming::Client.new(
  base_url: "https://" + config["base_url"],
  bearer_token: config["access_token"])

rest = Mastodon::REST::Client.new(
  base_url: "https://" + config["base_url"],
  bearer_token: config["access_token"])

reviewer = Ikku::Reviewer.new

begin
  stream.user() do |toot|
    next if !toot.kind_of?(Mastodon::Status)
    content = Sanitize.clean(toot.content)
    p "@#{toot.account.acct}: #{content}" if debug
    haiku = reviewer.find(content)
    if haiku then
      postcontent = "@#{toot.account.acct} 俳句を発見しました！\n#{haiku.phrases[0].join("")} #{haiku.phrases[1].join("")} #{haiku.phrases[2].join("")}"
      p postcontent if debug
      # rest.create_status(text, in_reply_to_id, media_ids, visibility)
      rest.create_status(postcontent, toot.id, "", "unlisted") if toot.in_reply_to_id.nil? && !toot.reblogged?
    elsif debug
      p "not haiku"
    end
  end
rescue => e
  p "error"
  puts e
  retry
end
