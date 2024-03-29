require_relative 'database'

class ActiveRecord
  def initialize(attributes = {})
    current_columns = self.class.instance_variable_get(:@column_names)

    attributes.each do |key, value|
      raise ArgumentError, "Unknown attribute '#{key}'" unless current_columns.include?(key)

      instance_variable_set("@#{key}", value)
    end
  end

  def self.columns(*column_names)
    @column_names = column_names
    @table_name = "#{to_s.downcase}s"
    @column_names << :id unless @column_names.include?(:id)

    connection.create_table(@table_name, @column_names)
    define_accessors(@column_names)
  end

  def self.connection
    @connection ||= Database.instance
  end

  def self.find(id)
    row = connection.select(@table_name, :id, id).first
    return nil unless row

    new(row)
  end

  def self.create(attributes = {})
    record = new(attributes)
    new_record = connection.insert(@table_name, record.instance_variables_hash)
    record.id = new_record[:id]
    record
  end

  def table_name
    self.class.instance_variable_get(:@table_name)
  end

  def update(attributes = {})
    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    self.class.connection.update(table_name, id, instance_variables_hash)
  end

  def destroy
    return unless id

    self.class.connection.delete(table_name, :id, id)
  end

  def save
    id ? update : new_record = self.class.create(instance_variables_hash)
    self.id = new_record.id if new_record

    true
  rescue StandardError
    false
  end

  def new_record?
    id.nil?
  end

  def self.define_accessors(columns)
    columns.each do |column|
      define_method(column) do
        instance_variable_get("@#{column}")
      end

      define_method("#{column}=") do |value|
        instance_variable_set("@#{column}", value)
      end
    end
  end

  def instance_variables_hash
    Hash[instance_variables.map { |name| [name.to_s.delete('@').to_sym, instance_variable_get(name)] }]
  end
end
