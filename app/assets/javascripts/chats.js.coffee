# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  class window.ChatClient
    constructor: (@options) ->
      #Create a new client to connect to Faye
      @client = new Faye.Client('http://localhost:9292/faye')
      @username = @options.username

    publish_private: (room, message) ->
      console.log('publish private', room, message)
      @client.publish('/messages/private/' + room, { username: @username, msg: message })

    publish_public: (message) ->
      console.log('publish public', message)
      #It's a public message
      @client.publish('/messages/public', { username: @username, msg: message})

    handle_send: ->
      #Handle form submissions and post messages to faye
      $('#new_message_form').submit () =>
        console.log('submit ->')

        #Is it a private message?
        if (matches = $('#message').val().match(/@(\w+)\s(.+)/))
          console.log('Private -> ', matches[1],'|', matches[2])
          @publish_private(matches[1], matches[2])
        else
          console.log('publish_public')
          #Publish the message to the public channel
          @publish_public($('#message').val())

        #Clear the message box
        $('#message').val('')

        #Don't actually submit the form, otherwise the page will refresh.
        return false
    subscribe_public: ->
      #Subscribe to the public channel
      public_subscription = @client.subscribe '/messages/public', (data) ->
        console.log('Public', data)
        $('<p></p>').html(data.username + ": " + data.msg).appendTo('#chat_room')
    subscribe_private: ->
      my_private_channel = '/messages/private/' + @username
      console.log(my_private_channel)

      #Our own private channel
      private_subscription = @client.subscribe my_private_channel, (data) ->
        console.log('Private', data)
        $('<p></p>').addClass('private').html(data.username + ": " + data.msg).appendTo('#chat_room')
