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
		username = session[:username]
		if session[:user] == true
			user1 = session[:username]
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
		redirect('/website')
	end

	get('/chat') do
		username = session[:username]
		if session[:user] == true
			user1 = session[:username]
			db = SQLite3::Database.new("./db/copybook.sqlite")
			friends = db.execute("SELECT user2 FROM friends WHERE user1 IS (?)", [user1])
			db.execute("SELECT * FROM friends WHERE user1 IS (?)", [user1])
			a = []
			a << friends
			erb(:chat, locals:{a: friends})
		else
			session[:error] = "Not logged in"
			session[:back] = "/login"
			redirect('/error')
		end
	end

end           
