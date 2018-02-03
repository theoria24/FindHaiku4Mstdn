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
      if toot.visibility == "public" || toot.visibility == "unlisted" then
        if toot.in_reply_to_id.nil? && toot.attributes["reblog"].nil? then
          content = Sanitize.clean(toot.content)
          p "@#{toot.account.acct}: #{content}" if debug
          haiku = reviewer.find(content)
          if haiku then
            postcontent = "『#{haiku.phrases[0].join("")} #{haiku.phrases[1].join("")} #{haiku.phrases[2].join("")}』"
            p "俳句検知: #{postcontent}" if debug
            if toot.attributes["tags"].map{|t| t["name"]}.include?("theboss_tech").include?("theboss_tech")
              vis = "public"
            else
              vis = "unlisted"
            end
            if toot.attributes["spoiler_text"].empty? then
              rest.create_status("@#{toot.account.acct} 俳句を発見しました！\n" + postcontent, toot.id, visibility: vis)
            else
              rest.create_status("@#{toot.account.acct}\n" + postcontent, in_reply_to_id: toot.id, spoiler_text: "俳句を発見しました！", visibility: vis)
            end
            p "post!" if debug
          elsif debug
            p "俳句なし"
          end
        elsif debug
          p "BT or reply"
        end
      elsif debug
        p "private toot"
      end
    elsif toot.kind_of?(Mastodon::Notification) then
      p "#{toot.type} by #{toot.account.id}" if debug
      rest.follow(toot.account.id) if toot.type == "follow"
    end
  end
rescue => e
  p "error"
  puts e
  retry
end
