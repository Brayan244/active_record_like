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

  describe '.first' do
    after { ActiveRecord.connection.data.clear }

    it 'returns the first record' do
      user = User.create(name: 'Jane', age: 25)
      User.create(name: 'Brayan', age: 26)

      first_user = User.first

      expect(first_user.id).to eq(user.id)
      expect(first_user.name).to eq(user.name)
      expect(first_user.age).to eq(user.age)
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

  describe '#destroy' do
    let(:user) { User.create(name: 'Jane', age: 25) }

    after { ActiveRecord.connection.data.clear }

    it 'deletes the record from the database' do
      user.destroy

      expect(User.find(user.id)).to be_nil
    end
  end

  describe '#save' do
    let(:user) { User.create(name: 'Jane', age: 25) }

    after { ActiveRecord.connection.data.clear }

    it 'updates the record in the database' do
      user.name = 'Brayan'
      user.age = 30
      user.save

      updated_user = User.find(user.id)

      expect(updated_user.name).to eq('Brayan')
      expect(updated_user.age).to eq(30)
    end

    it 'creates a new record if the record does not exist in the database' do
      new_user = User.new(name: 'Brayan', age: 26)
      new_user.save

      expect(new_user.id).to_not be_nil
    end

    it 'returns true if the record was saved' do
      expect(user.save).to be true
    end
  end

  describe '#new_record?' do
    it 'returns true if the record has not been saved' do
      expect(User.new.new_record?).to be true
    end

    it 'returns false if the record has been saved' do
      expect(User.create(name: 'Jane', age: 25).new_record?).to be false
    end
  end
end
