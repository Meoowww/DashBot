require "CrystalIrc"

module DashBot::Plugins::Reminder
  extend self
  include Rights
  include Database

  def bind(bot)
    bind_write bot
    bind_check bot
    bind_read bot
    bind_signal bot
  end

  def wordToDate(txt)
    date = txt.split("/")
    time = Time.now()
    if date.size == 1
      date = txt.split("h")
      m = 0
      if date.size == 2 && date[1].size > 0
        m = date[1].to_i32
      end
      Time.new(time.year, time.month, time.day, date[0].to_i32, m, 0, 0, Time::Kind::Local).to_utc
    else
      y = time.year
      if date.size == 3 && date[2].size > 0
        y = date[2].to_i32
      end
      Time.new(y, date[1].to_i32, date[0].to_i32, 0, 0, 0, 0, Time::Kind::Local).to_utc
    end
  end

  def bind_write(bot)
    bot.on("PRIVMSG", message: /^!reminder ([[:graph:]]+) (.+)$/) do |msg, match|
      dest_time = wordToDate(match.as(Regex::MatchData)[1])
      message = match.as(Regex::MatchData)[2]
      DB.exec "INSERT INTO reminders (author, remind_time, content, created_at)
      VALUES ($1, $2, $3, NOW())", [msg.source_id, dest_time, message]
      msg.reply "Reminder set"
    end
  end

  def bind_read(bot)
    bot.on("PRIVMSG", message: /^!remindme$/) do |msg, match|
      messages = DB.query_all(
        "SELECT id, author, remind_time, content, created_at, checked_at, read_at FROM reminders WHERE read_at IS NULL AND author = $1",
          [msg.source_id], as: {Int32, String, Time, String, Time, Time?, Time?}) rescue nil
      if messages
        messages.each do |m|
          message = {id: m[0], author: m[1], remind_time: m[2], content: m[3], created_at: m[4], read_at: m[5]}
          if message[:remind_time] < Time.utc_now
            date = message[:remind_time].to_local
            if Time.now.to_s("%j") == date.to_s("%j")
              date = date.to_s("%H:%M:%S")
            else
              date = date.to_s("%B, %d at %H:%M:%S")
            end
            msg.reply "#{date} -- #{message[:content]}"
            DB.exec "UPDATE reminders SET read_at = NOW() WHERE id = $1", [message[:id]]
          end
        end
      end
    end
  end

  def bind_check(bot)
    bot.on("PING") do |msg|
      messages = DB.query_all(
        "SELECT id, author, remind_time, content, created_at, read_at FROM reminders WHERE checked_at IS NULL AND read_at IS NULL",
          as: {Int32, String, Time, String, Time, Time?}) rescue nil
      if messages
        messages.each do |m|
          message = {id: m[0], author: m[1], remind_time: m[2], content: m[3], created_at: m[4], read_at: m[5]}
          if message[:remind_time] < Time.utc_now
            # TODO: fix this so it finds the user's nickname and sends it to it instead
            bot.privmsg CrystalIrc::User.new(message[:author]), "You have a new reminder"
            DB.exec "UPDATE reminders SET checked_at = NOW() WHERE id = $1", [message[:id]]
            break
          end
        end
      end
    end
  end

  def bind_signal(bot)
    bot.on("JOIN") do |msg, _|
      count = DB.query_one("SELECT COUNT(*) FROM reminders WHERE read_at IS NULL and checked_at IS NOT NULL and author = $1", [msg.source_id], as: {Int64})
      msg.reply "#{msg.source_id}, you have #{count} reminders" if count > 0
    end
  end
end
