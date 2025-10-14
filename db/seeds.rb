# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create super admin
unless Admin.exists?(email: "admin@example.com")
  Admin.create!(
    email: "admin@example.com",
    name: "Super Admin",
    password: "password123",
    password_confirmation: "password123"
  )
  puts "Created super admin: admin@example.com / password123"
end

# Load compliance areas
require_relative "seeds/compliance_areas"

# Load master questionnaire
require_relative "seeds/master_questionnaire"

puts "Seeds completed successfully!"
