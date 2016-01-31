#!/bin/env ruby

require 'sinatra'
require 'sinatra-websocket'
require 'json'
require 'securerandom'
require 'pp'


class ClientSocket
  def initialize(config={})
    raise ArgumentError unless config[:name].kind_of? String
    raise ArgumentError unless config[:socket].kind_of? EventMachine::WebSocket::Connection 
    @name = config[:name]
    @group = config[:group] || []
    @socket = config[:socket]
  end
  attr_accessor :name, :group, :socket
end

set :server, 'thin'
set :sockets, []
set :controller_socket, nil

get '/' do
  erb :index
end

get '/socket' do
  if request.websocket? then
    request.websocket do |ws|
      ws.onopen do
        name = SecureRandom.uuid
        settings.sockets << ClientSocket.new(:name => name, :socket => ws)
        EM.next_tick do
          if settings.controller_socket
            settings.controller_socket.send(JSON.generate({:type => 'connected', :name => name}))
            ws.send(JSON.generate({:type => 'connected', :name => name}))
          end
        end
      end
      ws.onmessage do |msg|
        logger.info "<- #{msg}"
        EM.next_tick do
          if settings.controller_socket
            settings.controller_socket.send(JSON.generate({:type => 'clientmsg', :value => msg}))
          end
        end
      end
      ws.onclose do
        socket = settings.sockets.find { |v| v.socket == ws }
        if socket
          settings.sockets.delete(socket)
          EM.next_tick do
            if settings.controller_socket
              settings.controller_socket.send(JSON.generate({:type => 'disconnected', :name => socket.name}))
            end
          end
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
          settings.sockets.each do |socket|
            socket.socket.send(msg)
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
