Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "tickets.rubyconf.africa", "localhost:3000", "d8a5-105-165-250-28.ngrok-free.app"
    resource "*", headers: :any, methods: [ :get, :post, :options ]
  end
end
