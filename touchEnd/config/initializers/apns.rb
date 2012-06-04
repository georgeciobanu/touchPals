if Rails.env.production?
#  APNS.host = 'gateway.push.apple.com' 
  APNS.pem  = 'push_chataffair_prod.pem'
  # gateway.sandbox.push.apple.com is default
else
  APNS.pem  = 'push_chataffair_dev.pem'
end
# this is the file you just created

# APNS.port = 2195
# this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.
