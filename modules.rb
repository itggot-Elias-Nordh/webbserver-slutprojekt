module Messages
    def self.escape_messages(user1_messages, user2_messages)
        i1 = 0
        user1_messages.each do |message|
            chars = message[1].to_s.chars
            i2 = 0
            chars.each do |char|
                if char == "<"
                    chars[i2] = "&lt;"
                elsif char == ">"
                    chars[i2] = "&gt;"
                end
                i2 += 1
            end
            user1_messages[i1][1] = chars.join
            i1 += 1
        end
        i1 = 0
        user2_messages.each do |message|
            chars = message[1].to_s.chars
            i2 = 0
            chars.each do |char|
                if char == "<"
                    chars[i2] = "&lt;"
                elsif char == ">"
                    chars[i2] = "&gt;"
                end
                i2 += 1
            end
            user2_messages[i1][1] = chars.join
            i1 += 1
        end
        return [user1_messages, user2_messages]
    end
end