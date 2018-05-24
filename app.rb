require_relative 'modules.rb'

class App < Sinatra::Base
	include Account
	include Social
	include Add
	include Messages
	include Group

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
			begin
				Account::register(username, password_digest)
			rescue
				session[:error] = "Username has already been used"
				session[:back] = "/register"
				redirect('/error')
			end
			redirect('/')
		else
			session[:error] = "Passwords not the same"
			session[:back] = "/register"
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
		begin 
			a = Account::login(username)
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
		session[:user2] = ""
		if session[:user] == true
			result = Social::friends_groups(user1)
			friends = result[0]
			groups = result[1]
			erb(:website, locals:{a: friends, groups: groups})
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
		temp = Social::user2(user2)
		if temp == []
			session[:error] = "User does not exist"
			session[:back] = "/website"
			redirect('/error')
		end
		friends = Social::friends(user1)
		friends.each do |friend|
			if friend[0] == user2
				session[:error] = "Already friends"
				session[:back] = "/website"
				redirect('/error')
			end
		end
		Add::both(user1, user2)
		redirect('/website')
	end

	post('/message') do
		user1 = session[:username]
		user2 = params[:friend]
		session[:user2] = user2
		message = params[:message]
		if message == ""
			redirect('/chat')
		end
		Messages::send(message, user1, user2)
		redirect('/chat')
	end

	post('/group_message') do
		user1 = session[:username]
		group = params[:group]
		session[:user2] = group
		session[:group] = group
		message = params[:message]
		if message == ""
			redirect('/group_chat')
		end
		Messages::send(message, user1, group)
		redirect('/group_chat')
	end

	get('/chat') do
		user1 = session[:username]
		user2 = params[:friend]
		if session[:user] == true
			if user2 == "" or user2 == nil
				user2 = session[:user2]
			end
			friends = Social::friends(user1)
			session[:user2] = user2
			erb(:chat, locals:{a: friends, name: user2})
		else
			session[:error] = "Not logged in"
			session[:back] = "/login"
			redirect('/error')
		end
	end  

	get('/group_chat') do
		user1 = session[:username]
		session[:user2] = ""
		group = params[:group]
		if session[:user] == true
			if group == "" or group == nil
				group = session[:group]
			end
			friends = Social::friends(user1)
			session[:group] = group
			erb(:group_chat, locals:{a: friends, name: group})
		else
			session[:error] = "Not logged in"
			session[:back] = "/login"
			redirect('/error')
		end
	end 
	
	get('/messages') do
		user1 = session[:username]
		user2 = session[:user2]
		yes = false
		if user2 == "" or user2 == nil
			user2 = session[:group]
			yes = true
		end
		user1_messages = Messages::user1(user1, user2)
		if yes == true
			user2_messages = Messages::user2_1(user1, user2)
		else
			user2_messages = Messages::user2_2(user1, user2)
		end
		result = Messages::escape_messages(user1_messages, user2_messages)
		user1_messages = result[0]
		user2_messages = result[1]
		erb(:messages, layout:false, locals:{name: user2, temp1: user1_messages, temp2: user2_messages, user1_messages: user1_messages, user2_messages: user2_messages })
	end 

	post('/create_group') do
		user = session[:username]
		group = params[:name] + " (group)"
		error = Group::create(user, group)
		if error == true
			session[:error] = "Group already exist"
			session[:back] = "/website"
			redirect('/error')
		end
		redirect('/website')
	end

	post('/add_to_group') do
		friend = params[:friend]
		group = session[:group]
		error = Group::add(friend, group)
		if error == true
			session[:error] = "User already in the group"
			session[:back] = "/group_chat"
			redirect('/error')
		end
		redirect('/group_chat')
	end       

end           
