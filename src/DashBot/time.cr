struct Time
  def self.adaptive_parse(txt)
    t = Time.now
    parsing_formats = {
      "%R %-d/%m/%Y" => " #{t.day}/#{t.month}/#{t.year}",
      "%T %-d/%m/%Y" => " #{t.day}/#{t.month}/#{t.year}",
      "%Hh%M %-d/%m/%Y" => " #{t.day}/#{t.month}/#{t.year}",
      "%kh%M %-d/%m/%Y" => " #{t.day}/#{t.month}/#{t.year}",
      "%k:%M %-d/%m/%Y" => " #{t.day}/#{t.month}/#{t.year}",
      "%Hh %-d/%m/%Y" => " #{t.day}/#{t.month}/#{t.year}",
      "%kh %-d/%m/%Y" => " #{t.day}/#{t.month}/#{t.year}",
      "%d/%m %Y" => " #{t.year}",
      "%-d/%m %Y" => " #{t.year}",
      "%d/%m/%Y" => "",
      "%-d/%m/%Y" => "",
      "%D" => "",
    }

    parsing_formats.each do |f, v|
      begin
        return Format.new(f, Time::Kind::Local).parse(txt + v).to_utc
      rescue
      end
    end
  end
end
