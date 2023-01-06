require 'rspec'
require_relative '../active_record'

describe ActiveRecord do
  describe '.inherited' do
    let(:subclass) { double }
    let(:columns) { %i[name] }

    before { allow(subclass).to receive(:columns).and_return(columns) }

    it 'creates a table in the database for the subclass when it is inherited' do
      subclass = double('User', superclass: ActiveRecord, columns: columns)
      table_name = "#{subclass.to_s.downcase}s"
      expect(ActiveRecord.connection).to receive(:create_table).with(table_name, columns)

      ActiveRecord.inherited(subclass)
    end

    it 'defines getters and setters for the columns' do
      ActiveRecord.inherited(subclass)

      model = ActiveRecord.new
      columns.each do |column|
        expect(model).to respond_to(column)
        expect(model).to respond_to("#{column}=")
      end
    end

    it 'sets and gets the value of an instance variable' do
      ActiveRecord.inherited(subclass)

      model = ActiveRecord.new
      model.id = 1
      model.name = 'Brayan'

      expect(model.id).to eq(1)
      expect(model.name).to eq('Brayan')
    end

    it 'sets the id of the model when it is created' do
      ActiveRecord.inherited(subclass)

      model = ActiveRecord.new
      expect(model).to respond_to(:id)
    end
  end
end
