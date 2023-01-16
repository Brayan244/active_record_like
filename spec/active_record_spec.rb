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
end
