require 'rspec'
require_relative '../active_record'

describe ActiveRecord do
  describe '.columns' do
    before do
      class User < ActiveRecord
        columns :name, :age
      end
    end

    it 'creates a table in the database for the subclass with the correct table name and columns' do
      expect(ActiveRecord.connection).to receive(:create_table).with('users', %i[name age id])
      User.columns :name, :age
    end

    it 'defines the columns for the subclass, including the id column' do
      expect(User.instance_variable_get(:@column_names)).to eq(%i[name age id])
    end

    it 'defines getters and setters for the columns' do
      user = User.new
      user.name = 'Brayan'
      expect(user.name).to eq('Brayan')
    end
  end

  describe '.create' do
    before do
      class User < ActiveRecord
        columns :name, :age
      end
    end

    after { ActiveRecord.connection.data.clear }

    it 'creates a new record and returns it' do
      user = User.create(name: 'Jane', age: 25)
      expect(user.name).to eq('Jane')
      expect(user.age).to eq(25)
      expect(user.id).to_not be_nil
    end

    it 'inserts the record into the database' do
      user = User.create(name: 'Jane', age: 25)
      expect(ActiveRecord.connection.data['users'].last).to include(user.instance_variables_hash)
    end
  end
end
