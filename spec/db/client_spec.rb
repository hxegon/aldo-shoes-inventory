# # client_spec.rb
# # require_relative '../../lib/db/client'

# require 'db/client'

# module DB
#   CONFIG = {
#     host: 'localhost',
#     port: 3322,
#     username: 'immudbtestuser',
#     password: 'immudbtestpassword',
#     database: 'immudbtestdb'
#   }
# end

# describe DB::Client do
#   before do
#     # Setup a few transactions, record ids for teardown later
#     # Seeing as how this is an immutable DB, maybe better to
#     # add and destroy a new table
#     @client = DB::Client.new(
#       {
#         host: 'localhost',
#         port: 3322,
#         username: immudb,
#         password: ENV,
#         database: nil,
#         timeout: nil
#       }
#     )
#   end

#   describe '#set_inventory' do
#   end

#   describe '#history' do
#   end

#   describe '#find_inventory' do
#   end

#   describe '#set_inventory' do
#   end
# end
