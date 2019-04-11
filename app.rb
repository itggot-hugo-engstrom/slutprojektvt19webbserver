require 'sinatra'
require 'slim'
require 'SQLite3'
require 'bcrypt'


get ('/') do
    slim(:index)
end

post('/login') do 
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true
    result = db.execute("SELECT id, password FROM tabell WHERE username = ?", params["username"])
    user = result.first
    hash_password = BCrypt::Password.new(user["password"])
    p hash_password

    if hash_password == params["password"]
        session[:username] = params["username"]
        session[:userId] = user["id"]
        redirect('/logged')
    else
        redirect('/oops')
    end
end

post('/register') do
    db = SQLite3::Database.new("db/blogg.db")
    hash_password = BCrypt::Password.create(params[:password])
    db.execute('INSERT INTO tabell(username, email, password) VALUES ((?), (?), (?))', params[:username], params[:email], hash_password)
    redirect('/')
end

get ('/oops') do
    slim(:oops)
end

get ('/register') do
    slim(:register)
end

