module Account
    def self.register(username, password_digest)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        db.execute("INSERT INTO login (username, password) VALUES (?,?)", [username, password_digest])
    end

    def self.login(username)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        a = db.execute("SELECT * FROM login WHERE username IS (?)", [username])[0]
        return a
    end
end

module Social
    def self.friends(user1)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        friends = db.execute("SELECT user2 FROM friends WHERE user1 IS (?)", [user1])
        return friends
    end

    def self.friends_groups(user1)
        db = SQLite3::Database.new("./db/copybook.sqlite")
		friends = db.execute("SELECT user2 FROM friends WHERE user1 IS (?)", [user1])
        groups = db.execute("SELECT group_name FROM groups WHERE user_name IS (?)", [user1])
        return [friends, groups]
    end

    def self.user2(user2)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        temp = db.execute("SELECT * FROM login WHERE username IS (?)", [user2])
        return temp
    end
end

module Add
    def self.both(user1, user2)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        db.execute("INSERT INTO friends (user1, user2) VALUES (?,?)", [user1, user2])
		db.execute("INSERT INTO friends (user2, user1) VALUES (?,?)", [user1, user2])
    end
end

module Messages
    def self.send(message, user1, user2)
        db = SQLite3::Database.new("./db/copybook.sqlite")
		db.execute("INSERT INTO messages (message, user1, user2) VALUES (?,?,?)", [message, user1, user2])
    end

    def self.user1(user1, user2)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        user1_messages = db.execute("SELECT id, message FROM messages WHERE user1=? AND user2=?", [user1, user2])
        return user1_messages
    end

    def self.user2_1(user1, user2)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        user2_messages = db.execute("SELECT * FROM messages WHERE user2=? AND user1!=?", [user2, user1])
        return user2_messages
    end

    def self.user2_2(user1, user2)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        user2_messages = db.execute("SELECT * FROM messages WHERE user1=? AND user2=?", [user2, user1])
        return user2_messages
    end

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

module Group
    def create(user, group)
        db = SQLite3::Database.new("./db/copybook.sqlite")
        begin
            if group == db.execute("SELECT * FROM groups WHERE group_name IS (?)", [group])[0][0]
                return true
            else
                db.execute("INSERT INTO groups (group_name, user_name) VALUES (?,?)", [group, user])
            end
        rescue
            db.execute("INSERT INTO groups (group_name, user_name) VALUES (?,?)", [group, user])
        end
        return false
    end

    def add(friend, group)
        db = SQLite3::Database.new("./db/copybook.sqlite")
		begin
			if friend != db.execute("SELECT user_name FROM groups WHERE group_name=? AND user_name=?", [group, friend])[0][0]
				db.execute("INSERT INTO groups (group_name, user_name) VALUES (?,?)", [group, friend])
			else
				return true
			end
		rescue
			db.execute("INSERT INTO groups (group_name, user_name) VALUES (?,?)", [group, friend])
		end
        return false
    end
end