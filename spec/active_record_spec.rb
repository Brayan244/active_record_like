require 'rspec'
require_relative '../active_record'

describe ActiveRecord do
  before do
    class User < ActiveRecord
      columns :name, :age
    end
  end

  describe '.columns' do
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

  describe '.find' do
    after { ActiveRecord.connection.data.clear }

    it 'returns the record with the given id' do
      user = User.create(name: 'Jane', age: 25)

      finded_user = User.find(user.id)

      expect(finded_user.id).to eq(user.id)
      expect(finded_user.name).to eq(user.name)
      expect(finded_user.age).to eq(user.age)
    end

    it 'returns nil if no record is found' do
      expect(User.find(1)).to be_nil
    end
  end

  describe '#update' do
    let(:user) { User.create(name: 'Jane', age: 25) }

    after { ActiveRecord.connection.data.clear }

    it 'updates the record in the database' do
      user.update(name: 'Brayan', age: 30)

      updated_user = User.find(user.id)

      expect(updated_user.name).to eq('Brayan')
      expect(updated_user.age).to eq(30)
    end
  end
end
