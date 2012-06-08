if Rails.env.production?
  APNS.host = 'gateway.push.apple.com' 
  APNS.pem  = 'push_chataffair_prod.pem'
else
  # gateway.sandbox.push.apple.com is default  
  APNS.pem  = 'push_chataffair_dev.pem'
end


# APNS.port = 2195
# this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.