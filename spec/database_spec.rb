require 'rspec'
require_relative '../database'

describe Database do
  let(:db) { Database.new }

  describe '#create_table' do
    it 'creates a new table in the database' do
      db.create_table(:users, %i[name email])
      expect(db.data).to include(:users)
    end
  end

  describe '#insert' do
    before { db.create_table(:users, %i[name email]) }

    it 'inserts a row into a table' do
      db.insert(:users, {  name: 'Alice', email: 'alice@example.com' })
      expect(db.data[:users]).to include({ id: 1, name: 'Alice', email: 'alice@example.com' })
    end

    it 'raises an error if the row contains invalid keys' do
      expect { db.insert(:users, { name: 'Alice', phone: '555-1234' }) }.to raise_error(ArgumentError)
    end
  end

  describe '#select!' do
    before do
      db.create_table(:users, %i[name email])
      db.insert(:users, {  name: 'Alice', email: 'alice@example.com' })
      db.insert(:users, {  name: 'Bob', email: 'bob@example.com' })
    end

    it 'selects rows from a table that match a given value' do
      users = db.select!(:users, :name, 'Alice')
      expect(users).to contain_exactly({ id: 1, name: 'Alice', email: 'alice@example.com' })
    end
  end

  describe '#delete' do
    before do
      db.create_table(:users, %i[name email])
      db.insert(:users, {  name: 'Alice', email: 'alice@example.com' })
      db.insert(:users, {  name: 'Bob', email: 'bob@example.com' })
    end

    it 'deletes rows from a table that match a given value' do
      db.delete(:users, :name, 'Alice')
      expect(db.data[:users]).to contain_exactly({ id: 2, name: 'Bob', email: 'bob@example.com' })
    end
  end

  describe '#update' do
    before do
      db.create_table(:users, %i[name email])
      db.insert(:users, {  name: 'Alice', email: 'alice@example.com' })
      db.insert(:users, {  name: 'Bob', email: 'bob@example.com' })
    end

    it 'updates rows from a table that match a given id' do
      db.update(:users, 1, :name, 'Alice Smith')
      expect(db.data[:users]).to contain_exactly(
        { id: 1, name: 'Alice Smith', email: 'alice@example.com' },
        { id: 2, name: 'Bob', email: 'bob@example.com' }
      )
    end
  end
end
