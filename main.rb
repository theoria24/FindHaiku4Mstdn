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
    if toot.kind_of?(Mastodon::Status) then
      content = Sanitize.clean(toot.content)
      p "@#{toot.account.acct}: #{content}" if debug
      haiku = reviewer.find(content)
      if haiku then
        postcontent = "@#{toot.account.acct} 俳句を発見しました！\n『#{haiku.phrases[0].join("")} #{haiku.phrases[1].join("")} #{haiku.phrases[2].join("")}』"
        p "俳句検知: #{postcontent}" if debug
        p "BT? #{toot.reblogged?}"
        if toot.in_reply_to_id.nil? && !(toot.reblogged?) then
          if toot.visibility == "public" || toot.visibility == "unlisted" then
            # rest.create_status(text, in_reply_to_id, media_ids, visibility)
            rest.create_status(postcontent, toot.id)
            p "post!" if debug
          elsif debug
            p "private toot"
          end
        elsif debug
          p "BT or reply"
        end
      elsif debug
        p "俳句なし"
      end
    elsif toot.kind_of?(Mastodon::Notification) then
      p "Notification!" if debug
      p "type: #{toot.type} by #{toot.account.id}" if debug
      rest.follow(toot.account.id) if toot.type == "follow"
    end
  end
rescue => e
  p "error"
  puts e
  retry
end
