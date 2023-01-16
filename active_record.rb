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
end
