#!/bin/env ruby

require 'sinatra'
require 'sinatra-websocket'
require 'json'
require 'securerandom'
require 'pp'

set :server, 'thin'
set :sockets, {}
set :controller_socket, nil

get '/' do
  erb :index
end

get '/socket' do
  if request.websocket? then
    request.websocket do |ws|
      ws.onopen do
        name = SecureRandom.uuid
        settings.sockets[name] = ws
        EM.next_tick do
          settings.controller_socket.send(JSON.generate({:type => 'connected', :name => name}))
          ws.send(JSON.generate({:type => 'connected', :name => name}))
        end
      end
      ws.onmessage do |msg|
        logger.info "<- #{msg}"
        EM.next_tick do
          settings.controller_socket.send(JSON.generate({:type => 'clientmsg', :value => msg}))
        end
      end
      ws.onclose do
        name = settings.sockets.rassoc(ws).first
        settings.sockets.delete(name)
        EM.next_tick do
          settings.controller_sockets.send(JSON.generate({:type => 'disconnected', :name => name}))
        end
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
        unless settings.controller_socket.nil?
          ws_old = settings.controller_socket
          EM.next_tick do
            ws_old.close_connection
          end
        end
        settings.controller_socket = ws
      end
      ws.onmessage do |msg|
        logger.info "-> #{msg}"
        EM.next_tick do
          settings.sockets.each do |name,s|
            s.send(msg)
          end
        end
      end
      ws.onclose do
        if settings.controller_socket == ws
          settings.controller_socket = nil
        end
      end
    end
  else
    status 503
  end
end


