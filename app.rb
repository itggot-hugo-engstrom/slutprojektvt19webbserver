require 'sinatra'
require 'slim'
require 'SQLite3'
require 'bcrypt'
require 'byebug'

enable :sessions

get ('/') do
    slim(:index)
end

post('/login') do 
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true
    result = db.execute("SELECT id, password FROM tabell WHERE username = ?", params["username"])
    user = result.first
    hash_password = BCrypt::Password.new(user["password"])
    p hash_password
    password_check = db.execute('SELECT password FROM tabell WHERE email = ?', params[:email])
    if password_check.any? == false
        session[:username] = params[:username]
        session[:userId] = user["id"]
        redirect('/logged')
    else
        redirect('/oops')
    end
end

post('/logout') do
    session.destroy
    redirect('/')
end

post('/register') do
    # byebug()
    db = SQLite3::Database.new("db/users.db")
    hash_password = BCrypt::Password.create(params[:password])

    user_already_exists = db.execute('SELECT email FROM tabell where email = ?', params[:email])
    if user_already_exists.any?
        redirect('/oops')
    else
        db.execute('INSERT INTO tabell(username, password, email) VALUES (?, ?, ?)', params[:username], hash_password, params[:email])
        redirect('/')
    end
end

get ('/oops') do
    slim(:oops)
end

get ('/logged') do
    slim(:logged)
end

get ('/register') do
    slim(:register)
end

