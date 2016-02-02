require_relative 'app_spec.rb'

describe ClientSocket do
  include Rack::Test::Methods

  it "raise ArgumentError if illegal argument specified" do
    expect { ClientSocket.new }.to raise_error(ArgumentError)
    expect { ClientSocket.new(:name => nil, :socket => nil) }.to raise_error(ArgumentError)
    expect { ClientSocket.new(:name => "name", :socket => "bad") }.to raise_error(ArgumentError)
  end

  it "is initialized with name and socket and optional group" do
    conn = EventMachine::WebSocket::Connection.new(nil, {})
    socket = ClientSocket.new(:name => "name", :socket => conn)
    expect(socket.name).to eq("name")
    expect(socket.group).to eq([])
    expect(socket.socket).to eq(conn)
    socket = ClientSocket.new(:name => "name", :group => ["group"], :socket => conn)
    expect(socket.name).to eq("name")
    expect(socket.group).to eq(["group"])
    expect(socket.socket).to eq(conn)
  end
end

describe "/" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response OK" do
    get '/'
    expect(last_response.ok?).to eq(true)
  end
end

describe "/controller" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response OK" do
    get '/controller'
    expect(last_response.ok?).to eq(true)
  end
end

describe "/socket" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response NG" do
    get '/socket'
    expect(last_response.status).to eq(503)
    # TODO how to check websocket
  end
end

describe "/controller_socket" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "response NG" do
    get '/controller_socket'
    expect(last_response.status).to eq(503)
    # TODO how to check websocket
  end
end
