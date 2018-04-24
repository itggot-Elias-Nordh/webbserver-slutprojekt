class App < Sinatra::Base

	enable:sessions

	get('/error') do
		error = session[:error]
		back = session[:back]
		a = [error, back]
		erb(:error, locals:{a: a})
    end

	get('/') do	
	    session[:user] = false	
		erb(:index)
	end

	get('/register') do
		erb(:register)
	end

	post('/register') do
		username = params[:username]
		password = params[:password]
		if username == "" or password == ""
			session[:error] = "Username or password is not filled in"
			session[:back] = "/register"
			redirect('/error')
		end
		re_password = params[:re_password]
		if password == re_password
			password_digest = BCrypt::Password.create(password)
			db = SQLite3::Database.new("./db/copybook.sqlite")
			begin
				db.execute("INSERT INTO login (username, password) VALUES (?,?)", [username, password_digest])
			rescue
				session[:error] = "Username has already been used"
				session[:back] = "/register"
				redirect('/error')
			end
			redirect('/')
		else
			session[:error] = "Passwords not the same"
			redirect('/error')
		end
	end

	get('/login') do
		erb(:login)
	end

	post('/login') do
		session[:user] = false
		username = params[:username]
		password = params[:password]
		if username == "" or password == ""
			redirect('/website')
		end
		db = SQLite3::Database.new("./db/copybook.sqlite")
		begin 
			a = db.execute("SELECT * FROM login WHERE username IS (?)", [username])[0]
			password_digest = BCrypt::Password.new(a[2])
		rescue
			redirect('/website')
		end
		if a[1] == username && password_digest == password
			session[:user] = true
			session[:username] = username
		else
			session[:user] = false
		end
		redirect('/website')
	end

	get('/website') do
		user1 = session[:username]
		if session[:user] == true
			db = SQLite3::Database.new("./db/copybook.sqlite")
			friends = db.execute("SELECT user2 FROM friends WHERE user1 IS (?)", [user1])
			db.execute("SELECT * FROM friends WHERE user1 IS (?)", [user1])
			erb(:website, locals:{a: friends})
		else
			session[:error] = "Wrong username or password"
			session[:back] = "/login"
			redirect('/error')
		end
	end

	post('/add') do
		user1 = session[:username]
		user2 = params[:name]
		if user2 == ""
			session[:error] = "User can not be nil"
			session[:back] = "/website"
			redirect('/error')
		elsif user1 == user2
			session[:error] = "You can not add yourself"
			session[:back] = "/website"
			redirect('/error')
		end
		db = SQLite3::Database.new("./db/copybook.sqlite")
		if db.execute("SELECT * FROM login WHERE username IS (?)", [user2]) == []
			session[:error] = "User does not exist"
			session[:back] = "/website"
			redirect('/error')
		end
		friends = db.execute("SELECT user2 FROM friends WHERE user1 IS (?)", [user1])
		friends.each do |friend|
			if friend[0] == user2
				session[:error] = "Already friends"
				session[:back] = "/website"
				redirect('/error')
			end
		end
		db.execute("INSERT INTO friends (user1, user2) VALUES (?,?)", [user1, user2])
		db.execute("INSERT INTO friends (user2, user1) VALUES (?,?)", [user1, user2])
		redirect('/website')
	end

	post('/message') do
		p user1 = session[:username]
		p user2 = params[:friend]
		session[:user2] = user2
		message = params[:message]
		if message == ""
			redirect('/chat')
		end
		db = SQLite3::Database.new("./db/copybook.sqlite")
		db.execute("INSERT INTO messages (message, user1, user2) VALUES (?,?,?)", [message, user1, user2])
		redirect('/chat')
	end

	get('/chat') do
		user2 = ""
		user1 = session[:username]
		user2 = session[:user2]
		if session[:user] == true
			if user2 == "" or user2 == nil
				user2 = params[:friend]
			end
			db = SQLite3::Database.new("./db/copybook.sqlite")
			friends = db.execute("SELECT user2 FROM friends WHERE user1 IS (?)", [user1])
			user1_messages = db.execute("SELECT id, message FROM messages WHERE user1=? AND user2=?", [user1, user2])
			user2_messages = db.execute("SELECT id, message FROM messages WHERE user1=? AND user2=?", [user2, user1])
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
			p user1_messages
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
			db.execute("SELECT * FROM friends WHERE user1 IS (?)", [user1])
			session[:user2] = ""
			a = []
			a << friends
			erb(:chat, locals:{a: friends, name: user2, temp1: user1_messages, temp2: user2_messages, user1_messages: user1_messages, user2_messages: user2_messages })
		else
			session[:error] = "Not logged in"
			session[:back] = "/login"
			redirect('/error')
		end
	end        

end           
