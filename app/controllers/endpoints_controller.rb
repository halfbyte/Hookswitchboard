class EndpointsController < ApplicationController
  
  def endpoint
    # first, storing it all in a mongomapper doc
    post_body = request.post? ? request.body.read : nil
    
    params_without_std = params.select{|k,v| !['controller', 'action'].include?(k)}
    
    message = Incoming.create(:source => request.ip, :params => params_without_std, :post_body => post_body)
    
    message.process
    
    render :text => 'OK', :content_type => 'text/plain'
  end
  
end
