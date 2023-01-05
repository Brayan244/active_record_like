class Database
  attr_accessor :data, :schema

  def initialize
    @data = {}
    @schema = {}
    @next_id = {}
  end

  def create_table(table_name, schema = [])
    @data[table_name] = []
    @schema[table_name] = schema
    @next_id[table_name] = 1
  end

  def insert(table_name, row)
    validate_row!(table_name, row)
    row[:id] = @next_id[table_name]
    @data[table_name] << row
    @next_id[table_name] += 1
  end

  def select!(table_name, column_name, value)
    @data[table_name].select do |row|
      row[column_name] == value
    end
  end

  def delete(table_name, column_name, value)
    @data[table_name].delete_if do |row|
      row[column_name] == value
    end
  end

  def update(table_name, id, column_name, value)
    rows_to_update = @data[table_name].select { |row| row[:id] == id }
    rows_to_update.each { |row| row[column_name] = value }

    rows_to_update.count
  end

  private

  def validate_row!(table_name, row)
    expected_keys = @schema[table_name]
    given_keys = row.except(:id).keys

    return unless given_keys.any? { |key| !expected_keys.include?(key) }

    raise ArgumentError, "Invalid row: Expected keys #{expected_keys}, got #{given_keys}"
  end
end
