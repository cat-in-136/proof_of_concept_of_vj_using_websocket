#!/bin/env ruby

require 'sinatra'
require 'sinatra-websocket'
require 'pp'

set :server, 'thin'
set :sockets, []

get '/' do
  erb :index
end

get '/socket' do
  if request.websocket? then
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        pp msg
        EM.next_tick do
          settings.sockets.each do |s|
            s.send(msg)
          end
        end
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
end

