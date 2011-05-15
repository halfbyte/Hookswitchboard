class IncomingMessagesController < ApplicationController
  def index
    @messages = Incoming.sort(:created_at.desc)
  end

end
