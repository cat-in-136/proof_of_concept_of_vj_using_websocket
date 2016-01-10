#!/bin/env ruby

require 'sinatra'
require 'sinatra-websocket'
require 'pp'

set :server, 'thin'
set :sockets, []
set :controller_sockets, []

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
        logger.info "<- #{msg}"
        EM.next_tick do
          settings.controller_sockets.each do |s|
            s.send(msg)
          end
        end
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  else
    status 503
  end
end

get '/controller' do
  erb :controller
end

get '/controller_socket' do
  if request.websocket? then
    request.websocket do |ws|
      ws.onopen do
        settings.controller_sockets << ws
      end
      ws.onmessage do |msg|
        logger.info "-> #{msg}"
        EM.next_tick do
          settings.sockets.each do |s|
            s.send(msg)
          end
        end
      end
      ws.onclose do
        settings.controller_sockets.delete(ws)
      end
    end
  else
    status 503
  end
end


